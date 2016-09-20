# PusherSwift (pusher-websocket-swift) (also works with Objective-C!)

[![Build Status](https://travis-ci.org/pusher/pusher-websocket-swift.svg?branch=master)](https://travis-ci.org/pusher/pusher-websocket-swift)
![Languages](https://img.shields.io/badge/languages-swift%20%7C%20objc-orange.svg)
[![Platform](https://img.shields.io/cocoapods/p/PusherSwift.svg?style=flat)](http://cocoadocs.org/docsets/PusherSwift)
[![Cocoapods Compatible](https://img.shields.io/cocoapods/v/PusherSwift.svg)](https://img.shields.io/cocoapods/v/PusherSwift.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Twitter](https://img.shields.io/badge/twitter-@Pusher-blue.svg?style=flat)](http://twitter.com/Pusher)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/pusher/pusher-websocket-swift/master/LICENSE.md)


## I just want to copy and paste some code to get me started

What else would you want? Head over to the example app [ViewController.swift](https://github.com/pusher/pusher-websocket-swift/blob/master/iOS%20Example%20Swift/iOS%20Example%20Swift/ViewController.swift) to get some code you can drop in to get started. Or if you're using Objective-C, check out [ViewController.m](https://github.com/pusher/pusher-websocket-swift/blob/master/iOS%20Example%20Obj-C/iOS%20Example%20Obj-C/ViewController.m).


## Table of Contents

* [Installation](#installation)
* [Configuration](#configuration)
* [Connection](#connection)
  * [Connection delegate](#connection-delegate)
  * [Reconnection](#reconnection)
* [Subscribing to channels](#subscribing)
* [Binding to events](#binding-to-events)
  * [Globally](#global-events)
  * [Per-channel](#per-channel-events)
  * [Receiving errors](#receiving-errors)
* [Presence channel specifics](#presence-channel-specifics)
* [Push notifications](#push-notifications)
  * [Pusher delegate](#pusher-delegate)
* [Testing](#testing)
* [Extensions](#extensions)
* [Communication](#communication)
* [Credits](#credits)
* [License](#license)


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects and is our recommended method of installing PusherSwift and its dependencies.

If you don't already have the Cocoapods gem installed, run the following command:

```bash
$ gem install cocoapods
```

To integrate PusherSwift into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

pod 'PusherSwift'
```

Then, run the following command:

```bash
$ pod install
```

If you find that you're not having the most recent version installed when you run `pod install` then try running:

```bash
$ pod cache clean
$ pod repo update PusherSwift
$ pod install
```

Also you'll need to make sure that you've not got the version of PusherSwift locked to an old version in your `Podfile.lock` file.

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PusherSwift into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "pusher/pusher-websocket-swift"
```


## Configuration

There are a number of configuration parameters which can be set for the Pusher client. For Swift usage they are:

- `authMethod (AuthMethod)` - the method you would like the client to use to authenticate subscription requests to channels requiring authentication (see below for more details)
- `attemptToReturnJSONObject (Bool)` - whether or not you'd like the library to try and parse your data as JSON (or not, and just return a string)
- `encrypted (Bool)` - whether or not you'd like to use encypted transport or not, default is `true`
- `autoReconnect (Bool)` - set whether or not you'd like the library to try and autoReconnect upon disconnection
- `host (PusherHost)` - set a custom value for the host you'd like to connect to, e.g. `PusherHost.host("ws-test.pusher.com")`
- `port (Int)` - set a custom value for the port that you'd lilke to connect to

The `authMethod` parameter must be of the type `AuthMethod`. This is an enum defined as:

#### Swift
```swift
public enum AuthMethod {
    case endpoint(authEndpoint: String)
    case authRequestBuilder(authRequestBuilder: AuthRequestBuilderProtocol)
    case inline(secret: String)
    case noMethod
}
```

- `endpoint(authEndpoint: String)` - the client will make a `POST` request to the endpoint you specify with the socket ID of the client and the channel name attempting to be subscribed to
- `authRequestBuilder(authRequestBuilder: AuthRequestBuilderProtocol)` - you specify an object that conforms to the `AuthRequestBuilderProtocol` (defined below), which must generate an `NSURLRequest` object that will be used to make the auth request
- `inline(secret: String)` - your app's secret so that authentication requests do not need to be made to your authentication endpoint and instead subscriptions can be authenticated directly inside the library (this is mainly desgined to be used for development)
- `noMethod` - if you are only using public channels then you do not need to set an `authMethod` (this is the default value)

This is the `AuthRequestBuilderProtocol` definition:

```swift
public protocol AuthRequestBuilderProtocol {
    func requestFor(socketID: String, channel: PusherChannel) -> NSMutableURLRequest?
}
```

Note that if you want to specify the cluster to which you want to connect then you use the `host` property as follows:

#### Swift
```swift
let options = PusherClientOptions(
    host: .cluster("eu")
)
```

#### Objective-C
```objc
OCAuthMethod *authMethod = [[OCAuthMethod alloc] initWithAuthEndpoint:@"https://your.authendpoint/pusher/auth"];
OCPusherHost *host = [[OCPusherHost alloc] initWithCluster:@"eu"];
PusherClientOptions *options = [[PusherClientOptions alloc]
                                initWithOcAuthMethod:authMethod
                                attemptToReturnJSONObject:YES
                                autoReconnect:YES
                                ocHost:host
                                port:nil
                                encrypted:YES];
```

All of these configuration options need to be passed to a `PusherClientOptions` object, which in turn needs to be passed to the Pusher object, when instantiating it, for example:

#### Swift
```swift
let options = PusherClientOptions(
    authMethod: .endpoint(authEndpoint: "http://localhost:9292/pusher/auth")
)

let pusher = Pusher(key: "APP_KEY", options: options)
```

#### Objective-C
```objc
OCAuthMethod *authMethod = [[OCAuthMethod alloc] initWithAuthEndpoint:@"https://your.authendpoint/pusher/auth"];
OCPusherHost *host = [[OCPusherHost alloc] initWithCluster:@"eu"];
PusherClientOptions *options = [[PusherClientOptions alloc]
                                initWithOcAuthMethod:authMethod
                                attemptToReturnJSONObject:YES
                                autoReconnect:YES
                                ocHost:host
                                port:nil
                                encrypted:YES];
pusher = [[Pusher alloc] initWithAppKey:@"YOUR_APP_KEY" options:options];
```

As you may have noticed, this differs slightly for Objective-C usage. The main changes are that you need to use `OCAuthMethod` and `OCPusherHost` in place of `AuthMethod` and `PusherHost`. The `OCAuthMethod` class has the following functions that you can call in your Objective-C code.

```swift
public init(authEndpoint: String)

public init(authRequestBuilder: AuthRequestBuilderProtocol)

public init(secret: String)

public init()
```

```objc
OCAuthMethod *authMethod = [[OCAuthMethod alloc] initWithSecret:@"YOUR_APP_SECRET"];
PusherClientOptions *options = [[PusherClientOptions alloc] initWithAuthMethod:authMethod];
```

The case is similar for `OCPusherHost`. You have the following functions available:

```objc
public init(host: String)

public init(cluster: String)
```

```objc
[[OCPusherHost alloc] initWithCluster:@"YOUR_CLUSTER_SHORTCODE"];
```

Authenticated channel example:

#### Swift
```swift
class AuthRequestBuilder: AuthRequestBuilderProtocol {
    func requestFor(socketID: String, channel: PusherChannel) -> NSMutableURLRequest? {
        let request = NSMutableURLRequest(url: URL(string: "http://localhost:9292/builder")!)
        request.httpMethod = "POST"
        request.httpBody = "socket_id=\(socketID)&channel_name=\(channel.name)".data(using: String.Encoding.utf8)
        request.addValue("myToken", forHTTPHeaderField: "Authorization")
        return request
    }
}

let options = PusherClientOptions(
    authMethod: AuthMethod.authRequestBuilder(authRequestBuilder: AuthRequestBuilder())
)
let pusher = Pusher(
  key: "APP_KEY",
  options: options
)
```

#### Objective-C
```objc
@interface AuthRequestBuilder : NSObject <AuthRequestBuilderProtocol>

- (NSMutableURLRequest*)requestForSocketID:(NSString *)socketID channel:(PusherChannel *)channel;

@end

@implementation AuthRequestBuilder

- (NSMutableURLRequest*)requestForSocketID:(NSString *)socketID channel:(PusherChannel *)channel {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [[NSURL alloc] initWithString:@"http://localhost:9292/builder"]];
    NSString *dataStr = [NSString stringWithFormat: @"socket_id=%@&channel_name=%@", socketID, [channel name]];
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    request.HTTPMethod = @"POST";
    [request addValue:@"myToken" forHTTPHeaderField:@"Authorization"];
    return request;
}

@end

OCAuthMethod *authMethod = [[OCAuthMethod alloc] initWithAuthRequestBuilder:[[AuthRequestBuilder alloc] init]];
PusherClientOptions *options = [[PusherClientOptions alloc] initWithAuthMethod:authMethod];
```

Where `"Authorization"` and `"myToken"` are the field and value your server is expecting in the headers of the request.

## Connection

A Websocket connection is established by providing your API key to the constructor function:

#### Swift
```swift
let pusher = Pusher(key: "APP_KEY")
pusher.connect()
```

#### Objective-C
```objc
Pusher *pusher = [[Pusher alloc] initWithAppKey:@"YOUR_APP_KEY"];
[pusher connect];
```

This returns a client object which can then be used to subscribe to channels and then calling `connect()` triggers the connection process to start.

You can also set a `userDataFetcher` on the connection object.

- `userDataFetcher (() -> PusherPresenceChannelMember)` - if you are subscribing to an authenticated channel and wish to provide a function to return user data

You set it like this:

#### Swift
```swift
let pusher = Pusher(key: "APP_KEY")

pusher.connection.userDataFetcher = { () -> PusherPresenceChannelMember in
    return PusherPresenceChannelMember(userId: "123", userInfo: ["twitter": "hamchapman"])
}
```

#### Objective-C
```objc
Pusher *pusher = [[Pusher alloc] initWithAppKey:@"YOUR_APP_KEY"];

pusher.connection.userDataFetcher = ^PusherPresenceChannelMember* () {
    NSString *uuid = [[NSUUID UUID] UUIDString];
    return [[PusherPresenceChannelMember alloc] initWithUserId:uuid userInfo:nil];
};
```

### Connection delegate

There is a `PusherConnectionDelegate` that you can use to get access to connection-related information. These are the functions that you can optionally implement when conforming to the `PusherConnectionDelegate` protocol:

```swift
@objc optional func connectionStateDidChange(from old: ConnectionState, to new: ConnectionState)
@objc optional func debugLog(message: String)
@objc optional func subscriptionDidSucceed(channelName: String)
@objc optional func subscriptionDidFail(channelName: String, response: URLResponse?, data: String?, error: NSError?)
```

The names of the functions largely give away what their purpose is but just for completeness:

- `connectionStateDidChange` - use this if you want to use connection state changes to perform different actions / UI updates
- `debugLog` - use this if you want to log Pusher-related events, e.g. the underlying websocket receiving a message
- `subscriptionDidSucceed` - use this if you want to be informed of when a channel has successfully been subscribed to, which is useful if you want to perform actions that are only relevant after a subscription has succeeded, e.g. logging out the members of a presence channel
- `subscriptionDidFail` - use this if you want to be informed of a failed subscription attempt, which you could use, for exampple, to then attempt another subscription or make a call to a service you use to track errors

Setting up a delegate looks like this:

#### Swift
```swift
class ViewController: UIViewController, PusherConnectionDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let pusher = Pusher(key: "APP_KEY")
        pusher.connection.delegate = self
        // ...
    }
}
```

#### Objective-C
```objc
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.client = [[Pusher alloc] initWithAppKey:@"YOUR_APP_KEY"];

    self.client.connection.delegate = self;
    // ...
}
```

Here are examples of setting up a class with functions for each of the optional protocol functions:

#### Swift
```swift
class DummyDelegate: PusherConnectionDelegate {
    func connectionStateDidChange(from old: ConnectionState, to new: ConnectionState) {
        // ...
    }

    func debugLog(message: String) {
        // ...
    }

    func subscriptionDidSucceed(channelName: String) {
        // ...
    }

    func subscriptionDidFail(channelName: String, response: URLResponse?, data: String?, error: NSError?) {
        // ...
    }
}
```

#### Objective-C
```objc
@interface DummyDelegate : NSObject <PusherConnectionDelegate>

- (void)connectionStateDidChangeFrom:(enum ConnectionState)old to:(enum ConnectionState)new_
- (void)debugLogWithMessage:(NSString *)message
- (void)subscriptionDidSucceedWithChannelName:(NSString *)channelName
- (void)subscriptionDidFailWithChannelName:(NSString *)channelName response:(NSURLResponse *)response data:(NSString *)data error:(NSError *)error

@end

@implementation DummyDelegate

- (void)connectionStateDidChangeFrom:(enum ConnectionState)old to:(enum ConnectionState)new_ {
    // ...
}

- (void)debugLogWithMessage:(NSString *)message {
    // ...
}

- (void)subscriptionDidSucceedWithChannelName:(NSString *)channelName {
    // ...
}

- (void)subscriptionDidFailWithChannelName:(NSString *)channelName response:(NSURLResponse *)response data:(NSString *)data error:(NSError *)error {
    // ...
}

@end
```

The different states that the connection can be in are (Objective-C integer enum cases in brackets):

* `connecting (0)` - the connection is about to attempt to be made
* `connected (1)` - the connection has been successfully made
* `disconnecting (2)` - the connection has been instructed to disconnect and it is just about to do so
* `disconnected (3)` - the connection has disconnected and no attempt will be made to reconnect automatically
* `reconnecting (4)` - an attempt is going to be made to try and re-establish the connection
* `reconnectingWhenNetworkBecomesReachable (5)` - when the network becomes reachable an attempt will be made to reconnect

There is a `stringValue` function that you can call on `ConnectionState` objects in order to get a `String` representation of the state, for example `"connecting"`.


### Reconnection

There are three main ways in which a disconnection can occur:

  * The client explicitly calls disconnect and a close frame is sent over the websocket connection
  * The client experiences some form of network degradation which leads to a heartbeat (ping/pong) message being missed and thus the client disconnects
  * The Pusher server closes the websocket connection; typically this will only occur during a restart of the Pusher socket servers and an almost immediate reconnection should occur

In the case of the first type of disconnection the library will (as you'd hope) not attempt a reconnection.

If there is network degradation that leads to a disconnection then the library has the [Reachability](https://github.com/ashleymills/Reachability.swift) library embedded and will be able to automatically determine when to attempt a reconnect based on the changing network conditions.

If the Pusher servers close the websocket then the library will attempt to reconnect (by default) a maximum of 6 times, with an exponential backoff. The value of `reconnectAttemptsMax` is a public property on the `PusherConnection` and so can be changed if you wish.

All of this is the case if you have the client option of `autoReconnect` set as `true`, which it is by default. If the reconnection strategies are not suitable for your use case then you can set `autoReconnect` to `false` and implement your own reconnection strategy based on the connection state changes.

There are a couple of properties on the connection (`PusherConnection`) that you can set that affect how the reconnection behaviour works. These are:

* `public var reconnectAttemptsMax: Int? = 6` - if you set this to `nil` then there is no maximum number of reconnect attempts and so attempts will continue to be made with an exponential backoff (based on number of attempts), otherwise only as many attempts as this property's value will be made before the connection's state moves to `.disconnected`
* `public var maxReconnectGapInSeconds: Double? = nil` - if you want to set a maximum length of time (in seconds) between reconnect attempts then set this property appropriately

Note that the number of reconnect attempts gets reset to 0 as soon as a successful connection is made.

## Subscribing

### Public channels

The default method for subscribing to a channel involves invoking the `subscribe` method of your client object:

#### Swift
```swift
let myChannel = pusher.subscribe("my-channel")
```

#### Objective-C
```objc
PusherChannel *myChannel = [pusher subscribeWithChannelName:@"my-channel"];
```

This returns PusherChannel object, which events can be bound to.

### Private channels

Private channels are created in exactly the same way as public channels, except that they reside in the 'private-' namespace. This means prefixing the channel name:

#### Swift
```swift
let myPrivateChannel = pusher.subscribe("private-my-channel")
```

#### Objective-C
```objc
PusherChannel *myPrivateChannel = [pusher subscribeWithChannelName:@"private-my-channel"];
```

### Presence channels

Presence channels are created in exactly the same way as private channels, except that they reside in the 'presence-' namespace.

#### Swift
```swift
let myPresenceChannel = pusher.subscribe("presence-my-channel")
```

#### Objective-C
```objc
PusherChannel *myPresenceChannel = [pusher subscribeWithChannelName:@"presence-my-channel"];
```

This will give you back a `PusherChannel` object, which will not have access to functions available to `PusherPresenceChannel` objects, such as `members`, `me` etc.

You can of course cast the `PusherChannel` object to a `PusherPresenceChannel` or you can instead use the `subscribeToPresenceChannel` function which will directly return a `PusherPresenceChannel` object. You can do so like this:

#### Swift
```swift
let myPresenceChannel = pusher.subscribeToPresenceChannel(channelName: "presence-my-channel")
```

#### Objective-C
```objc
PusherPresenceChannel *myPresenceChannel = [pusher subscribeToPresenceChannelWithChannelName:@"presence-my-channel"];
```

You can also provide functions that will be called when members are either added to or removed from the channel. These are available as parameters to both `subscribe` and `subscribeToPresenceChannel`.

#### Swift
```swift
let onMemberChange = { (member: PusherPresenceChannelMember) in
    print(member)
}
let chan = pusher.subscribe("presence-channel", onMemberAdded: onMemberChange, onMemberRemoved: onMemberChange)
```

Note that both private and presence channels require the user to be authenticated in order to subscribe to the channel. This authentication can either happen inside the library, if you configured your Pusher object with your app's secret, or an authentication request is made to an authentication endpoint that you provide, again when instantiaing your Pusher object.

We recommend that you use an authentication endpoint over including your app's secret in your app in the vast majority of use cases. If you are completely certain that there's no risk to you including your app's secret in your app, for example if your app is just for internal use at your company, then it can make things easier than setting up an authentication endpoint.

## Binding to events

Events can be bound to at 2 levels; globally and per channel. When binding to an event you can choose to save the return value, which is a unique identifier for the event handler that gets created. The only reason to save this is if you're going to want to unbind from the event at a later point in time. There is an example of this below.

### Global events

You can attach behaviour to these events regardless of the channel the event is broadcast to. The following is an example of an app that binds to new comments from any channel:

#### Swift
```swift
let pusher = Pusher(key: "YOUR_APP_KEY")
pusher.subscribe("my-channel")

pusher.bind(callback: { (data: AnyObject?) -> Void in
    if let data = data as? [String : AnyObject] {
        if let commenter = data["commenter"] as? String, message = data["message"] as? String {
            print("\(commenter) wrote \(message)")
        }
    }
})
```

#### Objective-C
```objc
Pusher *pusher = [[Pusher alloc] initWithAppKey:@"YOUR_APP_KEY"];
PusherChannel *chan = [pusher subscribeWithChannelName:@"my-channel"];

[pusher bind: ^void (NSDictionary *data) {
    NSString *commenter = data[@"commenter"];
    NSString *message = data[@"message"];

    NSLog(@"%@ wrote %@", commenter, message);
}];
```

### Per-channel events

These are bound to a specific channel, and mean that you can reuse event names in different parts of your client application. The following might be an example of a stock tracking app where several channels are opened for different companies:

#### Swift
```swift
let pusher = Pusher(key: "YOUR_APP_KEY")
let myChannel = pusher.subscribe("my-channel")

myChannel.bind(eventName: "new-price", callback: { (data: AnyObject?) -> Void in
    if let data = data as? [String : AnyObject] {
        if let price = data["price"] as? String, company = data["company"] as? String {
            print("\(company) is now priced at \(price)")
        }
    }
})
```

#### Objective-C
```objc
Pusher *pusher = [[Pusher alloc] initWithAppKey:@"YOUR_APP_KEY"];
PusherChannel *chan = [pusher subscribeWithChannelName:@"my-channel"];

[chan bindWithEventName:@"new-price" callback:^void (NSDictionary *data) {
    NSString *price = data[@"price"];
    NSString *company = data[@"company"];

    NSLog(@"%@ is now priced at %@", company, price);
}];
```

### Receiving errors

Errors are sent to the client for which they are relevant with an event name of `pusher:error`. These can be received and handled using code as follows. Obviously the specifics of how to handle them are left up to the developer but this displays the general pattern.

#### Swift
```swift
pusher.bind({ (message: AnyObject?) in
    if let message = message as? [String: AnyObject], eventName = message["event"] as? String where eventName == "pusher:error" {
        if let data = message["data"] as? [String: AnyObject], errorMessage = data["message"] as? String {
            print("Error message: \(errorMessage)")
        }
    }
})
```

#### Objective-C
```objc
[pusher bind:^void (NSDictionary *data) {
    NSString *eventName = data[@"event"];

    if ([eventName isEqualToString:@"pusher:error"]) {
        NSString *errorMessage = data[@"data"][@"message"];
        NSLog(@"Error message: %@", errorMessage);
    }
}];
```


The sort of errors you might get are:

```bash
# if attempting to subscribe to an already subscribed-to channel

"{\"event\":\"pusher:error\",\"data\":{\"code\":null,\"message\":\"Existing subscription to channel presence-channel\"}}"

# if the auth signature generated by your auth mechanism is invalid

"{\"event\":\"pusher:error\",\"data\":{\"code\":null,\"message\":\"Invalid signature: Expected HMAC SHA256 hex digest of 200557.5043858:presence-channel:{\\\"user_id\\\":\\\"200557.5043858\\\"}, but got 8372e1649cf5a45a2de3cd97fe11d85de80b214243e3a9e9f5cee502fa03f880\"}}"
```

You can see that the general form they take is:

```bash
{
  "event": "pusher:error",
  "data": {
    "code": null,
    "message": "Error message here"
  }
}
```


### Unbind event handlers

You can remove previously-bound handlers from an object by using the `unbind` function. For example,

#### Swift
```swift
let pusher = Pusher(key: "YOUR_APP_KEY")
let myChannel = pusher.subscribe("my-channel")

let eventHandlerId = myChannel.bind(eventName: "new-price", callback: { (data: AnyObject?) -> Void in
  ...
})

myChannel.unbind(eventName: "new-price", callbackId: eventHandlerId)
```

#### Objective-C
```objc
Pusher *pusher = [[Pusher alloc] initWithAppKey:@"YOUR_APP_KEY"];
PusherChannel *chan = [pusher subscribeWithChannelName:@"my-channel"];

NSString *callbackId = [chan bindWithEventName:@"new-price" callback:^void (NSDictionary *data) {
    ...
}];

[chan unbindWithEventName:@"new-price" callbackId:callbackId];
```

You can unbind from events at both the global and per channel level. For both objects you also have the option of calling `unbindAll`, which, as you can guess, will unbind all eventHandlers on the object.


## Presence channel specifics

Presence channels have some extra properties and functions available to them. In particular you can access the members who are subscribed to the channel by calling `members` on the channel object, as below.

#### Swift
```swift
let chan = pusher.subscribe("presence-channel")

print(chan.members)
```

#### Objective-C
```objc
PusherPresenceChannel *presChanExplicit = [pusher subscribeToPresenceChannelWithChannelName:@"presence-explicit"];

NSArray *members = [presChanExplicit members];
```

You can also search for specific members in the channel by calling `findMember` and providing it with a user id string.

#### Swift
```swift
let chan = pusher.subscribe("presence-channel")
let member = chan.findMember(userId: "12345")

print(member)
```

#### Objective-C
```objc
PusherPresenceChannel *presChanExplicit = [pusher subscribeToPresenceChannelWithChannelName:@"presence-explicit"];

PusherPresenceChannelMember *me = [presChanExplicit findMemberWithUserId:@"12345"];
```

As a special case of `findMember` you can call `me` on the channel to get the member object of the subscribed client.

#### Swift
```swift
let chan = pusher.subscribeToPresenceChannel(channelName: "presence-channel")
let me = chan.me()

print(me)
```

#### Objective-C
```objc
PusherPresenceChannel *presChanExplicit = [pusher subscribeToPresenceChannelWithChannelName:@"presence-explicit"];

PusherPresenceChannelMember *me = [presChanExplicit me];
```


## Push notifications

Pusher also supports push notifications. Instances of your application can register for push notifications and subscribe to "interests". Your server can then publish to those interests, which will be delivered to your application as push notifications. See [our guide to setting up push notifications for iOS](https://pusher.com/docs/push_notifications/ios) for a friendly introduction.

You should set up your app for push notifications in your `AppDelegate`. Start off your app in the usual way:

#### Swift
```swift
import PusherSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let pusher = Pusher(key: "YOUR_APP_KEY")
    ...
```

#### Objective-C
```objc
#import "AppDelegate.h"
@import UserNotifications;

@interface AppDelegate ()

@end

@implementation AppDelegate
...
```

For your app to receive push notifications, it must first register with APNs. You should do this when the application finishes launching. Your app should register for all types of notification, like so:

#### Swift
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
        // Enable or disable features based on authorization.
    }
    application.registerForRemoteNotifications()

    return true
}
```

#### Objective-C
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.pusher = [[Pusher alloc] initWithKey:@"YOUR_APP_KEY"];

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // Enable or disable features based on authorization.
    }];

    [application registerForRemoteNotifications];
    return YES;
}
```

Next, APNs will respond with a device token identifying your app instance. Your app should then register with Pusher, passing along its device token.

Your app can now subscribe to interests. The following registers and subscribes the app to the interest "donuts":

#### Swift
```swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    pusher.nativePusher().register(deviceToken: deviceToken)
    pusher.nativePusher().subscribe(interestName: "donuts")
}
```

#### Objective-C
```objc
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Registered for remote notifications; received device token");
    [[[self pusher] nativePusher] registerWithDeviceToken:deviceToken];
    [[[self pusher] nativePusher] subscribeWithInterestName:@"donuts"];
}
```


When your server publishes a notification to the interest "donuts", it will get passed to your app. This happens as a call in your `AppDelegate` which you should listen to:

#### Swift
```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    print(userInfo)
}
```

#### Objective-C
```objc
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Received remote notification: %@", userInfo);
}
```

If at a later point you wish to unsubscribe from an interest, this works in the same way:

#### Swift
```swift
pusher.nativePusher().unsubscribe(interestName: "donuts")
```

#### Objective-C
```objc
[[[self pusher] nativePusher] unsubscribeWithInterestName:@"donuts"];
```

For a complete example of a working app, see the [Example/](https://github.com/pusher/pusher-websocket-swift/tree/push-notifications/Example) directory in this repository. Specifically for push notifications code, see the [Example/AppDelegate.swift](https://github.com/pusher/pusher-websocket-swift/blob/master/iOS%20Example%20Swift/iOS%20Example%20Swift/AppDelegate.swift) file.


### Pusher delegate

There is a `PusherDelegate` that you can use to get access to events that occur in relation to push notifications interactions. These are the functions that you can optionally implement when conforming to the `PusherDelegate` protocol:

```swift
@objc optional func didRegisterForPushNotifications(clientId: String)
@objc optional func didSubscribeToInterest(named name: String)
@objc optional func didUnsubscribeFromInterest(named name: String)
```

Again, the names of the functions largely give away what their purpose is but just for completeness:

- `didRegisterForPushNotifications` - use this if you want to know when a client has successfully registered with the Pusher Push Notifications service, or if you want access to the `clientId` that is returned upon successful registration
- `didSubscribeToInterest` - use this if you want keep track of interests that are successfully subscribed to
- `didUnsubscribeFromInterest` - use this if you want keep track of interests that are successfully unsubscribed from

Setting up a delegate looks like this:

#### Swift
```swift
class ViewController: UIViewController, PusherDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let pusher = Pusher(key: "APP_KEY")
        pusher.delegate = self
        // ...
    }
}
```

#### Objective-C
```objc
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.client = [[Pusher alloc] initWithAppKey:@"YOUR_APP_KEY"];

    self.client.delegate = self;
    // ...
}
```

The process is identical to that of setting up a `PusherConnectionDelegate`. At some point in the future the `PusherDelegate` and `PusherConnectionDelegate` will likely be merged into the `PusherDelegate` in order to provide one unified delegate that can be used to get notified of Pusher-related events.


## Testing

There are a set of tests for the library that can be run using the standard method (Command-U in Xcode).

The tests also get run on [Travis-CI](https://travis-ci.org/pusher/pusher-websocket-swift). See [.travis.yml](https://github.com/pusher/pusher-websocket-swift/blob/master/.travis.yml) for details on how the Travis tests are run.


## Extensions

* [RxPusherSwift](https://github.com/jondwillis/RxPusherSwift)


## Communication

- If you have found a bug, please open an issue.
- If you have a feature request, please open an issue.
- If you want to contribute, please submit a pull request (preferrably with some tests :) ).


## Credits

PusherSwift is owned and maintained by [Pusher](https://pusher.com). It was originally created by [Hamilton Chapman](https://github.com/hamchapman).

It uses code from the following repositories:

* [CryptoSwift](https://github.com/krzyzanowskim/CryptoSwift)
* [Reachability.swift](https://github.com/ashleymills/Reachability.swift)
* [Starscream](https://github.com/daltoniam/Starscream)

The individual licenses for these libraries are included in the corresponding Swift files.


## License

PusherSwift is released under the MIT license. See [LICENSE](https://github.com/pusher/pusher-websocket-swift/blob/master/LICENSE.md) for details.
