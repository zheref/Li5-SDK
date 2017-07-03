//
//  TeaserViewController.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/9/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation
import AVFoundation


protocol TeaserViewControllerProtocol {
    
}


class TeaserViewController : UIViewController, TeaserViewControllerProtocol {
    
    // MARK: - INSTANCE MEMBERS
    
    // MARK: - Stored Properties
    
    // MARK: References
    
    var product: Product!
    
    var playerLayer: AVPlayerLayer?
    
    /// A weak reference to the player held by the PlaybackManager for convenience purposes
    private weak var player: AVPlayer?
    
    var waveView: Wave?
    
    var posterImageView: UIImageView?
    
    // MARK: Flags
    
    var hasBeenRetried: Bool = false
    var isDisplayed = false {
        didSet {
            if isDisplayed {
                log.debug("Attaching Teaser(\(scrollPageIndex)) to PlaybackManager")
                PlaybackManager.shared.attach(delegate: self, automaticallyReplays: true)
            }
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var playerContainer: UIView!
    
    @IBOutlet weak var actionsView: ProductPageActionsView!
    @IBOutlet weak var progressView: ThinPlayerProgressView!
    
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    // MARK: - Computed Properties
    
    var unlockable: Bool {
        return product.videoURL != nil && product.videoURL.isEmpty == false
    }
    
    var hasDetails: Bool {
        return product.type == "product" || (product.type == "url" && product.contentUrl != nil)
    }
    
    fileprivate var productId: String {
        return product.id ?? "nil"
    }
    
    // MARK: - Initializers
    
    
    /// For purposes of avoiding arbitrary creation from outside
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    /// Creates and instance of TeaserVC with the given product and context
    /// - Parameters:
    ///   - product: The product for which the TeaserVC should be created
    ///   - context: The context for the TeaserVC
    /// - Returns: New instance of TeaserViewController setup for the given data
    static func instance(withProduct product: Product,
                         andContext context: PContext) -> TeaserViewController {
        
        let storyboard = UIStoryboard(name: KUI.SB.ProductPageViews.rawValue,
                                      bundle: Bundle(for: TeaserViewController.self))
        
        let vc = storyboard.instantiateViewController(withIdentifier: KUI.VC.TeaserView.rawValue)
            as? TeaserViewController
        
        if vc == nil {
            log.error("Failed to cast ViewController from storyboard to TeaserViewController")
        }
        
        let viewController = vc!
        
        log.verbose("Initializing new TeaserVC")
        
        viewController.product = product
        viewController.reset()
            
        return viewController
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    /// Sets up from scratch the player
    private func reset() {
        if let player = PlaybackManager.shared.player {
            playerLayer = AVPlayerLayer(player: player)
        }
    }
    
    
    // MARK: Lifecycle
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        log.verbose("TeaserVC did load for product with id: \(product.id ?? "nil")")
        
        super.viewDidLoad()
        
        setup()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        actionsView.refreshStatus()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        log.verbose("TeaserVC for product with id \(product.id ?? "nil") did appear")
        super.viewDidAppear(animated)
        
        isDisplayed = true
        
        readyToPlay()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        log.verbose("TeaserVC for product with id \(product.id ?? "nil") did disappear")
        
        super.viewDidDisappear(animated)
        
        isDisplayed = false
        
        if progressView != nil {
            progressView.player = nil
        }
        
        PlaybackManager.shared.videoWillChange()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        log.verbose("TeaserVC for product with id \(product.id ?? "nil") will disappear")
        
        super.viewWillDisappear(animated)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        playerLayer?.frame = view.bounds
        playerContainer.frame = view.bounds
    }
    
    
    override func didReceiveMemoryWarning() {
        log.error("Received memory warning for TeaserVC for product id: \(product.id ?? "nil")")
        
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        log.verbose("Deinitializing Teaser VC for product id: \(product.id ?? "nil")")
        
        progressView = nil
        playerLayer = nil
        product = nil
        waveView = nil
    }
    
    
    // MARK: Routines
    
    private func setup() {
        progressView.player = player
        
        setupPoster()
        
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        guard let playerLayer = playerLayer else {
            log.error("Player layer for TeaserVC is nil: \(product.id ?? "nil")")
            return
        }
        
        playerContainer.layer.addSublayer(playerLayer)
        actionsView.setProduct(product, animate: true)
        
        if let categoryName = product.categoryName {
            categoryLabel.text = categoryName.uppercased()
            categoryImage.image = UIImage(named: categoryName.replacingOccurrences(of: " ", with: "").lowercased(),
                                          in: Bundle(for: TeaserViewController.self),
                                          compatibleWith: nil)
        }
        
        categoryImage.layer.shadowColor = UIColor.black.withAlphaComponent(0.3).cgColor
        categoryImage.layer.shadowOffset = CGSize(width: 0, height: 2)
        categoryImage.layer.shadowOpacity = 1
        categoryImage.layer.shadowRadius = 1.0
        categoryImage.clipsToBounds = false
        
//        categoryLabel.alpha = 0.0
//        categoryImage.alpha = 0.0
        
        waveView = Wave(withView: view)
        waveView?.startAnimating()
        
        let volumeView = Li5VolumeView(frame: CGRect(x: 0,
                                                     y: 0,
                                                     width: view.frame.size.width,
                                                     height: 5))
        
        view.addSubview(volumeView)
        
        if product.isAd == false && hasDetails == false {
            arrowImageView.isHidden = true
            moreLabel.isHidden = true
        }
        
        if unlockable {
            progressView.backgroundColor = UIColor.li5_red().withAlphaComponent(0.6)
        }
    }
    
    
    private func setupPoster() {
        if let poster = product.trailerPosterPreview {
            log.debug("Rendering available poster for product on Teaser...")
            
            if let data = Data(base64Encoded: poster),
                let image = UIImage(data: data) {
                
                posterImageView = UIImageView(image: image)
                posterImageView?.frame = view.bounds
                
                if let posterImageView = posterImageView {
                    playerContainer.addSubview(posterImageView)
                }
            }
        }
    }
    
    /// Notifies the advocates that the VC is ready and set up to act as a host of the playback
    fileprivate func readyToPlay() {
        if isDisplayed {
            if PlaybackManager.shared.readyToPlayCurrentItem {
                waveView?.stopAnimating()
                posterImageView?.removeFromSuperview()
                
                log.verbose("Calling to play video: \(productId)")
                PlaybackManager.shared.viewReadyToPlay()
            } else {
                log.verbose("Stopped trying to play because video is not ready to be played: \(productId)")
            }
        } else {
            log.verbose("Stopped trying to play because video is ready but vc is not being displayed: \(productId)")
        }
    }
}


extension TeaserViewController : PlaybackDelegate {
    
    func handleError(with message: String?, error: Error? = nil) {
        log.error("Error occurred with message: \(message), error: \(error).")
        
        let alertTitle = NSLocalizedString("alert.error.title", comment: "Alert title for errors")
        
        let alertMessage = message ?? NSLocalizedString("error.default.description", comment: "Default error message when no NSError provided")
        
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        let alertActionTitle = NSLocalizedString("alert.error.actions.OK", comment: "OK on error alert")
        let alertAction = UIAlertAction(title: alertActionTitle, style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func bufferIsReadyToPlay() {
        readyToPlay()
    }
    
}


//extension TeaserViewController : BCPlayerDelegate {
//    
//    func readyToPlay() {
//        log.verbose("Ready to play: \(productId)")
//        playIfReady()
//    }
//    
//    
//    func failToLoadItem(_ error : NSError) {
//        log.error("Failed to load item for product with id: \(productId) : \(error.localizedDescription)")
//        
//        if hasBeenRetried == false {
//            clearObservers()
//            //player?.pauseAndDestroy()
//            retryPlayer()
//            setupObservers()
//        } else {
//            // TODO: Show error message
//        }
//        
//        hasBeenRetried = true
//    }
//    
//    
//    func bufferReady() {
//        log.verbose("Buffer is ready for TeaserVC with product id: \(productId)")
//        
//        waveView?.stopAnimating()
//        
//        playIfReady()
//    }
//    
//}


extension TeaserViewController : UIGestureRecognizerDelegate {
    
}


