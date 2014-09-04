//
//  PrimusProtocol.h
//  Primus
//
//  Created by Nuno Sousa on 17/01/14.
//  Copyright (c) 2014 Seegno. All rights reserved.
//

#import <Emitter/Emitter.h>

#import "PrimusConnectOptions.h"
#import "PrimusReconnectOptions.h"

typedef void (^PrimusIdCallback)(NSString *socketId);

typedef NS_ENUM(int16_t, PrimusReadyState) {
    kPrimusReadyStateClosed,
    kPrimusReadyStateOpening,
    kPrimusReadyStateOpen
};

typedef BOOL (^PrimusTransformCallback)(NSMutableDictionary *data);

@protocol PrimusProtocol <NSObject>

@property (nonatomic) NSURLRequest *request;
@property (nonatomic, readonly) PrimusConnectOptions *options;

/**
 *  The init method is disabled. Please call one of the other initializers.
 */
- (id)init __unavailable;

/**
 *  Initialize a Primus instance with a URL.
 *
 *  @param url The URL to use for realtime connections.
 *
 *  @return An initialized instance.
 */
- (id)initWithURL:(NSURL *)url;

/**
 *  Initialize a Primus instance with a URL and connect options.
 *
 *  @param url     The URL to use for realtime connections.
 *  @param options The options used for establishing the connection.
 *
 *  @return An initialized instance.
 */
- (id)initWithURL:(NSURL *)url options:(PrimusConnectOptions *)options;

/**
 *  Initialize a Primus instance with a URL request.
 *  This is useful when you need to set custom HTTP headers for the connection, for example.
 *
 *  @param request The URL request.
 *
 *  @return An initialized instance.
 */
- (id)initWithURLRequest:(NSURLRequest *)request;

/**
 *  Initialize a Primus instance with a URL request and connect options.
 *  This is useful when you need to set custom HTTP headers for the connection, for example.
 *
 *  @param request The URL request.
 *  @param options The options used for establishing the connection.
 *
 *  @return An initialized instance.
 */
- (id)initWithURLRequest:(NSURLRequest *)request options:(PrimusConnectOptions *)options;

/**
 *  Open the connection.
 */
- (void)open;

/**
 *  Write a packet into the stream. This is useful for plugins and internal communications.
 *
 *  @param data An instance of NSDictionary, NSData, NSString, etc.
 *
 *  @return YES if the data was written successfully, NO otherwise.
 */
- (BOOL)write:(id)data;

/**
 * Retrieve the current id from the server.
 *
 * @param fn Callback function.
 */
- (void)id:(PrimusIdCallback)fn;

/**
 *  Closes the connection.
 */
- (void)end;

/**
 *  Closes the connection and sends one last packet of data.
 *
 *  @param data The last packet of data.
 */
- (void)end:(id)data;

/**
 *  Register a transformer on the connection.
 *
 *  For example:
 *
 *  @code
 *  [primus transform:@"incoming", ^(id packet) {
 *      packet[@"data"] = @"foo";
 *  }];
 *  @endcode
 *
 *  @param type The type of transformer (@"incoming" or @"outgoing").
 *  @param fn   A callback block.
 */
- (void)transform:(NSString *)type fn:(PrimusTransformCallback)fn;

@end
