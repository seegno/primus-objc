//
//  PrimusConnectOptions.m
//  Primus
//
//  Created by Nuno Sousa on 15/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusConnectOptions.h"

@implementation PrimusConnectOptions

- (id)init
{
    return [self initWithTransformerClass:nil andStrategy:nil];
}

- (id)initWithStrategy:(NSArray *)strategy
{
    return [self initWithTransformerClass:nil andStrategy:strategy];
}

- (id)initWithTransformerClass:(Class)transformerClass
{
    return [self initWithTransformerClass:transformerClass andStrategy:nil];
}

- (id)initWithTransformerClass:(Class)transformerClass andStrategy:(NSArray *)strategy
{
    self = [super init];

    if (self) {
        _reconnect = [[PrimusReconnectOptions alloc] init];
        _strategy = strategy ?: [NSArray array];
        _timeout = 10;
        _ping = 25;
        _pong = 10;
        _autodetect = YES;
        _manual = NO;
        _transformerClass = transformerClass;
        _parserClass = nil;

        if (strategy) {
            _reconnect.strategies = [[NSMutableSet alloc] initWithArray:strategy];
        }
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[PrimusConnectOptions allocWithZone:zone] initWithTransformerClass:self.transformerClass andStrategy:self.strategy];
}

@end
