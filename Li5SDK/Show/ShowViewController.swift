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

class ShowViewController: UIViewController {
    
    // MARK: - PROPERTIES
    
    // MARK: Outlets
    
    @IBOutlet weak var playerView: Li5PlayerView!
    @IBOutlet weak var posterImageView: UIImageView!
    
    // MARK: Stored Properties
    
    /// The player responsible of the media playback
    let player = AVQueuePlayer()
    
    /// The index of the item currently being played
    var currentIndex: Int = 0
    
    /// The product models which trailer URLs should be played
    var products = [Product]()
    
    /// The assets corresponding the trailers of each product to be eventually played
    var loadedAssets = [AVURLAsset]()
    
    // MARK: Computed Properties
    
    var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    
    var currentProduct: Product {
        return products[currentIndex]
    }
    
    // MARK: - INSTANCE OPERATIONS
    
    // MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        player.automaticallyWaitsToMinimizeStalling = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addObserver(self, forKeyPath: #keyPath(ShowViewController.player.currentItem.status), options: [.new, .initial], context: &playerViewControllerKVOContext)
        addObserver(self, forKeyPath: #keyPath(ShowViewController.player.currentItem), options: [.new, .initial], context: &playerViewControllerKVOContext)
        
        playerView.playerLayer.player = player
        
        asynchronouslyLoadProducts { [unowned self] in
            for product in self.products {
                if let url = Foundation.URL(string: product.trailerURL) {
                    let asset = AVURLAsset(url: url, options: [:])
                    
                    self.loadedAssets.append(asset)
                    
                    let newPlayerItem = AVPlayerItem(asset: asset)
                    
                    self.player.insert(newPlayerItem, after: nil)
                }
            }
            
            self.setupPoster()
            
            self.player.play()
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
    
    /// Shows poster image if available in the product model and is a valid base 64 image
    private func setupPoster() {
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
    
    @IBAction func userDidTapRightActiveSection(_ sender: Any) {
        currentIndex += 1
        setupPoster()
        player.advanceToNextItem()
    }
    

}
