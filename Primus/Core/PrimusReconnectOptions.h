//
//  PrimusReconnectOptions.h
//  Primus
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

@class PrimusReconnectOptions;

typedef NS_ENUM(int16_t, PrimusReconnectionStrategy) {
    kPrimusReconnectionStrategyUnknown,
    kPrimusReconnectionStrategyTimeout,
    kPrimusReconnectionStrategyDisconnect,
    kPrimusReconnectionStrategyOnline
};

typedef void (^PrimusReconnectCallback)(NSError *error, PrimusReconnectOptions *options);

@interface PrimusReconnectOptions : NSObject<NSCopying>

@property (nonatomic) NSTimeInterval maxDelay;    // Maximum delay
@property (nonatomic) NSTimeInterval minDelay;    // Minimum delay
@property (nonatomic) NSInteger retries;          // Allowed retries
@property (nonatomic) NSInteger attempt;          // Current attempt
@property (nonatomic) NSInteger factor;           // Back off factor
@property (nonatomic) NSTimeInterval timeout;     // Back off timeout
@property (nonatomic) BOOL backoff;               // Back off decision
@property (nonatomic) BOOL authorization;         // Authorization
@property (nonatomic) NSMutableSet *strategies;   // Strategies

/**
 *  Initialize the options using a custom connection strategy.
 *
 *  @param strategy An array of connection strategies.
 *
 *  @return A PrimusReconnectOptions instance.
 */
- (id)initWithStrategy:(NSArray *)strategy;

/**
 *  Initialize the options using another instance of a reconnect options object.
 *
 *  @param options An instance of a PrimusReconnectOptions object.
 *
 *  @return A PrimusReconnectOptions instance.
 */
- (id)initWithOptions:(PrimusReconnectOptions *)options;

@end
