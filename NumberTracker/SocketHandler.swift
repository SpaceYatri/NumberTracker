//
//  SocketHandler.swift
//  NumberTracker
//
//  Created by Sushant Tiwari on 23/05/17.
//  Copyright © 2017 Sushant Tiwari. All rights reserved.
//

import UIKit
import SocketIO

class SocketHandler: SocketIOClient {
    
    override init(socketURL: URL, config: SocketIOClientConfiguration) {
        super.init(socketURL: socketURL, config: config)
    }
    
    convenience init(socketURL: URL, namespace: String) {
        self.init(socketURL: socketURL, config: [.log(false), .forcePolling(true)])
        joinNamespace(namespace)
        connect()
    }
    
    func getInt(forEvent event: String, _ completionBlock: @escaping (Int?) -> ()) {
        on(event) { (response, _) in
            guard let randomInt = response[0] as? Int else {
                completionBlock(nil)
                return
            }
            completionBlock(randomInt)
        }
    }
}
