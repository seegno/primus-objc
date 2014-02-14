//
//  SocketIOClientTest.m
//  PrimusTests
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "SocketIOClient.h"

SpecBegin(SocketIOClient)

describe(@"SocketIOClient", ^{
    itShouldBehaveLike(@"a transformer", @{
        @"transformer": [SocketIOClient class],
        @"server": @"SocketIOServerTest"
    });
});

SpecEnd
