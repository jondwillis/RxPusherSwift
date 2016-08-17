//
//  PusherSwift+Rx.swift
//  RxPusherSwift
//
//  Created by Jon Willis on 8/16/16.
//  Copyright © 2016 Jon Willis. All rights reserved.
//

import Foundation

#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

import PusherSwift

public typealias RxPusherConnectionState = (old: ConnectionState, new: ConnectionState)

public class RxPusherConnectionStateChangeDelegateProxy: DelegateProxy,
    ConnectionStateChangeDelegate,
DelegateProxyType {
    /**
     Typed parent object.
     */
    public weak private(set) var pusherConnection: PusherConnection?
    
    /**
     Initializes `RxScrollViewDelegateProxy`
     
     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: AnyObject) {
        self.pusherConnection = (parentObject as! PusherConnection)
        super.init(parentObject: parentObject)
    }
    
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let pusherConnection: PusherConnection = object as! PusherConnection
        return pusherConnection.stateChangeDelegate
    }
    
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let pusherConnection: PusherConnection = object as! PusherConnection
        pusherConnection.stateChangeDelegate = delegate as? ConnectionStateChangeDelegate
    }
    
    private var _connectionStateSubject: ReplaySubject<RxPusherConnectionState>?
    
    internal var connectionStateSubject: ReplaySubject<RxPusherConnectionState> {
        if _connectionStateSubject == nil {
            let subject = ReplaySubject<RxPusherConnectionState>.create(bufferSize: 1)
            _connectionStateSubject = subject
            let state = self.pusherConnection?.connectionState ?? ConnectionState.Disconnected
            subject.onNext((state, new: state))
        }
        
        return _connectionStateSubject!
    }
    
    public func connectionChange(old: ConnectionState, new: ConnectionState) {
        _connectionStateSubject?.onNext((old: old, new: new))
        //        (self._forwardToDelegate as? ConnectionStateChangeDelegate).connectionChange(old, new: new)
    }
    
    deinit {
        if let connectionState = _connectionStateSubject {
            connectionState.onCompleted()
        }
    }
}

public extension PusherConnection {
    public var rx_delegate: DelegateProxy {
        return RxPusherConnectionStateChangeDelegateProxy
            .proxyForObject(RxPusherConnectionStateChangeDelegateProxy.self)
    }
    
    public var rx_connectionState: Observable<RxPusherConnectionState> {
        let proxy = RxPusherConnectionStateChangeDelegateProxy.proxyForObject(self)
        return proxy.connectionStateSubject.asObservable()
    }
}

public enum RxPusherSwiftError: ErrorType {
    case WebSocketDisconnected
}

public extension Pusher {
    
    public func rx_subscribe(channelName: String) -> Observable<PusherChannel> {
        return Observable.create { observer in
            let pusherChannel = self.subscribe(channelName)
            observer.onNext(pusherChannel)
            
            var dispose: DisposeBag! = DisposeBag()
            
            self
                .connection
                .rx_connectionState
                .filter {
                    ($0.new == ConnectionState.Reconnecting || $0.new == ConnectionState.Connecting)
                }
                .skip(2)
                .map { _ in RxPusherSwiftError.WebSocketDisconnected }
                .subscribeNext { error in observer.onError(error) }
                .addDisposableTo(dispose)
            
            return AnonymousDisposable {
                dispose = nil
                self.unsubscribe(channelName)
            }
        }
    }
}

public extension PusherChannel {
    
    public func rx_bind(eventName: String) -> Observable<AnyObject?> {
        return Observable.create { observer in
            let callbackId = self.bind(eventName, callback: { data in
                observer.onNext(data)
            })
            
            return AnonymousDisposable {
                self.unbind(eventName, callbackId: callbackId)
            }
        }
    }
    
}