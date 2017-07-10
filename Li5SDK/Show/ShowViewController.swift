//
//  ShowViewController.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 7/4/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import AVFoundation

private var playerViewControllerKVOContext = 0

let hardcodedHls = [
    "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
    "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
    "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
    "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
    "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
    "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
    "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
    "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
    "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
    "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
    "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
    "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
    "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
    "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
    "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
    "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
    "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
    "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
    "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
    "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8"
]

class ShowViewController: UIViewController {
    
    // MARK: - PROPERTIES
    
    // MARK: Outlets
    
    @IBOutlet weak var playerView: Li5PlayerView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Stored Properties
    
    /// The player responsible of the media playback
    let player = AVQueuePlayer()
    
    /// The index of the item currently being played
    var currentIndex: Int = 0
    
    /// The product models which trailer URLs should be played
    var products = [Product]()
    
    /// TODO: Missing documentation
    var playlistItems = [AVPlayerItem]()
    
    /// The assets corresponding the trailers of each product to be eventually played
    var assetsManager = PlaybackAssetsManager()
    
    private var endPlayObserver: NSObjectProtocol?
    
    // MARK: Computed Properties
    
    var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    
    var currentProduct: Product? {
        if currentIndex >= 0 && currentIndex < products.count {
            return products[currentIndex]
        } else {
            return nil
        }
    }
    
    // MARK: - INSTANCE OPERATIONS
    
    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObserver(self, forKeyPath: #keyPath(ShowViewController.player.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(ShowViewController.player.currentItem), options: [.new, .initial], context: &playerViewControllerKVOContext)
        
        self.showLoadingScreen()
        
        playerView.playerLayer.player = player
        
        asynchronouslyLoadProducts { [unowned self] in
            var assets = [Li5Asset]()
            
            var i = 0 // TODO: Remove hardcode
            
            for product in self.products {
                //product.trailerURL = hardcodedHls[i] // TODO: Remove hardcode
                i += 1 // TODO: Remove hardcode
                
                if let url = Foundation.URL(string: product.trailerURL) {
                    let asset = AVURLAsset(url: url)
                    log.verbose("Creating Li5Asset for product \(product.id)")
                    assets.append(Li5Asset(id: product.id, asset: asset))
                }
            }
            
            self.assetsManager.delegate = self
            self.assetsManager.assets = assets
            
            self.assetsManager.startPreemptive()
            //self.assetsManager.startDownloading()
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        player.pause()
        
        removeObserver(self, forKeyPath: #keyPath(ShowViewController.player.currentItem.status),
                       context: &playerViewControllerKVOContext)
        
        removeObserver(self, forKeyPath: #keyPath(ShowViewController.player.currentItem),
                       context: &playerViewControllerKVOContext)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        player.play()
        setAutomaticReplay()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: KVO Observation
    
    // Update our UI when player or `player.currentItem` changes.
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(ShowViewController.player.currentItem) {
            //queueDidChangeWithOldPlayerItems(oldPlayerItems: [], newPlayerItems: player.items())
        } else if keyPath ==  #keyPath(ShowViewController.player.currentItem.status) {
            // Display an error if status becomes `.Failed`.
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItemStatus
            
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
                
                if newStatus == .readyToPlay {
                    player.play()
                }
            }
            else {
                newStatus = .unknown
            }
            
            if newStatus == .failed {
                handleError(with: player.currentItem?.error?.localizedDescription, error: player.currentItem?.error)
            }
        }
    }
    
    
    /// Preloads the first assets
    ///
    /// - Parameter then: <#then description#>
    private func preloadFirstAssets(_ then: () -> Void) {
        //                for i in 0...products.count-1 {
        //                    let newPlayerItem = assetsManager.itemReady(forIndex: i)
        //                    self.playlistItems.append(newPlayerItem)
        //                    self.player.insert(newPlayerItem, after: nil)
        //                }
        //
    }
    
    /// Shows poster image if available in the product model and is a valid base 64 image
    fileprivate func setupPoster() {
        guard let currentProduct = currentProduct else {
            log.error("Current product is nil: \(currentIndex)")
            return
        }
        
        if let poster = currentProduct.trailerPosterPreview {
            if let data = Data(base64Encoded: poster),
                let image = UIImage(data: data) {
                posterImageView.image = image
            }
        }
    }
    
    
    func asynchronouslyLoadProducts(_ then: @escaping () -> Void) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let li5 = Li5ApiHandler.sharedInstance() else {
                log.error("No instance available for Li5 API Services")
                return
            }
            
            li5.requestDiscoverProducts() { [weak self] (error, products) in
                if let error = error {
                    log.error("Error while fetching products: \(error)")
                    // Handle error
                } else if let products = products {
                    log.info("\(products.data.count) fetched products")
                    log.verbose(products)
                    
                    if products.data.count > 0 {
                        if let this = self {
                            this.products = products.data as? [Product] ?? [Product]()
                            //this.endOfPrimeTime = products.endOfPrimeTime
                            log.info("Products and EOPT set successfully")
                            then()
                        } else {
                            log.warning("Lost reference to self after products have been fetched")
                        }
                    } else {
                        log.warning("0 retrieved products")
                    }
                } else {
                    log.error("No retrieved products")
                }
            }
        }
        
    }
    
    
    private func playNext() {
        if currentIndex == playlistItems.count - 1 {
            log.error("Trying to go to next player item when there are no more enqueued")
        } else {
            currentIndex += 1
            setupPoster()
            player.advanceToNextItem()
            setAutomaticReplay()
        }
    }
    
    
    private func playPrevious() {
        if currentIndex == 0 {
            log.error("Trying to go to previous player item when the cursor is on zero position")
        } else {
            currentIndex -= 1
            setupPoster()
            
            player.removeAllItems()
            
            for index in currentIndex...playlistItems.count-1 {
                let item = playlistItems[index]
                
                if player.canInsert(item, after: nil) {
                    player.seek(to: kCMTimeZero)
                    player.insert(item, after: nil)
                } else {
                    log.warning("Wasn't able to insert av player item while refreshign for specific play")
                }
            }
            
            if player.status == .readyToPlay {
                player.play()
                setAutomaticReplay()
            } else {
                log.warning("Tried to play but not ready yet for index: \(currentIndex)")
            }
        }
    }
    
    
    private func setAutomaticReplay() {
        player.actionAtItemEnd = .none
        
        if endPlayObserver != nil {
            NotificationCenter.default.removeObserver(endPlayObserver!)
            endPlayObserver = nil
        }
        
        endPlayObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                                 object: player.currentItem,
                                                                 queue: nil)
        { [weak self] (_) in
            DispatchQueue.main.async { [weak self] in
                self?.player.seek(to: kCMTimeZero)
            }
        }
    }
    
    /// Change elements to display loading screen. Specially designed for giving time for loading assets
    private func showLoadingScreen() {
        loadingView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    /// Change elements to hide loading screen. Should be run when assets are ready to play smoothly
    fileprivate func hideLoadingScreen() {
        loadingView.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // MARK: Error Handling
    
    func handleError(with message: String?, error: Error? = nil) {
        NSLog("Error occurred with message: \(message), error: \(error).")
        
        let alertTitle = NSLocalizedString("alert.error.title", comment: "Alert title for errors")
        
        let alertMessage = message ?? NSLocalizedString("error.default.description", comment: "Default error message when no NSError provided")
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let alertActionTitle = NSLocalizedString("alert.error.actions.OK", comment: "OK on error alert")
        let alertAction = UIAlertAction(title: alertActionTitle, style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Actions
    
    @IBAction func userDidTapLeftActiveSection(_ sender: Any) {
        playPrevious()
    }
    
    @IBAction func userDidTapRightActiveSection(_ sender: Any) {
        playNext()
    }
    

}

extension ShowViewController : Li5PlaybackAssetsManagerDelegate {
    
    func requiredAssetIsReady(_ asset: AVAsset, forId id: String) {
        log.verbose("Adding ready asset for id: \(id)")
        let newPlayerItem = AVPlayerItem(asset: asset)
        
        playlistItems.append(newPlayerItem)
        player.insert(newPlayerItem, after: nil)
    }
    
    func managerDidFinishBufferingMinimumRequiredAssets() {
        DispatchQueue.main.async { [unowned self] in
            self.hideLoadingScreen()
            self.setupPoster()
            self.player.play()
        }
    }
    
    func managerDidFinishDownloadingRequiredAssets() {
        log.verbose("Finished downloading")
    }
}
