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
        _stayConnectedInBackground = [[NSBundle.mainBundle objectForInfoDictionaryKey:@"UIBackgroundModes"] containsObject:@"voip"];
        _plugins = nil;
        _transformerClass = transformerClass;
        _parserClass = nil;

        // Initialize reconnect strategies
        if (strategy) {
            _reconnect.strategies = [[NSMutableSet alloc] initWithArray:strategy];
        }

        // Set the ping time to 10 minutes and 25 seconds
        if (_stayConnectedInBackground) {
            _ping = 625;
        }
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[PrimusConnectOptions allocWithZone:zone] initWithTransformerClass:self.transformerClass andStrategy:self.strategy];
}

@end
