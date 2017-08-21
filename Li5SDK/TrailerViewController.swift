//
//  TrailerViewController.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/17/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation
import AVFoundation


protocol TrailerViewControllerProtocol {
    
    func set(player: AVPlayer)
    
}


class TrailerViewController : UIViewController, TrailerViewControllerProtocol {
    
    // MARK: - INSTANCE MEMBERS
    
    // MARK: - Stored Properties
    
    // MARK: References
    
    var product: ProductModel! {
        didSet {
            setupPoster()
        }
    }
    
    // MARK: - Outlets
    
    var waveView: Wave?
    
    @IBOutlet weak var playerView: L5PlayerView!
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var progressView: ThinPlayerProgressView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var moreLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    // MARK: - Computed Properties
    
    var layer: AVPlayerLayer {
        return playerView.playerLayer
    }
    
    var unlockable: Bool {
        return product.extendedUrl != nil
    }
    
    var hasDetails: Bool {
        return product.detailsUrl != nil
    }
    
    fileprivate var productId: String {
        return "\(product.id)"
    }
    
    // MARK: - Initializers
    
    
    /// For purposes of avoiding arbitrary creation from outside
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    
    /// Creates and instance of TeaserVC with the given product and context
    /// - Parameters:
    ///   - product: The product for which the TeaserVC should be created
    ///   - pageIndex: The page index being represented by the TeaserVC
    ///   - context: The context for the TeaserVC
    /// - Returns: New instance of TeaserViewController setup for the given data
    static func instance(withProduct product: ProductModel) -> TrailerViewController {
        
        let storyboard = UIStoryboard(name: KUI.SB.ProductPageViews.rawValue,
                                      bundle: Bundle(for: TrailerViewController.self))
        
        let vc = storyboard.instantiateViewController(withIdentifier: KUI.VC.TeaserView.rawValue)
            as? TrailerViewController
        
        if vc == nil {
            log.error("Failed to cast ViewController from storyboard to TrailerViewController")
        }
        
        let viewController = vc!
        
        log.verbose("Initializing new TrailerVC")
        
        viewController.product = product
        
        return viewController
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: Lifecycle
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        log.verbose("TeaserVC did load for product with id: \(product.id)")
        
        super.viewDidLoad()
        
        setup()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        log.verbose("TeaserVC for product with id \(product.id) did disappear")
        
        super.viewDidDisappear(animated)
        
        if progressView != nil {
            progressView.player = nil
        }
    }
    
    deinit {
        log.verbose("Deinitializing Teaser VC for product id: \(product.id)")
        
        progressView = nil
        playerView = nil
        product = nil
        waveView = nil
    }
    
    
    // MARK: Routines
    
    func set(player: AVPlayer) {
        playerView.player = player
        progressView.player = playerView.player
    }
    
    private func setup() {
        setupPoster()
        setupCategory()
        
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
        } else {
            arrowImageView.image = UIImage(named: "down",
                                           in: Bundle(for: TrailerViewController.self),
                                           compatibleWith: nil)
        }
        
        if unlockable {
            progressView.backgroundColor = UIColor.li5_red().withAlphaComponent(0.6)
        }
    }
    
    private func setupCategory() {
        if let categoryName = product.categoryName {
            categoryLabel.text = categoryName.uppercased()
        } else {
            categoryLabel.text = ""
        }
    }
    
    /// Shows poster image if available in the product model and is a valid base 64 image
    private func setupPoster() {
        guard posterImageView != nil else { return }
        
        if let poster = product.poster {
            if let data = Data(base64Encoded: poster),
                let image = UIImage(data: data) {
                posterImageView.image = image
            }
        }
    }
}


extension TrailerViewController : MultiPlayerDelegate {
    
    func didChange(player: AVPlayer?) {
        playerView.playerLayer.player = player
    }
    
    /// Change elements to display loading screen. Specially designed for giving time for loading assets
    internal func showLoadingScreen() {
        waveView?.startAnimating()
    }
    
    /// Change elements to hide loading screen. Should be run when assets are ready to play smoothly
    internal func hideLoadingScreen() {
        waveView?.stopAnimating()
    }
    
}
