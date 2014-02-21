//
//  PrimusTimers.h
//  Primus
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

@interface PrimusTimers : NSObject

@property (nonatomic) NSTimer *open;
@property (nonatomic) NSTimer *ping;
@property (nonatomic) NSTimer *pong;
@property (nonatomic) NSTimer *connect;
@property (nonatomic) NSTimer *reconnect;

/**
 *  Invalidate all timers.
 */
- (void)invalidateAll;

/**
 *  Invalidate and release all timers.
 */
- (void)clearAll;

@end
