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

- (id)initWithPrimus:(id<PrimusProtocol>)primus
{
    self = [super initWithPrimus:primus];

    if (self) {
        [_primus on:@"outgoing::open" selector:@selector(onOutgoingOpen) target:self];
        [_primus on:@"outgoing::data" selector:@selector(onOutgoingData:) target:self];
        [_primus on:@"outgoing::reconnect" selector:@selector(onOutgoingReconnect) target:self];
        [_primus on:@"outgoing::end" selector:@selector(onOutgoingEnd) target:self];
    }

    return self;
}

- (void)dealloc
{
    [_primus removeListener:@"outgoing::open" selector:@selector(onOutgoingOpen) target:self];
    [_primus removeListener:@"outgoing::data" selector:@selector(onOutgoingData:) target:self];
    [_primus removeListener:@"outgoing::reconnect" selector:@selector(onOutgoingReconnect) target:self];
    [_primus removeListener:@"outgoing::end" selector:@selector(onOutgoingEnd) target:self];

    _socket = nil;
}

#pragma mark - Event listeners

- (void)onOutgoingOpen
{
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
}

- (void)onOutgoingData:(id)data
{
    if (!_socket || !_socket.isConnected) {
        return;
    }

    @try {
        [_socket sendMessage:data];
    }
    @catch (NSException *exception) {
        [_primus emit:@"incoming::error", exception];
    }
}

- (void)onOutgoingReconnect
{
    if (_socket) {
        [_primus emit:@"outgoing::end"];
    }

    [_primus emit:@"outgoing::open"];
}

- (void)onOutgoingEnd
{
    if (!_socket) {
        return;
    }

    [_socket disconnect];
}

#pragma mark - Transformer methods

- (NSString *)id
{
    return _socket.sid;
}

#pragma mark - SocketIODelegate

- (void)socketIODidConnect:(SocketIO *)socket
{
    if (_socket != socket) {
        return;
    }

    [_primus emit:@"incoming::open"];
}

- (void)socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
    if (_socket != socket) {
        return;
    }

    [_primus emit:@"incoming::end", nil];
}

- (void)socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    if (_socket != socket) {
        return;
    }

    [_primus emit:@"incoming::data", packet.data];
}

- (void)socketIO:(SocketIO *)socket didReceiveJSON:(SocketIOPacket *)packet
{
    if (_socket != socket) {
        return;
    }

    [_primus emit:@"incoming::data", packet.data];
}

- (void)socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    if (_socket != socket) {
        return;
    }

    [_primus emit:@"incoming::data", packet.data];
}

- (void)socketIO:(SocketIO *)socket onError:(NSError *)error
{
    if (_socket != socket) {
        return;
    }

    [_primus emit:@"incoming::error", error];

    if (!_socket.isConnected) {
        [_primus emit:@"incoming::end", nil];
    }
}

@end

#endif
