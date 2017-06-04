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

open class Li5SDK {
    
    fileprivate var primetimeViewController: PrimeTimeViewController!
    fileprivate var primetimeDataSource: PrimeTimeViewControllerDataSource!
    
    
    fileprivate init() {}
    
    
    open static var shared: Li5SDK = {
        return Li5SDK()
    }()
    
    
    open func config(apiKey: String, forApp appId: String) {
        // Override point for customization after application launch.
        
        //let serverUrl = "http://api-testing.li5.tv/v1"
        let serverUrl = "https://api-testing.li5.tv/v1"
        //let serverUrl = "https://api.li5.tv/v1"
        
        Li5ApiHandler.sharedInstance().baseURL = serverUrl
        
        Li5ApiHandler.sharedInstance().login(DeviceManager.sharedInstance.deviceId,
                                             withApiKey: apiKey) { nserror in
            
            if let errorString = nserror != nil ? nserror?.localizedDescription : "0" {
                print("Logged in with result: \(errorString)")
            }
        }
    }
    
    
    open func present() {
        prepareMediaCapabilities()
        
        if primetimeDataSource == nil { primetimeDataSource = PrimeTimeViewControllerDataSource() }
        
        if primetimeViewController == nil {
            primetimeViewController = PrimeTimeViewController(dataSource: primetimeDataSource)
        }
        
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        rootVC.present(primetimeViewController, animated: false) { [unowned self] in
            self.ready()
        }
    }
    
    open func ready() {
        
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
