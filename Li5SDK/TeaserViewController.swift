//
//  TeaserViewController.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/9/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation


protocol TeaserViewControllerProtocol {
    
}


class TeaserViewController : UIViewController, TeaserViewControllerProtocol {
    
    // MARK: - INSTANCE MEMBERS
    
    // MARK: - Stored Properties
    
    var product: Product!
    var productContext: PContext!
    
    var hasBeenRetried: Bool = false
    var isDisplayed = false
    
    var player: BCPlayer?
    var playerLayer: BCPlayerLayer?
    
    var waveView: Wave?
    
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
    
    // MARK: - Initializers
    
    
    static func instance(withProduct product: Product,
                         andContext context: PContext) -> TeaserViewController {
        
        let storyboard = UIStoryboard(name: "ProductPageViews",
                                      bundle: Bundle(for: TeaserViewController.self))
        
        let vc = storyboard.instantiateViewController(withIdentifier: "TeaserView")
            as! TeaserViewController
        
        log.verbose("Initializing new TeaserVC")
        
        vc.product = product
        vc.productContext = context
        vc.reset()
            
        return vc
    }
    
    
    private func reset() {
        if let url = Foundation.URL(string: product.trailerURL) {
            player = BCPlayer(url: url, bufferInSeconds: 10.0, priority: .buffer, delegate: self)
            
            playerLayer = BCPlayerLayer(player: player,
                                        andFrame: UIScreen.main.bounds,
                                        previewImageRequired: false)
        } else {
            log.error("URL couldn't be created with string \(product.trailerURL)")
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
    
    
    override func viewDidDisappear(_ animated: Bool) {
        log.verbose("TeaserVC for product with id \(product.id ?? "nil") did disappear")
        
        super.viewDidDisappear(animated)
        
        isDisplayed = false
        
        clearObservers()
        player?.pauseAndDestroy()
        // [self updateSecondsWatched];
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        log.verbose("TeaserVC for product with id \(product.id ?? "nil") will disappear")
        
        super.viewWillDisappear(animated)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        log.verbose("TeaserVC for product with id \(product.id ?? "nil") will appear")
        
        super.viewWillAppear(animated)
        
        actionsView.refreshStatus()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        log.verbose("TeaserVC for product with id \(product.id ?? "nil") did appear")
        
        super.viewDidAppear(animated)
        
        isDisplayed = true
        
        playIfReady()
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
        log.debug("Deinitializing Teaser VC for product id: \(product.id ?? "nil")")
        
        clearObservers()
        player?.pauseAndDestroy()
        
        product = nil
        player = nil
        waveView = nil
    }
    
    
    // MARK: Routines
    
    
    func setPriority(_ priority: BCPriority) {
        player?.changePriority(priority)
    }
    
    
    private func setup() {
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
            log.verbose("Rendering available poster for product on Teaser...")
            
            if let data = Data(base64Encoded: poster),
                let image = UIImage(data: data) {
                
                let imageView = UIImageView(image: image)
                imageView.frame = view.bounds
                
                playerContainer.addSubview(imageView)
            }
        }
    }
    
    
    fileprivate func playIfReady() {
        log.debug("Calling to play if ready...")
        
        if isDisplayed {
            player?.changePriority(.play)
        }
        
        if player?.status == .readyToPlay {
            log.debug("Trying to play since player status seems to be ready to play: \(product.id ?? "nil")")
            waveView?.stopAnimating()
            
            progressView.player = player
            
            if isDisplayed {
                log.debug("Playing video: \(product.id ?? "nil")")
                player?.play()
                setupObservers()
            } else {
                log.verbose("Stopped trying to play because video is ready but vc is not being displayed: \(product.id ?? "nil")")
            }
        } else {
            log.warning("Tried to play but not ready yet: \(product.id ?? "nil")")
        }
    }
    
    
    private func replay() {
        log.verbose("Replaying...")
        
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    
    fileprivate func retryPlayer() {
        guard let url = Foundation.URL(string: product.trailerURL) else {
            log.error("Couldn't undertand url for string: \(product.trailerURL)")
            return
        }
        
        player = BCPlayer(url: url, bufferInSeconds: 10.0, priority: .buffer, delegate: self)
        playerLayer?.player = player
        
        player?.play()
    }
    
    
    fileprivate func setupObservers() {
        log.verbose("Setting up observers for TeaserVC with product id: \(product.id)")
    }
    
    
    fileprivate func clearObservers() {
        progressView.player = nil
    }
    
}


extension TeaserViewController : UIViewControllerTransitioningDelegate {
    
}


extension TeaserViewController : BCPlayerDelegate {
    
    func readyToPlay() {
        playIfReady()
    }
    
    
    func failToLoadItem(_ error : NSError) {
        log.error("Failed to load item for product with id: \(product.id ?? "nil") : \(error.localizedDescription)")
        
        if hasBeenRetried == false {
            clearObservers()
            player?.pauseAndDestroy()
            retryPlayer()
            setupObservers()
        } else {
            // TODO: Show error message
        }
        
        hasBeenRetried = true
    }
    
    
    func networkFail(_ error : NSError) {
        log.error("Network failed to load TeaserVC for product with id: \(product.id ?? "nil") : \(error.localizedDescription)")
        
        // TODO: Show error message
    }
    
    
    func bufferEmpty() {
        log.verbose("Buffer is EMPTY for TeaserVC with product id: \(product.id ?? "nil"). Waiting...")
        
        waveView?.startAnimating()
        
        player?.pause()
    }
    
    
    func bufferReady() {
        log.verbose("Buffer is ready for TeaserVC with product id: \(product.id ?? "nil")")
        
        waveView?.stopAnimating()
        
        playIfReady()
    }
    
}


extension TeaserViewController : UIGestureRecognizerDelegate {
    
}


