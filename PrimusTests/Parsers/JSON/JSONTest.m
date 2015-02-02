//
//  JSONTest.m
//  PrimusTests
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "JSON.h"

SpecBegin(JSON)

describe(@"JSON", ^{
    __block JSON *serializer;

    beforeEach(^{
        serializer = [[JSON alloc] init];
    });

    it(@"encodes raw data", ^AsyncBlock {
        [serializer encode:@{ @"key": @"value" } callback:^(NSError *error, NSString *data) {
            expect(error).to.beNil();
            expect(data).to.equal(@"{\"key\":\"value\"}");

            done();
        }];
    });

    it(@"encodes string data", ^AsyncBlock {
        [serializer encode:@"string-data" callback:^(NSError *error, id data) {
            expect(error).to.beNil();
            expect(data).to.equal(@"\"string-data\"");

            done();
        }];
    });

    it(@"returns error during encoding", ^AsyncBlock {
        [serializer encode:@123 callback:^(NSError *error, id data) {
            expect(error).notTo.beNil();
            expect(error.localizedFailureReason).to.contain(@"Invalid top-level type in JSON write");
            expect(data).to.beNil();

            done();
        }];
    });

    it(@"decodes raw data", ^AsyncBlock {
        [serializer decode:[@"{\"key\":\"value\"}" dataUsingEncoding:NSUTF8StringEncoding] callback:^(NSError *error, id data) {
            expect(error).to.beNil();
            expect(data).to.equal(@{ @"key": @"value" });

            done();
        }];
    });

    it(@"decodes dictionary data", ^AsyncBlock {
        [serializer decode:@{ @"key": @"value" } callback:^(NSError *error, id data) {
            expect(error).to.beNil();
            expect(data).to.equal(@{ @"key": @"value" });

            done();
        }];
    });

    it(@"returns error during decoding", ^AsyncBlock {
        [serializer decode:[@"{\"key\"}" dataUsingEncoding:NSUTF8StringEncoding] callback:^(NSError *error, id data) {
            expect(error).notTo.beNil();
            expect(data).to.beNil();

            done();
        }];
    });
});

SpecEnd
