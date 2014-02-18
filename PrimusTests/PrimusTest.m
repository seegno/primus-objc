//
//  PrimusTest.m
//  PrimusTests
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "Primus.h"

SpecBegin(Primus)

describe(@"Primus", ^{
    __block Primus *primus;

    setAsyncSpecTimeout(1.0);

    beforeEach(^{
        NSURL *url = [NSURL URLWithString:@"http://127.0.0.1"];
        PrimusConnectOptions *options = [[PrimusConnectOptions alloc] init];

        options.manual = YES;

        primus = [[Primus alloc] initWithURL:url options:options];

        primus.transformer = mockObjectAndProtocol([NSObject class], @protocol(TransformerProtocol));
    });

    it(@"initializes with defaults", ^{
        expect(primus.online).to.equal(YES);
        expect(primus.writable).to.equal(NO);
        expect(primus.readyState).to.equal(kPrimusReadyStateClosed);
        expect(primus.options).to.beInstanceOf([PrimusConnectOptions class]);
    });

    it(@"throws an error if initialised without a transformer", ^{
        expect(^{
            primus.transformer = nil;

            [primus open];
        }).to.raiseWithReason(@"NSInvalidArgumentException", @"No transformer specified.");
    });

    it(@"throws an error if initialised with an invalid transformer", ^{
        expect(^{
            NSURL *url = [NSURL URLWithString:@"http://127.0.0.1"];
            PrimusConnectOptions *options = [[PrimusConnectOptions alloc] init];

            options.transformerClass = [NSObject class];

            [[[Primus alloc] initWithURL:url options:options] description];
        }).to.raiseWithReason(@"NSInvalidArgumentException", @"Transformer does not implement TransformerProtocol.");
    });

    it(@"emits an `initialised` event when the server is fully constructed", ^AsyncBlock {
        [primus on:@"initialised" listener:^(id<TransformerProtocol> transformer, id<ParserProtocol> parser) {
            expect(transformer).to.equal(primus.transformer);
            expect(parser).to.equal(primus.parser);

            done();
        }];
    });

    it(@"emits an `open` event", ^AsyncBlock {
        [primus on:@"open" listener:^{
            done();
        }];

        [primus emit:@"incoming::open"];
    });

    it(@"emits an `end` event after closing", ^AsyncBlock {
        [primus on:@"end" listener:^{
            done();
        }];

        [primus open];
        [primus end];
    });

    it(@"emits a `close` event after closing", ^AsyncBlock {
        [primus on:@"close" listener:^{
            done();
        }];

        [primus open];
        [primus end];
    });

    it(@"emits an `error` event when it cannot encode the data", ^AsyncBlock {
        [primus on:@"error" listener:^(NSError *error){
            expect(error).notTo.beNil();
            expect(error.localizedFailureReason).to.contain(@"Invalid top-level type in JSON write");

            done();
        }];

        [primus emit:@"incoming::open"];

        [primus write:@123];
    });

    it(@"only emits `end` once", ^{
        [primus end];

        [primus on:@"end" listener:^{
            XCTFail(@"listener should not fire");
        }];

        [primus end];
    });

    it(@"buffers messages before connecting", ^AsyncBlock {
        __block int received = 0;
        int messages = 10;

        for(int i=0; i < messages; i++) {
            [primus write:@{ @"echo": @(i) }];
        }

        [primus on:@"outgoing::data" listener:^{
            if (++received == messages) {
                done();
            }
        }];

        [primus emit:@"incoming::open"];
    });

    it(@"should not open the socket if the state is manual", ^{
        [primus on:@"open" listener:^{
            XCTFail(@"listener should not fire");
        }];

        expect(primus.readyState).notTo.equal(kPrimusReadyStateOpen);
    });

    it(@"should not reconnect when we close the connection", ^{
        [primus emit:@"incoming::open"];

        [primus on:@"reconnect" listener:^(PrimusReconnectOptions *options) {
            XCTFail(@"listener should not fire");
        }];

        [primus end];
    });

    it(@"should not reconnect when strategy is none", ^{
        [primus.options.reconnect.strategies removeAllObjects];

        [primus on:@"reconnect" listener:^(PrimusReconnectOptions *options) {
            XCTFail(@"listener should not fire");
        }];

        [primus emit:@"incoming::open"];

        [primus emit:@"incoming::end"];
    });

    it(@"should reconnect when the connection closes unexpectedly", ^AsyncBlock {
        [primus on:@"reconnect" listener:^(PrimusReconnectOptions *options) {
            done();
        }];

        [primus emit:@"incoming::open"];

        [primus emit:@"incoming::end"];
    });

    it(@"should reset the reconnect details after a successful reconnect", ^AsyncBlock {
        [primus on:@"reconnect" listener:^(PrimusReconnectOptions *attempt) {
            expect(primus.attemptOptions).toNot.beNil();
            expect(primus.attemptOptions.attempt).to.beGreaterThan(0);
            expect(primus.attemptOptions.minDelay).to.equal(0.5);
            expect(primus.attemptOptions.maxDelay).to.equal(NSIntegerMax);
            expect(primus.attemptOptions.timeout).to.beLessThan(2);
            expect(primus.attemptOptions.timeout).to.beGreaterThan(0.099);

            done();
        }];

        [primus reconnect];
    });

    it(@"should change readyStates", ^AsyncBlock {
        expect(primus.readyState).to.equal(@(kPrimusReadyStateClosed));

        [primus open];

        expect(primus.readyState).to.equal(@(kPrimusReadyStateOpening));

        [primus on:@"open" listener:^{
            expect(primus.readyState).to.equal(@(kPrimusReadyStateOpen));

            [primus end];
        }];

        [primus on:@"end" listener:^{
            expect(primus.readyState).to.equal(@(kPrimusReadyStateClosed));

            done();
        }];

        [primus emit:@"incoming::open"];
    });
});

SpecEnd
