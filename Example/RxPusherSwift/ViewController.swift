//
//  ViewController.swift
//  RxPusherSwift
//
//  Created by Jon Willis on 08/17/2016.
//  Copyright (c) 2016 Jon Willis. All rights reserved.
//

import UIKit
import PusherSwift
import RxPusherSwift
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var connectionStateLabel: UILabel!
    
    @IBOutlet weak var connectButton: UIButton!
    
    var disposeBag: DisposeBag!
    var pusher: Pusher!
    var channelObservable: Observable<PusherChannel>!
    
    @IBAction func connectAction(_ sender: AnyObject) {
        self.pusher.connect()
    }
    
    @IBAction func triggerEventAction(_ sender: AnyObject) {
        self.channelObservable
            .take(1)
            .subscribe(onNext: { $0.trigger(eventName: "exampleEvent", data: "thing") })
            .addDisposableTo(disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.disposeBag = DisposeBag()
        self.pusher =  Pusher(key: "YOUR_KEY_HERE")
        
        self.pusher
            .connection
            .rx
            .connectionState
            .map { "\($0.new)" }
            .bindTo(self.connectionStateLabel.rx.text)
            .addDisposableTo(self.disposeBag)
        
        let channelObservable = pusher
            .rx_subscribe("exampleChannel")
            .replay(1)
        
        channelObservable
            .flatMapLatest { channel in channel.rx_bind("exampleEvent") }
            .map { "\($0)" }
            .bindTo(self.lastMessageLabel.rx.text)
            .addDisposableTo(disposeBag)
        
        self.channelObservable = channelObservable.asObservable()
        channelObservable.connect().addDisposableTo(disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.disposeBag = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

