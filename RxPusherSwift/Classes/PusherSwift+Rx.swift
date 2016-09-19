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

open class RxPusherConnectionStateChangeDelegateProxy: DelegateProxy,
    PusherConnectionDelegate,
DelegateProxyType {
    /**
     Typed parent object.
     */
    open weak fileprivate(set) var pusherConnection: PusherConnection?
    
    /**
     Initializes `RxScrollViewDelegateProxy`
     
     - parameter parentObject: Parent object for delegate proxy.
     */
    public required init(parentObject: AnyObject) {
        self.pusherConnection = (parentObject as! PusherConnection)
        super.init(parentObject: parentObject)
    }
    
    open class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let pusherConnection: PusherConnection = object as! PusherConnection
        return pusherConnection.delegate
    }
    
    open class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let pusherConnection: PusherConnection = object as! PusherConnection
        pusherConnection.delegate = delegate as? PusherConnectionDelegate
    }
    
    fileprivate var _connectionStateSubject: ReplaySubject<RxPusherConnectionState>?
    
    internal var connectionStateSubject: ReplaySubject<RxPusherConnectionState> {
        if _connectionStateSubject == nil {
            let subject = ReplaySubject<RxPusherConnectionState>.create(bufferSize: 1)
            _connectionStateSubject = subject
            let state = self.pusherConnection?.connectionState ?? ConnectionState.disconnected
            subject.onNext((state, new: state))
        }
        
        return _connectionStateSubject!
    }
    
    open func connectionChange(_ old: ConnectionState, new: ConnectionState) {
        _connectionStateSubject?.onNext((old: old, new: new))
        //        (self._forwardToDelegate as? ConnectionStateChangeDelegate).connectionChange(old, new: new)
    }
    
    deinit {
        if let connectionState = _connectionStateSubject {
            connectionState.onCompleted()
        }
    }
}

public extension Reactive where Base: PusherConnection {
    
    public var delegate: DelegateProxy {
        return RxPusherConnectionStateChangeDelegateProxy
            .proxyForObject(RxPusherConnectionStateChangeDelegateProxy.self)
    }
    
    public var connectionState: Observable<RxPusherConnectionState> {
        let proxy = RxPusherConnectionStateChangeDelegateProxy.proxyForObject(self as AnyObject)
        return proxy.connectionStateSubject.asObservable()
    }
}

public enum RxPusherSwiftError: Error {
    case webSocketDisconnected
}

public extension Pusher {
    
    public func rx_subscribe(_ channelName: String) -> Observable<PusherChannel> {
        return Observable.create { observer in
            let pusherChannel = self.subscribe(channelName)
            observer.onNext(pusherChannel)
            
            var dispose: DisposeBag! = DisposeBag()
            
            self
                .connection
                .rx
                .connectionState
                .filter {
                    ($0.new == ConnectionState.reconnecting || $0.new == ConnectionState.connecting)
                }
                .skip(2)
                .map { _ in RxPusherSwiftError.webSocketDisconnected }
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
    
    public func rx_bind(_ eventName: String) -> Observable<AnyObject?> {
        return Observable.create { observer in
            let callbackId = self.bind(eventName: eventName, callback: { data in
                observer.onNext(data as AnyObject?)
            })
            
            return AnonymousDisposable {
                self.unbind(eventName: eventName, callbackId: callbackId)
            }
        }
    }
    
}
