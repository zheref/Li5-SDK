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

public protocol Li5SDKProtocol {
    static var shared: Li5SDKProtocol { get }
    
    var options: Li5SDKOptionsProtocol { get set }
    
    func config(apiKey: String, forApp appId: String)
    func present()
}

/// SDK class which will be the access point to the presentation and configuration of SDK
public class Li5SDK : Li5SDKProtocol {
    
    fileprivate var viewController: PrimeTimeViewController!
    
    fileprivate lazy var player: MultiPlayer = {
        return MultiPlayer()
    }()
    
    fileprivate var manager: CommonPreloadingManager?
    
    fileprivate var bufferer: PreemptiveBufferPreloader?
    
    fileprivate var downloader: PlayerDownloadPreloader?
    
    fileprivate init() {}
    
    /// Singleton instance of the SDK
    public static var shared: Li5SDKProtocol = {
        return Li5SDK()
    }()
    
    public var options: Li5SDKOptionsProtocol = Li5SDKOptions()
    
    /// Prepares SDK for later calling by logging in associated registered user
    /// which holds the info and media to be managed by it.
    /// - Parameters:
    ///   - apiKey: The provided app secret key when created at the dashboard
    ///   - appId: The unique id given to the app at the dashboard
    public func config(apiKey: String, forApp appId: String) {
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
    
    /// PRE: :config method must have been already called by the time of this method call
    /// Starts the SDK by presenting the main view controller which holds the whole funcionality
    /// of
    public func present() {
        prepareMediaCapabilities()
        
        if viewController == nil {
            viewController = PrimeTimeViewController(nibName: KUI.XIB.PrimeTimeViewController.rawValue,
                                                    bundle: Bundle(for: Li5SDK.self))
        }
        
        ProductsDataStore.shared.asynchronouslyLoadProducts({ [weak self] (products, eop, eos) in
            self?.render(withProducts: products, eop: eop, eos: eos)
        })
    }
    
    /// Sets logger up for custom log printing
    private func configLogger() {
        log.addDestination(ConsoleDestination())
    }
    
    /// Starts presentation of SDK for already available products
    /// - Parameter products: The already available models to use as base of presentation
    private func render(withProducts products: [ProductModel], eop: EndOfPrimeTime?, eos: EndOfShow?) {
        // !!!UNSAFE POINT
        let assets = products.map({ (model) -> Asset in
            return model.asAsset!
        })
        
        if manager == nil {
            manager = CommonPreloadingManager(assets: assets,
                                              sameTimeBufferAmount: 1,
                                              minimumBufferedVideosToStartPlaying: 2)
            
            if bufferer == nil {
                bufferer = PreemptiveBufferPreloader(delegate: manager!)
            }
            
            if downloader == nil {
                downloader = PlayerDownloadPreloader(delegate: manager!)
            }
            
            manager?.setup(bufferer: bufferer!, downloader: downloader!)
        }
        
        viewController.setup(products: products,
                             eop: eop,
                             eos: eos,
                             player: player,
                             manager: manager!,
                             bufferer: bufferer!,
                             downloader: downloader!)
        
        viewController.options = options
        viewController.delegate = self
        
        let storyboard = UIStoryboard(name: KUI.SB.DiscoverViews.rawValue,
                                      bundle: Bundle(for: Li5SDK.self))
        
        let mantleVC = storyboard.instantiateViewController(withIdentifier: KUI.VC.MantleViewController.rawValue) as! RCMantleViewController
        
        viewController.mantleDelegate = mantleVC
        
        mantleVC.setUpScrollView()
        
        mantleVC.addToScrollViewNewController(controller: viewController)
        
        guard let rootVC = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        
        rootVC.present(mantleVC, animated: true, completion: nil)
    }
    
    
    // Restart any tasks that were paused (or not yet started) while the application was
    // inactive. If the application was previously in the background, optionally refresh the
    // user interface.
    private func prepareMediaCapabilities() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
    }
    
}

extension Li5SDK : PrimeTimeViewControllerDelegate {
    func primeTimeWasDismissed() {
        
    }
}
