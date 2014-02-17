//
//  SocketIOClient.m
//  PrimusObjc
//
//  Created by Nuno Sousa on 1/8/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#if __has_include(<socket.IO/SocketIO.h>)

#import "SocketIOClient.h"

@implementation SocketIOClient

- (void)bindEvents
{
    [_primus on:@"outgoing::open" listener:^{
        @try {
            _socket = [[SocketIO alloc] initWithDelegate:self];

            NSURL *url = _primus.request.URL;
            NSString *host = url.host;
            NSInteger port = [url.port integerValue] ?: 80;

            if (NO == [url.path isEqualToString:@""]) {
                [_socket setResourceName:[url.path substringFromIndex:1]];
            }

            [_socket connectToHost:host onPort:port];
        }
        @catch (NSException *exception) {
            [_primus emit:@"incoming::error", exception];
        }
    }];

    [_primus on:@"outgoing::data" listener:^(id data) {
        if (!_socket || !_socket.isConnected) {
            return;
        }

        @try {
            [_socket sendMessage:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        }
        @catch (NSException *exception) {
            [_primus emit:@"incoming::error", exception];
        }
    }];

    [_primus on:@"outgoing::reconnect" listener:^{
        if (_socket) {
            [_primus emit:@"outgoing::end"];
        }

        [_primus emit:@"outgoing::open"];
    }];

    [_primus on:@"outgoing::end" listener:^{
        if (!_socket) {
            return;
        }

        [_socket disconnect];
        _socket = nil;
    }];
}

- (void)socketIODidConnect:(SocketIO *)socket
{
    [_primus emit:@"incoming::open"];
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    [_primus emit:@"incoming::end"];
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    [_primus emit:@"incoming::data", packet.data];
}

- (void)socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    [_primus emit:@"incoming::data", packet.data];
}

- (void)socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    [_primus emit:@"incoming::data", packet.data];
}

- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    [_primus emit:@"incoming::error", error];
}

@end

#endif
