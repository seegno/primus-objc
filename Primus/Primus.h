//
//  Primus.h
//  Primus
//
//  Created by Nuno Sousa on 1/8/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import <Reachability/Reachability.h>
#import <NSTimer-Blocks/NSTimer+Blocks.h>

#import "TransformerProtocol.h"
#import "ParserProtocol.h"
#import "PluginProtocol.h"

#import "PrimusError.h"
#import "PrimusTimers.h"
#import "PrimusTransformers.h"
#import "PrimusConnectOptions.h"
#import "PrimusReconnectOptions.h"
#import "PrimusProtocol.h"

typedef NS_ENUM(int16_t, PrimusReadyState) {
    kPrimusReadyStateClosed,
    kPrimusReadyStateOpening,
    kPrimusReadyStateOpen
};

typedef BOOL (^PrimusTransformCallback)(NSDictionary *data);

@interface Primus : NSObject<PrimusProtocol>
{
    NSUInteger _timeout;
    NSMutableArray *_buffer;
    PrimusTimers *_timers;
    Reachability *_reach;
}

@property (nonatomic, readonly) BOOL online;
@property (nonatomic, readonly) BOOL writable;
@property (nonatomic, readonly) PrimusReadyState readyState;
@property (nonatomic, readonly) PrimusConnectOptions *options;
@property (nonatomic, readonly) PrimusReconnectOptions *reconnectOptions;
@property (nonatomic, readonly) PrimusReconnectOptions *attemptOptions;

@property (nonatomic, readonly) PrimusTransformers *transformers;
@property (nonatomic, readonly) NSDictionary *plugins;
@property (nonatomic) id<TransformerProtocol> transformer;
@property (nonatomic) id<ParserProtocol> parser;

- (id)init __unavailable;
- (id)initWithURL:(NSURL *)url;
- (id)initWithURL:(NSURL *)url options:(PrimusConnectOptions *)options;
- (id)initWithURLRequest:(NSURLRequest *)request;
- (id)initWithURLRequest:(NSURLRequest *)request options:(PrimusConnectOptions *)options;

- (void)open;
- (BOOL)write:(id)data;
- (void)backoff:(PrimusReconnectCallback)callback options:(PrimusReconnectOptions *)options;
- (void)reconnect;
- (void)end;
- (void)end:(id)data;
- (void)transform:(NSString *)type fn:(PrimusTransformCallback)fn;

@end
