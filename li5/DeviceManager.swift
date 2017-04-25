//
//  Device.swift
//  li5
//
//  Created by Martin Cocaro on 4/6/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation
import AdSupport

class DeviceManager : NSObject {
    
    static let sharedInstance = DeviceManager()
    
    override private init() { }
    
    private var __deviceId: String?
    
    var deviceId: String? {
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
    
    private func idfa() -> String {
        return ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
    }
    
    private func idfv() -> String {
        return UIDevice.currentDevice().identifierForVendor!.UUIDString
    }
    
    private func udid() -> String {
        return NSUUID().UUIDString
    }
}
