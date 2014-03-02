//
//  PrimusTransformers.m
//  Primus
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "PrimusTransformers.h"

@implementation PrimusTransformers

- (id)init
{
    self = [super init];

    if (self) {
        _incoming = [[NSMutableArray alloc] init];
        _outgoing = [[NSMutableArray alloc] init];
    }

    return self;
}

- (NSString *)mapTransformer:(NSString *)transformer
{
    return @{
        @"websockets": @"SocketRocketClient",
        @"socket.io": @"SocketIOClient"
    }[transformer];
}

@end
