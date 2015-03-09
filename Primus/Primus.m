//
//  Primus.m
//  Primus
//
//  Created by Nuno Sousa on 1/8/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>
#endif

#import <libextobjc/EXTScope.h>
#import <objc/runtime.h>

#import "Primus.h"

NSTimeInterval const kBackgroundFetchIntervalMinimum = 600;

@implementation Primus

@synthesize request = _request;
@synthesize options = _options;

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];

    return nil;
}

- (id)initWithURL:(NSURL *)url
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    return [self initWithURLRequest:request];
}

- (id)initWithURL:(NSURL *)url options:(PrimusConnectOptions *)options
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    return [self initWithURLRequest:request options:options];
}

- (id)initWithURLRequest:(NSURLRequest *)request
{
    PrimusConnectOptions *options = [[PrimusConnectOptions alloc] init];

    return [self initWithURLRequest:request options:options];
}

- (id)initWithURLRequest:(NSURLRequest *)request options:(PrimusConnectOptions *)options
{
    self = [super init];

    if (self) {
        _request = request;
        _options = options;
        _attemptOptions = nil;
        _reconnectOptions = options.reconnect;
        _buffer = [[NSMutableArray alloc] init];
        _transformers = [[PrimusTransformers alloc] init];
        _plugins = [[NSMutableDictionary alloc] init];
        _timers = [[PrimusTimers alloc] init];
        _reach = [Reachability reachabilityForInternetConnection];
        _online = YES;

        [self bindRealtimeEvents];
        [self bindNetworkEvents];
        [self bindSystemEvents];

        if (!options.manual) {
            _timers.open = [GCDTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^{
                [self open];
            }];
        }
    }

    return self;
}

/**
 * Setup internal listeners.
 */
- (void)bindRealtimeEvents
{
    [self on:@"outgoing::open" listener:^{
        _readyState = kPrimusReadyStateOpening;

        [self startTimeout];
    }];

    [self on:@"incoming::open" listener:^{
        _readyState = kPrimusReadyStateOpen;

        _attemptOptions = nil;

        [_timers.ping invalidate];
        _timers.ping = nil;

        [_timers.pong invalidate];
        _timers.pong = nil;

        [self emit:@"open"];

        [self startHeartbeat];

        if (_buffer.count > 0) {
            for (id data in _buffer) {
                [self write:data];
            }

            [_buffer removeAllObjects];
        }
    }];

    [self on:@"incoming::pong" listener:^(NSNumber *time) {
        _online = YES;

        [_timers.pong invalidate];
        _timers.pong = nil;

        [self startHeartbeat];
    }];

    [self on:@"incoming::error" listener:^(NSError *error) {
        [self emit:@"error", error];

        if (_attemptOptions.attempt > 1) {
            return [self reconnect];
        }

        if (_timers.connect) {
            if ([self.options.reconnect.strategies containsObject:@(kPrimusReconnectionStrategyTimeout)]) {
                [self reconnect];
            } else {
                [self end];
            }
        }
    }];

    [self on:@"incoming::data" listener:^(id raw) {
        [self.parser decode:raw callback:^(NSError *error, id data) {
            if (error) {
                return [self emit:@"error", error];
            }

            if ([data isKindOfClass:[NSString class]]) {
                if ([data isEqualToString:@"primus::server::close"]) {
                    return [self end];
                }

                if ([data hasPrefix:@"primus::pong::"]) {
                    return [self emit:@"incoming::pong", [data substringFromIndex:14]];
                }

                if ([data hasPrefix:@"primus::id::"]) {
                    return [self emit:@"incoming::id", [data substringFromIndex:12]];
                }
            }

            for (PrimusTransformCallback transform in self.transformers.incoming) {
                NSMutableDictionary *packet = [@{ @"data": data } mutableCopy];

                if (NO == transform(packet)) {
                    // When false is returned by an incoming transformer it means that's
                    // being handled by the transformer and we should not emit the `data`
                    // event.

                    return;
                }

                data = packet[@"data"];
            }

            [self emit:@"data", data, raw];
        }];
    }];

    [self on:@"incoming::end" listener:^(NSString *intentional) {
        if (kPrimusReadyStateOpen != self.readyState && !_attemptOptions) {
            return;
        }

        _readyState = kPrimusReadyStateClosed;

        if ([intentional isEqualToString:@"primus::server::close"]) {
            [_timers clearAll];

            return [self emit:@"end"];
        }

        [self emit:@"close"];

        if ([self.options.reconnect.strategies containsObject:@(kPrimusReconnectionStrategyDisconnect)]) {
            [self reconnect];
        } else {
            [_timers clearAll];
        }
    }];
}

/**
 * Listen for network change events
 */
- (void)bindNetworkEvents
{
    @weakify(self);

    _reach.reachableBlock = ^(Reachability *reach) {
        @strongify(self);

        self->_online = YES;

        [self emit:@"online"];

        if ([self.options.reconnect.strategies containsObject:@(kPrimusReconnectionStrategyOnline)]) {
            [self reconnect];
        }
    };

    _reach.unreachableBlock = ^(Reachability *reach) {
        @strongify(self);

        self->_online = NO;

        [self emit:@"offline"];

        [self end];
    };

    [_reach startNotifier];
}

/**
 * Listen for app state change events
 */
- (void)bindSystemEvents
{
#if __has_include(<UIKit/UIKit.h>)
    [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
        if (NO == self.options.stayConnectedInBackground) {
            return;
        }

        // Send a keep-alive ping every 10 minutes while in background
        [UIApplication.sharedApplication setKeepAliveTimeout:kBackgroundFetchIntervalMinimum handler:^{
            [self ping];
        }];
    }];

    [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note) {
        // Clear the keep-alive ping after resuming from background
        if (YES == self.options.stayConnectedInBackground) {
            [UIApplication.sharedApplication clearKeepAliveTimeout];

            return;
        }

        // Do not reconnect if the connection was previously closed
        if (!self.online) {
            return;
        }

        // Reconnect to the server after resuming from background
        if ([self.options.reconnect.strategies containsObject:@(kPrimusReconnectionStrategyOnline)]) {
            [self ping];
        }
    }];
#endif
}

/**
 * Initialise and setup the transformer and parser.
 */
- (void)initialize
{
    Class transformerClass = self.options.transformerClass;
    Class parserClass = self.options.parserClass;

    if (self.options.autodetect) {
        // If there is no transformer set, request the /spec endpoint and
        // map the server-side transformer to our client-side one.
        // Also, since we already have that information, set the parser as well.
        NSDictionary *spec = [self getJSONData:[self.request.URL URLByAppendingPathComponent:@"spec"]];

        if (!transformerClass) {
            transformerClass = NSClassFromString([self.transformers mapTransformer:spec[@"transformer"]]);
        }

        if (!parserClass) {
            parserClass = NSClassFromString([spec[@"parser"] uppercaseString]);
        }

        // Subtract 10 seconds from the maximum server-side timeout, as per the
        // official Primus server-side documentation.
        NSTimeInterval timeout = ((NSNumber *)spec[@"timeout"]).doubleValue - 10e3;

        self.options.ping = MAX(MIN(self.options.ping, timeout / 1000.0f), 0);
    }

    // If the calculated ping is smaller than the minimum allowed interval, disable background.
    if (self.options.ping < kBackgroundFetchIntervalMinimum) {
        self.options.stayConnectedInBackground = NO;
    }

    // If there is no parser set, use JSON as default
    if (!parserClass) {
        parserClass = NSClassFromString(@"JSON");
    }

    if (transformerClass && ![transformerClass conformsToProtocol:@protocol(TransformerProtocol)]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Transformer does not implement TransformerProtocol." userInfo:nil];
    }

    if (parserClass && ![parserClass conformsToProtocol:@protocol(ParserProtocol)]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Parser does not implement ParserProtocol." userInfo:nil];
    }

    // Initialize the transformer and parser
    self.options.transformerClass = transformerClass;
    self.options.parserClass = parserClass;

    if (!_transformer) {
        _transformer = [[self.options.transformerClass alloc] initWithPrimus:self];
    }

    if (!_parser) {
        _parser = [[self.options.parserClass alloc] init];
    }

    [self emit:@"initialised", self.transformer, self.parser];
}

/**
 * Synchronously retrieve JSON data from a URL.
 */
- (NSDictionary *)getJSONData:(NSURL *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    NSHTTPURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];

    if (200 != response.statusCode){
        return nil;
    }

    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}

/**
 * Establish a connection with the server.
 */
- (void)open
{
    if (kPrimusReadyStateClosed != self.readyState) {
        return;
    }

    [self initialize];

    if (!self.transformer) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"No transformer specified." userInfo:nil];
    }

    if (!self.parser) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"No parser specified." userInfo:nil];
    }

    // Resolve and instantiate plugins
    [self.plugins removeAllObjects];

    for (NSString *pluginName in self.options.plugins.allKeys) {
        id pluginClass = self.options.plugins[pluginName];
        id plugin = nil;

        if ([pluginClass isKindOfClass:NSString.class]) {
            plugin = [NSClassFromString(pluginClass) alloc];
        }

        if (class_isMetaClass(object_getClass(pluginClass))) {
            plugin = [(Class)pluginClass alloc];
        }

        if (![plugin conformsToProtocol:@protocol(PluginProtocol)]) {
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Plugin should be a class whose instances conform to PluginProtocol" userInfo:nil];
        }

        self.plugins[pluginName] = [plugin initWithPrimus:self];
    }

    [self emit:@"outgoing::open"];
}

/**
 * Send a new message.
 *
 * @param data  The data that needs to be written.
 * @returns     Always returns true.
 */
- (BOOL)write:(id)data
{
    if (kPrimusReadyStateOpen != self.readyState) {
        [_buffer addObject:data];

        return YES;
    }

    for (PrimusTransformCallback transform in self.transformers.outgoing) {
        NSMutableDictionary *packet = [@{ @"data": data } mutableCopy];

        if (NO == transform(packet)) {
            // When false is returned by an incoming transformer it means that's
            // being handled by the transformer and we should not emit the `data`
            // event.

            return NO;
        }

        data = packet[@"data"];
    }

    [self.parser encode:data callback:^(NSError *error, id packet) {
        if (error) {
            return [self emit:@"error", error];
        }

        [self emit:@"outgoing::data", packet];
    }];

    return YES;
}

/**
 * Retrieve the current id from the server.
 *
 * @param fn Callback function.
 */
- (void)id:(PrimusIdCallback)fn
{
    if (self.transformer && [self.transformer respondsToSelector:@selector(id)]) {
        return fn(self.transformer.id);
    }

    [self write:@"primus::id::"];

    [self once:@"incoming::id" listener:fn];
}

- (void)pong
{
    [_timers.pong invalidate];
    _timers.pong = nil;

    if (self.online) {
        return;
    }

    _online = NO;

    [self emit:@"offline"];
    [self emit:@"incoming::end", nil];
}

- (void)ping
{
    [_timers.ping invalidate];
    _timers.ping = nil;

    [self write:[NSString stringWithFormat:@"primus::ping::%f", [[NSDate date] timeIntervalSince1970]]];
    [self emit:@"outgoing::ping"];

    _timers.pong = [GCDTimer scheduledTimerWithTimeInterval:self.options.pong repeats:NO block:^{
        [self pong];
    }];
}

/**
 * Send a new heartbeat over the connection to ensure that we're still
 * connected and our internet connection didn't drop. We cannot use server side
 * heartbeats for this unfortunately.
 */
- (void)startHeartbeat
{
    if (! self.options.ping) {
        return;
    }

    _timers.ping = [GCDTimer scheduledTimerWithTimeInterval:self.options.ping repeats:NO block:^{
        [self ping];
    }];
}

/**
 * Start a connection timeout.
 */
- (void)startTimeout
{
    dispatch_block_t stop = ^{
        [_timers.connect invalidate];
        _timers.connect = nil;
    };

    _timers.connect = [GCDTimer scheduledTimerWithTimeInterval:self.options.timeout repeats:NO block:^{
        stop();

        if (kPrimusReadyStateOpen == self.readyState || _attemptOptions) {
            return;
        }

        [self emit:@"timeout", [NSError errorWithDomain:kPrimusErrorDomain code:kPrimusErrorConnectionTimeout userInfo:@{
            NSLocalizedDescriptionKey: @"Connection timeout"
        }]];

        if ([self.options.reconnect.strategies containsObject:@(kPrimusReconnectionStrategyTimeout)]) {
            [self reconnect];
        } else {
            [self end];
        }
    }];

    [self once:@"open" listener:stop];
    [self once:@"end" listener:stop];
}

/**
 * Exponential back off algorithm for retry operations. It uses an randomized
 * retry so we don't DDOS our server when it goes down under pressure.
 *
 * @param callback  Callback to be called after the timeout.
 * @param opts      Options for configuring the timeout.
 */
- (void)backoff:(PrimusReconnectCallback)callback options:(PrimusReconnectOptions *)options
{
    if (options.backoff) {
        return;
    }

    if (options.attempt > options.retries) {
        NSError *error = [NSError errorWithDomain:kPrimusErrorDomain code:kPrimusErrorUnableToRetry userInfo:@{
            NSLocalizedDescriptionKey: @"Maximum reconnect attempts reached"
        }];

        callback(error, options);

        return;
    }

    options.backoff = YES;

    options.timeout = options.attempt != 0
        ? MIN(round((drand48() + 1) * options.minDelay * pow(options.factor, options.attempt)), options.maxDelay)
        : options.minDelay;

    [self emit:@"reconnecting", options];

    _timers.reconnect = [GCDTimer scheduledTimerWithTimeInterval:options.timeout repeats:NO block:^{
        _timers.reconnect = nil;

        callback(nil, options);

        options.attempt++;
        options.backoff = NO;
    }];
}

/**
 * Start a new reconnect procedure.
 */
- (void)reconnect
{
    // Try to re-use the existing attempt.
    _attemptOptions = _attemptOptions ?: [_reconnectOptions copy];

    [self backoff:^(NSError *error, PrimusReconnectOptions *options) {
        if (error) {
            _attemptOptions = nil;

            return [self emit:@"end"];
        }

        // Try to re-open the connection again.
        [self emit:@"reconnect", options];
        [self emit:@"outgoing::reconnect"];
    } options:_attemptOptions];
}

/**
 * Close the connection.
 */
- (void)end
{
    [self end:nil];
}

/**
 * Close the connection.
 *
 * @param data  The last packet of data.
 */
- (void)end:(id)data
{
    if (kPrimusReadyStateClosed == self.readyState && !_timers.connect) {
        return;
    }

    if (data) {
        [self write:data];
    }

    _writable = NO;
    _readyState = kPrimusReadyStateClosed;

    [_plugins removeAllObjects];
    [_timers clearAll];

    [self emit:@"outgoing::end"];
    [self emit:@"close"];
    [self emit:@"end"];
}

/**
 * Register a new message transformer. This allows you to easily manipulate incoming
 * and outgoing data which is particularity handy for plugins that want to send
 * meta data together with the messages.
 *
 * @param type  Incoming or outgoing
 * @param fn    A new message transformer.
 */
- (void)transform:(NSString *)type fn:(PrimusTransformCallback)fn
{
    if ([type isEqualToString:@"incoming"]) {
        [self.transformers.incoming addObject:fn];

        return;
    }

    if ([type isEqualToString:@"outgoing"]) {
        [self.transformers.outgoing addObject:fn];

        return;
    }
}

@end
