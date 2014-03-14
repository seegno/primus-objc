//
//  PrimusConnectOptions.h
//  Primus
//
//  Created by Nuno Sousa on 15/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusReconnectOptions.h"

@interface PrimusConnectOptions : NSObject<NSCopying>

@property (nonatomic) PrimusReconnectOptions *reconnect; // Stores the back off configuration
@property (nonatomic) NSArray *strategy;                 // Default reconnect strategies
@property (nonatomic) NSTimeInterval timeout;            // Connection timeout duration
@property (nonatomic) NSTimeInterval ping;               // Heartbeat ping interval
@property (nonatomic) NSTimeInterval pong;               // Heartbeat pong response timeout.
@property (nonatomic) BOOL autodetect;                   // Autodetect transformer and parser
@property (nonatomic) BOOL manual;                       // Manual connection
@property (nonatomic) BOOL stayConnectedInBackground;    // Stay connected while app is in background
@property (nonatomic) NSDictionary *plugins;             // Plugins to load
@property (nonatomic) Class transformerClass;            // Transformer
@property (nonatomic) Class parserClass;                 // Parser

/**
 *  Initialize the options using a custom connection strategy.
 *
 *  @param strategy An array of connection strategies.
 *
 *  @return A PrimusConnectOptions instance.
 */
- (id)initWithStrategy:(NSArray *)strategy;

/**
 *  Initialize the options using a custom transformer.
 *
 *  @param transformerClass The class object of the transformer.
 *
 *  @return A PrimusConnectOptions instance.
 */
- (id)initWithTransformerClass:(Class)transformerClass;

/**
 *  Initialize the options using a custom transformer and a custom
 *  connection strategy.
 *
 *  @param transformerClass The class object of the transformer.
 *  @param strategy         An array of connection strategies.
 *
 *  @return A PrimusConnectOptions instance.
 */
- (id)initWithTransformerClass:(Class)transformerClass andStrategy:(NSArray *)strategy;

@end
