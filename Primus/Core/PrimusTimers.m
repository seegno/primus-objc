//
//  PrimusTimers.m
//  Primus
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusTimers.h"

@implementation PrimusTimers

- (void)invalidateAll
{
    [self.open invalidate];
    [self.heartbeat invalidate];
    [self.connect invalidate];
    [self.reconnect invalidate];
}

- (void)clearAll
{
    [self invalidateAll];

    self.open = nil;
    self.heartbeat = nil;
    self.connect = nil;
    self.reconnect = nil;
}

@end
