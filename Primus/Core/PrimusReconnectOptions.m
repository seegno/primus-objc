//
//  PrimusReconnectOptions.m
//  Primus
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusReconnectOptions.h"

@implementation PrimusReconnectOptions

- (id)init
{
    return [self initWithStrategy:@[
        @(kPrimusReconnectionStrategyOnline),
        @(kPrimusReconnectionStrategyDisconnect),
        @(kPrimusReconnectionStrategyTimeout)
    ]];
}

- (id)initWithStrategy:(NSArray *)strategy
{
    self = [super init];

    if (self) {
        _maxDelay = NSIntegerMax;
        _minDelay = 0.5f;
        _retries = 10;
        _attempt = 1;
        _factor = 2;
        _timeout = -1;
        _backoff = NO;
        _authorization = NO;
        _strategies = [[NSMutableSet alloc] initWithArray:strategy];
    }

    return self;
}

- (id)initWithOptions:(PrimusReconnectOptions *)options
{
    self = [self init];

    if (self) {
        _maxDelay = options.maxDelay ?: _maxDelay;
        _minDelay = options.minDelay ?: _minDelay;
        _retries = options.retries ?: _retries;
        _attempt = options.attempt ?: _attempt;
        _factor = options.factor ?: _factor;
        _timeout = options.timeout ?: _timeout;
        _backoff = options.backoff ?: _backoff;
        _authorization = options.authorization ?: _authorization;
        _strategies = options.strategies ?: _strategies;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[PrimusReconnectOptions allocWithZone:zone] initWithOptions:self];
}

- (void)setAuthorization:(BOOL)authorization
{
    _authorization = authorization;

    if (authorization) {
        [_strategies addObject:@(kPrimusReconnectionStrategyTimeout)];
    }
}

@end
