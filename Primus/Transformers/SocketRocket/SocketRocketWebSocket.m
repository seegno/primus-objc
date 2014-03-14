//
//  SocketRocketWebSocket.m
//  Primus
//
//  Created by Nuno Sousa on 13/03/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#if __has_include(<SocketRocket/SRWebSocket.h>)

#import "SocketRocketWebSocket.h"

@implementation SocketRocketWebSocket

/**
 *  Set the input/output TCP streams as VOIP streams, if applicable.
 *  This will allow us to receive data while in background mode.
 *
 *  @param aStream   The TCP stream.
 *  @param eventCode The event code.
 */
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if (self.stayConnectedInBackground) {
        [aStream setProperty:NSStreamNetworkServiceTypeVoIP forKey:NSStreamNetworkServiceType];
    } else {
        [aStream setProperty:nil forKey:NSStreamNetworkServiceType];
    }

    [super stream:aStream handleEvent:eventCode];
}

@end

#endif