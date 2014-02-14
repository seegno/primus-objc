//
//  PrimusProtocol.h
//  Primus
//
//  Created by Nuno Sousa on 17/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import <Emitter/Emitter.h>

#define recursiveBlock(outerBlock, innerBlock) void (^outerBlock)(); __block void (^block)() = outerBlock; innerBlock(block);

@protocol PrimusProtocol <NSObject>

@property (nonatomic) NSURLRequest *request;

@end
