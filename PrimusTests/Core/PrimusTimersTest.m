//
//  PrimusTimersTest.m
//  Primus
//
//  Created by Nuno Sousa on 11/02/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusTimers.h"

SpecBegin(PrimusTimers)

describe(@"PrimusTimers", ^{
    __block PrimusTimers *timers;

    beforeEach(^{
        timers = [[PrimusTimers alloc] init];

        timers.open = mock([NSTimer class]);
        timers.ping = mock([NSTimer class]);
        timers.pong = mock([NSTimer class]);
        timers.connect = mock([NSTimer class]);
        timers.reconnect = mock([NSTimer class]);
    });

    it(@"invalidates all timers", ^{
        [timers invalidateAll];

        [verify(timers.open) invalidate];
        [verify(timers.ping) invalidate];
        [verify(timers.pong) invalidate];
        [verify(timers.connect) invalidate];
        [verify(timers.reconnect) invalidate];
    });

    it(@"invalidates and clears all timers", ^{
        [timers clearAll];

        expect(timers.open).to.beNil();
        expect(timers.ping).to.beNil();
        expect(timers.pong).to.beNil();
        expect(timers.connect).to.beNil();
        expect(timers.reconnect).to.beNil();
    });
});

SpecEnd
