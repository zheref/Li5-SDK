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

/// SDK class which will be the access point to the presentation and configuration of SDK

open class Li5SDK {
    
    private var showViewController: ShowViewController!
    
    fileprivate init() {}
    
    /// Singleton instance of the SDK
    open static var shared: Li5SDK = {
        return Li5SDK()
    }()
    
    /// Prepares SDK for later calling by logging in associated registered user
    /// which holds the info and media to be managed by it.
    /// - Parameters:
    ///   - apiKey: The provided app secret key when created at the dashboard
    ///   - appId: The unique id given to the app at the dashboard
    open func config(apiKey: String, forApp appId: String) {
        configLogger()
        
        log.info("Setting up Li5 SDK")
        
        Li5ApiHandler.sharedInstance().baseURL = KCore.testApiUrl
        
        Li5ApiHandler.sharedInstance().login(DeviceManager.sharedInstance.deviceId,
                                             withApiKey: apiKey) { nserror in
            
            if let errorString = nserror != nil ? nserror?.localizedDescription : "0" {
                log.info("Logged in with result: \(errorString)")
            }
        }
    }
    
    /// Sets logger up for custom log printing
    private func configLogger() {
        log.addDestination(ConsoleDestination())
    }
    
    /// PRE: :config method must have been already called by the time of this method call
    /// Starts the SDK by presenting the main view controller which holds the whole funcionality
    /// of
    open func present() {
        prepareMediaCapabilities()
        
        if showViewController == nil {
            showViewController = ShowViewController(nibName: KUI.XIB.ShowViewController.rawValue,
                                                    bundle: Bundle(for: Li5SDK.self))
            
            ProductsDataStore.shared.asynchronouslyLoadProducts({ [weak self] (products) in
                self?.render(withProducts: products)
            })
        }
    }
    
    /// Starts presentation of SDK for already available products
    /// - Parameter products: The already available models to use as base of presentation
    private func render(withProducts products: [ProductModel]) {
        // !!!UNSAFE POINT
        let assets = products.map({ (model) -> Asset in
            return model.asAsset!
        })
        
        let manager = CommonPreloadingManager(assets: assets,
                                              sameTimeBufferAmount: 1,
                                              minimumBufferedVideosToStartPlaying: 2)
        
        let bufferer = PreemptiveBufferPreloader(delegate: manager)
        let downloader = PlayerDownloadPreloader(delegate: manager)
        
        manager.setup(bufferer: bufferer, downloader: downloader)
        
        self.showViewController.setup(products: products,
                                      player: MultiPlayer(),
                                      manager: manager,
                                      bufferer: bufferer,
                                      downloader: downloader)
        
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        rootVC.present(self.showViewController, animated: false, completion: nil)
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
