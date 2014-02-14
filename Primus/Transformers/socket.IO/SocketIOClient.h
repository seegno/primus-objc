//
//  SocketIOClient.h
//  Primus
//
//  Created by Nuno Sousa on 1/8/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#if __has_include(<socket.IO/SocketIO.h>)

#import <socket.IO/SocketIO.h>
#import <socket.IO/SocketIOPacket.h>

#import "Transformer.h"

@interface SocketIOClient : Transformer<SocketIODelegate>
{
    SocketIO *_socket;
}
@end

#endif