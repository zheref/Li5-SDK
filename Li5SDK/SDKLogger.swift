//
//  SDKLogger.swift
//  li5
//
//  Created by Sergio Daniel L. García on 5/31/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

public class SDKLogger {
    
    public static let shared = SDKLogger()
    
    private init() {}
    
    public func warning(text: String) {
        log(withPrefix: ">>>>>>/! [WARNING]", text: text, andSuffix: "")
    }
    
    public func debug(text: String) {
        log(withPrefix: ">>>>>>/@ [DEBUG]", text: text, andSuffix: "")
    }
    
    public func error(text: String) {
        log(withPrefix: ">>>>>>/*", text: text, andSuffix: "")
    }
    
    public func info(text: String) {
        log(withPrefix: ">>>>>>//", text: text, andSuffix: "")
    }
    
    private func log(withPrefix prefix: String, text: String, andSuffix suffix: String) {
        print("\(prefix) \(text) \(suffix)")
    }
    
}
