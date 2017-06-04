//
//  SDKLogger.swift
//  li5
//
//  Created by Sergio Daniel L. García on 5/31/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

@objc open class SDKLogger : NSObject {
    
    open static let shared = SDKLogger()
    
    override init() {}
    
    open func warning(_ text: String) {
        log.warning(">>>>>>/! \(text)")
    }
    
    open func debug(_ text: String) {
        log.debug(">>>>>>/@ \(text)")
    }
    
    open func error(_ text: String) {
        log.error(">>>>>>/* \(text)")
    }
    
    open func info(_ text: String) {
        log.info(">>>>>>// \(text)")
    }
    
}
