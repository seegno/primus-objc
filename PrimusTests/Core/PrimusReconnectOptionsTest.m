//
//  PrimusReconnectOptionsTest.m
//  Primus
//
//  Created by Nuno Sousa on 11/02/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusReconnectOptions.h"

SpecBegin(PrimusReconnectOptions)

describe(@"PrimusReconnectOptions", ^{
    it(@"initializes with strategy", ^{
        NSArray *strategy = @[@(kPrimusReconnectionStrategyTimeout)];

        PrimusReconnectOptions *options = [[PrimusReconnectOptions alloc] initWithStrategy:strategy];

        expect(options.strategies).to.haveCountOf(1);
        expect(options.strategies).to.contain(@(kPrimusReconnectionStrategyTimeout));
    });

    it(@"initializes with default reconnection strategies", ^{
        PrimusReconnectOptions *options = [[PrimusReconnectOptions alloc] init];

        expect(options.strategies).to.contain(@(kPrimusReconnectionStrategyDisconnect));
        expect(options.strategies).to.contain(@(kPrimusReconnectionStrategyOnline));
    });

    it(@"initializes with timeout strategy if authorization is defined", ^{
        PrimusReconnectOptions *options = [[PrimusReconnectOptions alloc] init];

        options.authorization = YES;

        expect(options.strategies).to.contain(@(kPrimusReconnectionStrategyTimeout));
    });

    it(@"initializes with overridden options", ^{
        PrimusReconnectOptions *base = [[PrimusReconnectOptions alloc] init];

        base.maxDelay = 1;
        base.minDelay = 2;
        base.retries = 3;
        base.attempt = 4;
        base.factor = 5;
        base.timeout = 6;
        base.backoff = YES;
        base.authorization = YES;
        base.strategies = [NSMutableSet new];

        PrimusReconnectOptions *options = [[PrimusReconnectOptions alloc] initWithOptions:base];

        expect(options.maxDelay).to.equal(base.maxDelay);
        expect(options.minDelay).to.equal(base.minDelay);
        expect(options.retries).to.equal(base.retries);
        expect(options.attempt).to.equal(base.attempt);
        expect(options.factor).to.equal(base.factor);
        expect(options.timeout).to.equal(base.timeout);
        expect(options.backoff).to.equal(base.backoff);
        expect(options.authorization).to.equal(base.authorization);
        expect(options.strategies).to.equal(base.strategies);
    });

    it(@"does not duplicate strategies", ^{
        PrimusReconnectOptions *options = [[PrimusReconnectOptions alloc] init];

        [options.strategies removeAllObjects];

        [options.strategies addObject:@(kPrimusReconnectionStrategyOnline)];
        [options.strategies addObject:@(kPrimusReconnectionStrategyOnline)];

        expect(options.strategies).to.haveCountOf(1);
    });
});

SpecEnd
