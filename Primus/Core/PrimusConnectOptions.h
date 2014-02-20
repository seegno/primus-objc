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
@property (nonatomic) NSDictionary *plugins;             // Plugins to load
@property (nonatomic) Class transformerClass;            // Transformer
@property (nonatomic) Class parserClass;                 // Parser

- (id)initWithStrategy:(NSArray *)strategy;

- (id)initWithTransformerClass:(Class)transformerClass;

- (id)initWithTransformerClass:(Class)transformerClass andStrategy:(NSArray *)strategy;

@end
