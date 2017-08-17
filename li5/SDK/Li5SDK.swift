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

public let hlsVideoURLs = [
    "https://li5-staging-media.s3.amazonaws.com/public/2017/06/26/0c04e3aa-d69a-4a85-aae0-877a051e5fbe/hls.m3u8",
    "https://li5-staging-media.s3.amazonaws.com/public/2017/06/26/977aaddc-163e-41af-9f16-8c4e8273f483/hls.m3u8",
    "https://li5-staging-media.s3.amazonaws.com/public/2017/06/26/1ba5e997-36de-490a-889f-4efdc5fdf454/hls.m3u8",
    "https://li5-staging-media.s3.amazonaws.com/public/2017/06/26/01938331-7b23-4878-9e68-7b052a907a41/hls.m3u8",
    "https://li5-staging-media.s3.amazonaws.com/public/2017/06/26/ced1d1be-fd74-4616-9fc5-523aa386a5b2/hls.m3u8",
    "https://li5-staging-media.s3.amazonaws.com/public/2017/06/26/a94e97ba-3f10-4483-82a3-9cdcd1a3804d/hls.m3u8",
    "https://li5-staging-media.s3.amazonaws.com/public/2017/06/26/b849c1a1-5e2a-4890-8cbf-7c216407155c/hls.m3u8",
    "https://li5-staging-media.s3.amazonaws.com/public/2017/06/26/1cc99262-c3e0-4f29-bd03-4c6a5a8ef907/hls.m3u8",
    "https://li5-staging-media.s3.amazonaws.com/public/2017/06/26/c549384b-eb34-4b64-b7ca-a3554acc87cc/hls.m3u8"
]

open class Li5SDK {
    
    var primetimeViewController: PrimeTimeViewController!
    var primetimeDataSource: PrimeTimeViewControllerDataSource!
    
    var showViewController: ShowViewController!
    
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
                log.info("Logged in with result: \(errorString)")
            }
        }
    }
    
    
    private func configLogger() {
        // add log destinations. at least one is needed!
        let console = ConsoleDestination()
//        let cloud = SBPlatformDestination(appID: "v6gkMX",
//                                          appSecret: "mOuyxsvl8bm8eVlLghd5NljmmOvuvope",
//                                          encryptionKey: "3DcwczruKlfLmyK10dKiT3ctz0x9wjOr")
        
        log.addDestination(console)
        //log.addDestination(cloud)
    }
    
    
    private var assets: [Asset] {
        var i = 0
        
        return hlsVideoURLs.map({ (urlStr) -> Asset in
            let asset = Asset(url: URL(string: urlStr)!, forId: i.description)
            i += 1
            return asset
        })
    }
    
    
    open func present() {
        prepareMediaCapabilities()
        
        if primetimeDataSource == nil { primetimeDataSource = PrimeTimeViewControllerDataSource() }
        
        if primetimeViewController == nil {
            primetimeViewController = PrimeTimeViewController(withDataSource: primetimeDataSource)
        }
        
        if showViewController == nil {
            showViewController = ShowViewController(nibName: KUI.XIB.ShowViewController.rawValue,
                                                    bundle: Bundle(for: Li5SDK.self))
            
            let manager = CommonPreloadingManager(assets: assets,
                                                  sameTimeBufferAmount: 1,
                                                  minimumBufferedVideosToStartPlaying: 2)
            
            let bufferer = PreemptiveBufferPreloader(delegate: manager)
            let downloader = PlayerDownloadPreloader(delegate: manager)
            
            manager.setup(bufferer: bufferer, downloader: downloader)
            
            showViewController.setup(player: MultiPlayer(),
                                     manager: manager,
                                     bufferer: bufferer,
                                     downloader: downloader)
        }
        
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        //rootVC.present(primetimeViewController, animated: false, completion: nil)
        rootVC.present(showViewController, animated: false, completion: nil)
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
