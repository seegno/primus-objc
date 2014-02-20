Primus-Objc is an implementation of the [Primus](https://github.com/primus/primus) javascript client layer.

The library is fully unit tested using [Specta](https://github.com/specta/specta), [Expecta](https://github.com/specta/expecta) and [OCMockito](https://github.com/jonreid/OCMockito).

Currently supported transformers:

* [SocketRocket](https://github.com/square/SocketRocket)
* [socket.IO-objc](https://github.com/pkyeck/socket.IO-objc)

## Use it

```ruby
pod 'Primus'

pod 'SocketRocket'
# or pod 'socket.IO'
```

## Quick Start

```objective-c
#import <Primus/Primus.h>

- (void)start
{
    NSURL *url = [NSURL urlWithString:@"http://localhost:9090/primus"];

    Primus *primus = [[Primus alloc] initWithURL:url];

    [primus on:@"reconnect" listener:^(PrimusReconnectOptions *options) {
        NSLog(@"[%@] %@ - %@", @"reconnect", @"Reconnecting", @"We are scheduling a new reconnect attempt");
    }];

    [primus on:@"reconnect" listener:^{
        NSLog(@"[%@] %@ - %@", @"reconnect", @"Reconnect", @"Starting the reconnect attempt, hopefully we get a connection!");
    }];

    [primus on:@"online" listener:^{
        NSLog(@"[%@] %@ - %@", @"network", @"Online", @"We have regained control over our internet connection.");
    }];

    [primus on:@"offline" listener:^{
        NSLog(@"[%@] %@ - %@", @"network", @"Offline", @"We lost our internet connection.");
    }];

    [primus on:@"open" listener:^{
        NSLog(@"[%@] %@ - %@", @"open", @"Open", @"The connection has been established.");
    }];

    [primus on:@"error" listener:^(NSError *error) {
        NSLog(@"[%@] %@ - %@", @"error", @"Error", error);
    }];

    [primus on:@"data" listener:^(NSDictionary *data) {
        NSLog(@"[%@] %@ - %@", @"data", @"Received data", data);
    }];

    [primus on:@"end" listener:^{
        NSLog(@"[%@] %@ - %@", @"end", @"End", @"The connection has ended.");
    }];

    [primus on:@"close" listener:^{
        NSLog(@"[%@] %@ - %@", @"close", @"close", @"We\'ve lost the connection to the server.");
    }];
}
```
