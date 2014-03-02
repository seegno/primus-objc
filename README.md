# Primus-Objc

Primus-Objc is an implementation of the [Primus](https://github.com/primus/primus) javascript client layer.

The library is fully unit tested using [Specta](https://github.com/specta/specta), [Expecta](https://github.com/specta/expecta) and [OCMockito](https://github.com/jonreid/OCMockito).

Currently supported real-time frameworks:

* [SocketRocket](https://github.com/square/SocketRocket)
* [socket.IO-objc](https://github.com/pkyeck/socket.IO-objc)

## Installation

```ruby
pod 'Primus'

pod 'SocketRocket'
# or pod 'socket.IO'
```

## Table of Contents

- [Introduction](#primus-objc)
- [Installation](#installation)
- [Getting Started](#getting-started)
- [Connecting](#connecting)
- [Authorization](#authorization)
- [Broadcasting](#broadcasting)
- [Disconnecting](#disconnecting)
- [Events](#events)
- [Heartbeats and latency](#heartbeats-and-latency)
- [Plugins](#plugins)
  - [Transforming and intercepting messages](#transforming-and-intercepting-messages)
  - [Community Plugins](#community-plugins)
- [Tests](#tests)
- [License](#license)

## Getting Started

Here is a quick example of establishing a connection to a Primus server and listening on the various events we emit.

Since we haven't specified a transformer, Primus will connect to then `/spec` [endpoint](https://github.com/primus/primus#connecting-from-the-server) and attempt to determine the appropriate real-time framework.

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

    [primus on:@"data" listener:^(NSDictionary *data, id raw) {
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

Primus can also be initialized with an NSURLRequest class, so that you can add your own HTTP headers, for example:

```objective-c
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:9090/primus"]];
    
    [request setValue:@"Bearer <your-oauth-token-here>" forHTTPHeaderField:@"Authorization"];
    
    Primus *primus = [[Primus alloc] initWithURLRequest:request];
```

Further customization can also be achieved by passing an instance of a PrimusConnectOptions object:

```objective-c
    NSURL *url = [NSURL URLWithString:@"http://localhost:9090/primus"];
    
    PrimusConnectOptions *options = [[PrimusConnectOptions alloc] init];
    
    options.transformerClass = SocketRocketClient.class;
    options.strategy = @[@(kPrimusReconnectionStrategyTimeout)];
    options.timeout = 200;
    options.manual = YES;
    
    Primus *primus = [[Primus alloc] initWithURL:url options:options];
```

## Connecting

When you initialize a Primus instance with the default options, it will automatically connect. This is done for compatibility with the original Primus library.

However, if you'd prefer to connect manually, you must pass a custom PrimusConnectOptions to the initializer and call the `open` method:

```objective-c
    NSURL *url = [NSURL URLWithString:@"http://localhost:9090/primus"];
    
    PrimusConnectOptions *options = [[PrimusConnectOptions alloc] init];
    
    options.manual = YES;
    
    Primus *primus = [[Primus alloc] initWithURL:url options:options];
    
    // Calling 'open' will start the connection
    [primus open];
```

The `open` event will be emitted when the connection is successfully established.

## Authorization

If you have made use of the server-side [authorization hook](https://github.com/primus/primus#authorization), Primus will emit an `error` event if it fails authorization.

You can then retrieve the error code as per your authorization logic.

## Broadcasting

Broadcasting allows you to write a message to the server. You can currently broadcast instances of `NSDictionary`, `NSString` or `NSData`.

```objective-c
[primus write:@{
	@"my-data": @(123)
}];

[primus write:@"example-data"];
```

## Disconnecting

You can easily disconnect from the server by calling the `end` method. Primus will also emit an `end` event when it has successfully disconnected.

[primus end];

## Events

Primus is build upon the EventEmitter pattern using the [Emitter](https://github.com/seegno/emitter-objc) library. This is a summary of the events emitted by Primus.

Event                 | Usage      | Location | Description
----------------------|------------|----------|----------------------------------------
`reconnecting`        | **public** | client   | We're scheduling a reconnect.
`reconnect`           | **public** | client   | Reconnect attempt is about to be made.
`outgoing::open`      | private    | client   | Transformer should connect.
`incoming::open`      | private    | client   | Transformer has connected.
`open`                | **public** | client   | Connection is open.
`incoming::error`     | private    | client   | Transformer received error.
`error`               | **public** | client   | An error happened.
`incoming::data`      | private    | client   | Transformer received data.
`outgoing::data`      | private    | client   | Transformer should write data.
`data`                | **public** | client   | We received data.
`incoming::end`       | private    | client   | Transformer closed the connection.
`outgoing::end`       | private    | client   | Transformer should close connection.
`end`                 | **public** | client   | Primus has ended.
`close`               | **public** | client   | The underlaying connection is closed, we might retry.
`initialised`         | **public** | client   | The server is initialised.
`incoming::pong`      | private    | client   | We received a pong message.
`outgoing::ping`      | private    | client   | We're sending a ping message.
`online`              | **public** | client   | We've regained a network connection
`offline`             | **public** | client   | We've lost our internet connection

## Heartbeats and latency

The Primus heartbeat mechanism has been implemented as described in the [original framework](https://github.com/primus/primus#heartbeats-and-latency).

## Plugins

The Primus javascript framework [allows for plugins](https://github.com/primus/primus#plugins) on the server-side.

Primus-Objc also supports client-side plugins as well as message transformers.

### Transforming And Intercepting Messages

You can intercept and transform `incoming` or `outgoing` data by registering a transform block:

```objective-c
    [self transform:@"incoming" fn:^BOOL(NSMutableDictionary *data) {
        data[@"foo"] = @"bar";
        
        return YES;
    }];
```

You can also prevent the `data` event from being emitted by returning `NO` on the transformer block. This will effectively discard the message.

### Community Plugins

These are plugins created by our community. If you created a module, please submit a pull request and add it to this section.

***[primus-emitter-objc](https://github.com/seegno/primus-emitter-objc)***

&nbsp;&nbsp;&nbsp;&nbsp;A module that adds emitter capabilities to Primus.

## Tests

Most of the functionality is covered by tests. For the real-time clients, we start up a small node server with the respective real-time frameworks and test against them.

Before running the tests, please run:

```
pod install
npm install
```

You can then open the project with XCode and choose Product → Test (⌘U).

## License

MIT