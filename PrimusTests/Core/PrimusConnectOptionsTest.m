//
//  PrimusConnectOptionsTest.m
//  Primus
//
//  Created by Nuno Sousa on 11/02/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusConnectOptions.h"

SpecBegin(PrimusConnectOptions)

describe(@"PrimusConnectOptions", ^{
    it(@"initializes with defaults", ^{
        PrimusConnectOptions *options = [[PrimusConnectOptions alloc] init];

        expect(options.timeout).to.equal(10);
        expect(options.reconnect).to.beInstanceOf([PrimusReconnectOptions class]);
        expect(options.strategy).to.equal([NSArray array]);
        expect(options.ping).to.equal(25);
        expect(options.pong).to.equal(10);
        expect(options.autodetect).to.equal(YES);
        expect(options.manual).to.equal(NO);
        expect(options.transformerClass).to.beNil();
        expect(options.parserClass).to.beNil();
    });

    it(@"initializes with transformer class", ^{
        id fakeClass = mockClass([NSArray class]);

        PrimusConnectOptions *options = [[PrimusConnectOptions alloc] initWithTransformerClass:fakeClass];

        expect(options.transformerClass.description).to.equal(@"mock class of NSArray");
    });

    it(@"initializes with default reconnect strategy", ^{
        NSArray *strategy = @[@(kPrimusReconnectionStrategyTimeout)];

        PrimusConnectOptions *options = [[PrimusConnectOptions alloc] initWithStrategy:strategy];

        expect(options.reconnect.strategies).to.haveCountOf(1);
        expect(options.reconnect.strategies).to.contain(@(kPrimusReconnectionStrategyTimeout));
    });

    it(@"initializes with transformer class and default reconnect strategy", ^{
        id fakeClass = mockClass([NSArray class]);

        NSArray *strategy = @[@(kPrimusReconnectionStrategyTimeout)];

        PrimusConnectOptions *options = [[PrimusConnectOptions alloc] initWithTransformerClass:fakeClass andStrategy:strategy];

        expect(options.transformerClass.description).to.equal(@"mock class of NSArray");

        expect(options.reconnect.strategies).to.haveCountOf(1);
        expect(options.reconnect.strategies).to.contain(@(kPrimusReconnectionStrategyTimeout));
    });
});

SpecEnd
