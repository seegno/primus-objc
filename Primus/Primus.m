//
//  Primus.m
//  Primus
//
//  Created by Nuno Sousa on 1/8/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import <libextobjc/EXTScope.h>

#import "Primus.h"

@implementation Primus

@synthesize request = _request;

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
        _timers = [[PrimusTimers alloc] init];
        _reach = [Reachability reachabilityForInternetConnection];
        _online = YES;

        [self bindRealtimeEvents];
        [self bindNetworkEvents];
        [self initialize];

        if (!options.manual) {
            _timers.open = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(open) userInfo:nil repeats:NO];
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
    }];

    [self on:@"incoming::open" listener:^{
        _readyState = kPrimusReadyStateOpen;

        [self emit:@"open"];

        [_timers.ping invalidate];
        _timers.ping = nil;

        [_timers.pong invalidate];
        _timers.pong = nil;

        [self heartbeat];

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

        [self heartbeat];
    }];

    [self on:@"incoming::error" listener:^(NSError *error) {
        [self emit:@"error", error];

        if (_attemptOptions.attempt) {
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
            }

            for (PrimusTransformCallback transform in self.transformers.incoming) {
                NSDictionary *packet = @{ @"data": data };

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
        PrimusReadyState readyState = self.readyState;

        _readyState = kPrimusReadyStateClosed;

        if (kPrimusReadyStateOpen != readyState) {
            return;
        }

        [_timers clearAll];

        if ([intentional isEqualToString:@"primus::server::close"]) {
            return [self emit:@"end"];
        }

        [self emit:@"close"];

        if ([self.options.reconnect.strategies containsObject:@(kPrimusReconnectionStrategyDisconnect)]) {
            [self reconnect];
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
 * Initialise and setup the transformer and parser.
 */
- (void)initialize
{
    Class transformerClass = self.options.transformerClass;
    Class parserClass = self.options.parserClass;

    if (!transformerClass && self.options.autodetect) {
        // If there is no transformer set, request the /spec endpoint and
        // map the server-side transformer to our client-side one.
        // Also, since we already have that information, set the parser as well.
        NSDictionary *spec = [self getJSONData:[self.request.URL URLByAppendingPathComponent:@"spec"]];

        transformerClass = NSClassFromString([self.transformers mapTransformer:spec[@"transformer"]]);
        parserClass = NSClassFromString(spec[@"parser"]);
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

    self.options.transformerClass = transformerClass;
    self.options.parserClass = parserClass;

    // Initialize the transformer and parser
    _transformer = [[self.options.transformerClass alloc] initWithPrimus:self];
    _parser = [[self.options.parserClass alloc] init];

    [NSTimer scheduledTimerWithTimeInterval:0 block:^{
        [self emit:@"initialised", self.transformer, self.parser];
    } repeats:NO];
}

/**
 * Synchronously retrieve JSON data from a URL.
 */
- (NSDictionary *)getJSONData:(NSURL *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

    NSHTTPURLResponse *responseCode = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:nil];

    if(200 != responseCode.statusCode){
        [self emit:@"error", responseCode];

        return nil;
    }

    return [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
}

/**
 * Establish a connection with the server. When this function is called we
 * assume that we don't have any open connections. If you do call it when you
 * have a connection open, it could cause duplicate connections.
 */
- (void)open
{
    if (!self.transformer) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"No transformer specified." userInfo:nil];
    }

    if (!self.parser) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"No parser specified." userInfo:nil];
    }

    [self emit:@"outgoing::open"];
}

/**
 * Send a new message.
 *
 * @param {Mixed} data The data that needs to be written.
 * @returns {Boolean} Always returns true.
 */
- (BOOL)write:(id)data
{
    if (kPrimusReadyStateOpen != self.readyState) {
        [_buffer addObject:data];

        return YES;
    }

    for (PrimusTransformCallback transform in self.transformers.outgoing) {
        NSDictionary *packet = @{ @"data": data };

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
 * Send a new heartbeat over the connection to ensure that we're still
 * connected and our internet connection didn't drop. We cannot use server side
 * heartbeats for this unfortunately.
 */
- (void)heartbeat
{
    if (! self.options.ping) {
        return;
    }

    id pong = ^{
        [_timers.pong invalidate];
        _timers.pong = nil;

        if (self.online) {
            return;
        }

        _online = NO;

        [self emit:@"offline"];
        [self emit:@"incoming::end", nil];
    };

    id ping = ^{
        [_timers.ping invalidate];
        _timers.ping = nil;

        [self write:[NSString stringWithFormat:@"primus::ping::%f", [[NSDate date] timeIntervalSince1970]]];
        [self emit:@"outgoing::ping"];

        _timers.pong = [NSTimer scheduledTimerWithTimeInterval:self.options.pong block:pong repeats:NO];
    };

    _timers.ping = [NSTimer scheduledTimerWithTimeInterval:self.options.ping block:ping repeats:NO];
}

/**
 * Start a connection timeout.
 */
- (void)timeout
{
    recursiveBlock(remove, ^(id block) {
        [self removeListener:@"error" listener:block];
        [self removeListener:@"open" listener:block];
        [self removeListener:@"end" listener:block];

        [_timers.connect invalidate];
        _timers.connect = nil;
    });

    _timers.connect = [NSTimer scheduledTimerWithTimeInterval:self.options.timeout block:^{
        remove();

        if (kPrimusReadyStateOpen == self.readyState || _attemptOptions.attempt) {
            return;
        }

        [self emit:@"timeout"];

        if ([self.options.reconnect.strategies containsObject:@(kPrimusReconnectionStrategyTimeout)]) {
            [self reconnect];
        } else {
            [self end];
        }
    } repeats:NO];

    [self on:@"error" listener:remove];
    [self on:@"open" listener:remove];
    [self on:@"end" listener:remove];
}

/**
 * Exponential back off algorithm for retry operations. It uses an randomized
 * retry so we don't DDOS our server when it goes down under pressure.
 *
 * @param {Function} callback Callback to be called after the timeout.
 * @param {Object} opts Options for configuring the timeout.
 */
- (void)backoff:(PrimusReconnectCallback)callback options:(PrimusReconnectOptions *)options
{
    if (options.backoff) {
        return;
    }

    if (options.attempt > options.retries) {
        NSError *error = [NSError errorWithDomain:kPrimusErrorDomain code:kPrimusErrorUnableToRetry userInfo:nil];

        callback(error, options);

        return;
    }

    options.backoff = YES;

    options.timeout = options.attempt != 1
        ? MIN(round((rand() + 1) * options.minDelay * pow(options.factor, options.attempt)), options.maxDelay)
        : options.minDelay;

    [self emit:@"reconnecting", options];

    _timers.reconnect = [NSTimer scheduledTimerWithTimeInterval:options.timeout block:^{
        options.backoff = NO;

        _timers.reconnect = nil;

        callback(nil, options);
    } repeats:NO];
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
 * @param {Mixed} data last packet of data.
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
 * @param {String} type Incoming or outgoing
 * @param {Function} fn A new message transformer.
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
