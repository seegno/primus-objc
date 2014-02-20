//
//  PrimusProtocol.h
//  Primus
//
//  Created by Nuno Sousa on 17/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import <Emitter/Emitter.h>

#import "PrimusConnectOptions.h"
#import "PrimusReconnectOptions.h"

#define recursiveBlock(outerBlock, innerBlock) void (^outerBlock)(); __block void (^block)() = outerBlock; innerBlock(block);

typedef NS_ENUM(int16_t, PrimusReadyState) {
    kPrimusReadyStateClosed,
    kPrimusReadyStateOpening,
    kPrimusReadyStateOpen
};

typedef BOOL (^PrimusTransformCallback)(NSDictionary *data);

@protocol PrimusProtocol <NSObject>

@property (nonatomic) NSURLRequest *request;

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
