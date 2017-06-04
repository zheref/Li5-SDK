//
//  Device.swift
//  li5
//
//  Created by Martin Cocaro on 4/6/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation
import AdSupport

open class DeviceManager : NSObject {
    
    open static let sharedInstance = DeviceManager()
    
    override fileprivate init() { }
    
    fileprivate var __deviceId: String?
    
    open var deviceId: String? {
        get {
            if (__deviceId == nil) {
                __deviceId = (self.idfa() ?? (self.idfv() ?? self.udid()))
            }
            return __deviceId
        }
        set {
            __deviceId = newValue
        }
    }
    
    fileprivate func idfa() -> String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    fileprivate func idfv() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    open func udid() -> String {
        return UUID().uuidString
    }
}
