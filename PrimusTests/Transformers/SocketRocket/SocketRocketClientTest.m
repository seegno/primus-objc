//
//  SocketRocketClientTest.m
//  PrimusTests
//
//  Created by Nuno Sousa on 14/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import "SocketRocketClient.h"

SpecBegin(SocketRocketClient)

describe(@"SocketRocketClient", ^{
    itShouldBehaveLike(@"a transformer", @{
        @"transformer": [SocketRocketClient class],
        @"server": @"SocketRocketServerTest"
    });
});

SpecEnd
