//
//  PrimusTimers.h
//  Primus
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import <GCDTimer/GCDTimer.h>

@interface PrimusTimers : NSObject

@property (nonatomic) GCDTimer *open;
@property (nonatomic) GCDTimer *heartbeat;
@property (nonatomic) GCDTimer *connect;
@property (nonatomic) GCDTimer *reconnect;

/**
 *  Invalidate all timers.
 */
- (void)invalidateAll;

/**
 *  Invalidate and release all timers.
 */
- (void)clearAll;

@end
