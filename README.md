# RxPusherSwift

[![CI Status](http://img.shields.io/travis/Jon Willis/RxPusherSwift.svg?style=flat)](https://travis-ci.org/Jon Willis/RxPusherSwift)
[![Version](https://img.shields.io/cocoapods/v/RxPusherSwift.svg?style=flat)](http://cocoapods.org/pods/RxPusherSwift)
[![License](https://img.shields.io/cocoapods/l/RxPusherSwift.svg?style=flat)](http://cocoapods.org/pods/RxPusherSwift)
[![Platform](https://img.shields.io/cocoapods/p/RxPusherSwift.svg?style=flat)](http://cocoapods.org/pods/RxPusherSwift)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### Binding to Connection

```swift
pusher
    .connection
    .rx_connectionState
    .map { "\($0.new)" }
    .bindTo(self.connectionStateLabel.rx_text)
    .addDisposableTo(self.disposeBag)
```

### Binding to a channel and event

```swift
pusher
    .rx_subscribe("exampleChannel")
    .flatMapLatest { channel in channel.rx_bind("exampleEvent") }
    .map { "\($0)" }
    .bindTo(self.lastMessageLabel.rx_text)
    .addDisposableTo(disposeBag)
```


## Requirements

RxSwift, RxCocoa, PusherSwift

## Installation

RxPusherSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "RxPusherSwift"
```

## Author

Jon Willis, jondwillis@gmail.com

## License

RxPusherSwift is available under the MIT license. See the LICENSE file for more info.
