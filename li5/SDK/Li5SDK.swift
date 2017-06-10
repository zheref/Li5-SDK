//
//  Li5SDK.swift
//  li5
//
//  Created by Sergio Daniel L. García on 4/28/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import AVFoundation

import SwiftyBeaver
let log = SwiftyBeaver.self

typealias ErrorReturner = (Error) -> Void

open class Li5SDK {
    
    var primetimeViewController: PrimeTimeViewController!
    var primetimeDataSource: PrimeTimeViewControllerDataSource!
    
    fileprivate init() {}
    
    
    open static var shared: Li5SDK = {
        return Li5SDK()
    }()
    
    
    open func config(apiKey: String, forApp appId: String) {
        configLogger()
        
        log.info("Setting up Li5 SDK")
        
        let serverUrl = "https://api-testing.li5.tv/v1"
        
        Li5ApiHandler.sharedInstance().baseURL = serverUrl
        
        Li5ApiHandler.sharedInstance().login(DeviceManager.sharedInstance.deviceId,
                                             withApiKey: apiKey) { nserror in
            
            if let errorString = nserror != nil ? nserror?.localizedDescription : "0" {
                log.debug("Logged in with result: \(errorString)")
            }
        }
    }
    
    
    private func configLogger() {
        // add log destinations. at least one is needed!
        let console = ConsoleDestination()
        let cloud = SBPlatformDestination(appID: "v6gkMX",
                                          appSecret: "mOuyxsvl8bm8eVlLghd5NljmmOvuvope",
                                          encryptionKey: "3DcwczruKlfLmyK10dKiT3ctz0x9wjOr")
        
        log.addDestination(console)
        log.addDestination(cloud)
    }
    
    
    open func present() {
        prepareMediaCapabilities()
        
        if primetimeDataSource == nil { primetimeDataSource = PrimeTimeViewControllerDataSource() }
        
        if primetimeViewController == nil {
            primetimeViewController = PrimeTimeViewController(withDataSource: primetimeDataSource)
        }
        
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        rootVC.present(primetimeViewController, animated: false, completion: nil)
    }
    
    
    // Restart any tasks that were paused (or not yet started) while the application was
    // inactive. If the application was previously in the background, optionally refresh the
    // user interface.
    func prepareMediaCapabilities() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
}
