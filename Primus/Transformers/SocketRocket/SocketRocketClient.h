//
//  SocketRocketClient.h
//  Primus
//
//  Created by Nuno Sousa on 17/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#if __has_include(<SocketRocket/SRWebSocket.h>)

#import <SocketRocket/SRWebSocket.h>

#import "Transformer.h"

@interface SocketRocketClient : Transformer<SRWebSocketDelegate>
{
    SRWebSocket *_socket;
}

@end

#endif