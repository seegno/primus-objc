//
//  SocketRocketWebSocket.h
//  Primus
//
//  Created by Nuno Sousa on 13/03/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#if __has_include(<SocketRocket/SRWebSocket.h>)

#import <SocketRocket/SRWebSocket.h>

@interface SocketRocketWebSocket : SRWebSocket

@property (nonatomic) BOOL stayConnectedInBackground;

@end

#endif