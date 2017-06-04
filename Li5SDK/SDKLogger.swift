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
        log(withPrefix: ">>>>>>/! [WARNING]", text: text, andSuffix: "")
    }
    
    open func debug(_ text: String) {
        log(withPrefix: ">>>>>>/@ [DEBUG]", text: text, andSuffix: "")
    }
    
    open func error(_ text: String) {
        log(withPrefix: ">>>>>>/* [ERROR]", text: text, andSuffix: "")
    }
    
    open func info(_ text: String) {
        log(withPrefix: ">>>>>>// [INFO]", text: text, andSuffix: "")
    }
    
    fileprivate func log(withPrefix prefix: String, text: String, andSuffix suffix: String) {
        print("\(prefix) \(text) \(suffix)")
    }
    
}
