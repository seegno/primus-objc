//
//  TransformerBehaviorTest.m
//  PrimusTests
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "Primus.h"

SharedExamplesBegin(TransformerBehavior)

sharedExamplesFor(@"a transformer", ^(NSDictionary *data) {
    setAsyncSpecTimeout(10);

    if (!data || !data[@"transformerClass"]) {
        XCTFail(@"No test transformer class specified.");
    }

    __block NSTask *server;
    __block Primus *primus;

    beforeEach(^AsyncBlock {
        NSString *path = [[NSBundle bundleWithIdentifier:@"com.seegno.PrimusTests"] pathForResource:data[@"server"] ofType:@"js"];
        NSNumber *pid = [[NSUserDefaults standardUserDefaults] objectForKey:@"last_pid"];

        // Kill the previous process
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"last_pid"]) {
            kill([pid intValue], SIGKILL);

            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"last_pid"];
        }

        // Launch the node server process
        server = [[NSTask alloc] init];
        server.launchPath = [[NSProcessInfo processInfo] environment][@"SHELL"];
        server.arguments = @[@"-i", @"-c", [@"node " stringByAppendingString:path]];
        server.standardOutput = [NSPipe pipe];

        [server launch];

        // Save the pid of the running process
        [[NSUserDefaults standardUserDefaults] setObject:@(server.processIdentifier) forKey:@"last_pid"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        // Read 1 byte of data (this is important so that we block until the server has started)
        [[server.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *handle) {
            done();

            NSLog(@"%@", [[NSString alloc] initWithData:handle.availableData encoding:NSUTF8StringEncoding]);
        }];
    });

    beforeEach(^{
        PrimusConnectOptions *options = [[PrimusConnectOptions alloc] initWithTransformerClass:data[@"transformer"]];

        options.manual = YES;

        primus = [[Primus alloc] initWithURL:[NSURL URLWithString:@"ws://127.0.0.1:9999"] options:options];
    });

    afterEach(^{
        expect(primus).toNot.beNil();

        [primus removeAllListeners];
        [primus end];
        primus = nil;
    });

    afterEach(^{
        expect(server).toNot.beNil();

        [server terminate];
        server = nil;
    });

    it(@"emits `incoming::open` event", ^AsyncBlock {
        [primus on:@"incoming::open" listener:^{
            done();
        }];

        [primus on:@"error" listener:^(NSError *error) {
            XCTFail(@"received error %@", error);
        }];

        [primus open];
    });

    it(@"emits `incoming::end` event", ^AsyncBlock {
        [primus on:@"incoming::end" listener:^{
            done();
        }];

        [primus on:@"incoming::open" listener:^{
            [primus end];
        }];

        [primus on:@"error" listener:^(NSError *error) {
            XCTFail(@"received error %@", error);
        }];

        [primus open];
    });

    it(@"emits `incoming::end` with `server-close` intention", ^AsyncBlock {
        [primus on:@"incoming::end" listener:^(NSString *intentional) {
            if (NO == [intentional isEqualToString:@"primus::server::close"]) {
                XCTFail(@"connection closed intentionally");
            }

            done();
        }];

        [primus on:@"error" listener:^(NSError *error) {
            XCTFail(@"received error %@", error);
        }];

        [primus emit:@"incoming::end", @"primus::server::close"];
    });

    it(@"emits `incoming::data` event", ^AsyncBlock {
        [primus on:@"incoming::data" listener:^(id data) {
            done();
        }];

        [primus on:@"error" listener:^(NSError *error) {
            XCTFail(@"received error %@", error);
        }];

        [primus open];

        [primus write:@{ @"data": @"example" }];
    });

    it(@"emits `incoming::error` event", ^AsyncBlock {
        [primus on:@"incoming::error" listener:^(id data) {
            done();
        }];

        [primus open];

        [server terminate];
    });
});

SharedExamplesEnd
