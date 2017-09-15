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

protocol TrailerViewControllerDelegate {
    var options: Li5SDKOptionsProtocol? { get }
}

class TrailerViewController : UIViewController, TrailerViewControllerProtocol {
    
    // MARK: VALUES
    
    var startPositionX: CGFloat = 0.0
    var endPositionX: CGFloat = 0.0
    
    // MARK: MODEL
    
    var product: ProductModel! {
        didSet {
            setupPoster()
            setupCategory()
            setupProgressColor()
            toggleMoreCaptionDisplay(into: product.detailsUrl != nil)
        }
    }
    
    // MARK: OUTLETS
    
    @IBOutlet weak var playerView: L5PlayerView!
    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var progressView: ThinPlayerProgressView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var moreLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    // MARK: PROGRAMMATIC UI
    
    var waveView: Wave?
    
    var layer: AVPlayerLayer {
        return playerView.playerLayer
    }
    
    var unlockable: Bool {
        return product.extendedUrl != nil
    }
    
    var hasDetails: Bool {
        return product.detailsUrl != nil
    }
    
    // MARK: REFERENCES
    
    var delegate: TrailerViewControllerDelegate?
    
    // MARK: COMPUTED PROPERTIES
    
    fileprivate var productId: String {
        return "\(product.id)"
    }
    
    // MARK: - INITIALIZERS
    
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
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
    
    // MARK: LIFECYCLE AND OVERRIDES
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        log.verbose("TeaserVC did load for product with id: \(product.id)")
        
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        progressView.player = playerView.player
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        log.verbose("TeaserVC for product with id \(product.id) did disappear")
        
        super.viewDidDisappear(animated)
        
        if progressView != nil {
            progressView.player = nil
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        startPositionX = (view.bounds.size.width / 2) - (categoryLabel.bounds.size.width / 2)
        endPositionX = categoryLabel.layer.position.x
    }
    
    // MARK: - SETUPS
    
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
        
        setupProgressColor()
        setupMoreCaption()
        toggleMoreCaptionDisplay(into: product.detailsUrl != nil)
    }
    
    private func setupProgressColor() {
        if progressView != nil {
            let unlockableColor = delegate?.options?.extendablePlaybackProgressColor ?? UIColor.red
            let limitedColor = delegate?.options?.playbackProgressColor ?? UIColor.white
            
            if unlockable {
                progressView.overlayColor = unlockableColor
            } else {
                progressView.overlayColor = limitedColor
            }
        }
    }
    
    private func setupCategory() {
        if categoryLabel != nil {
            if let categoryName = product.categoryName {
                categoryLabel.text = categoryName.uppercased()
                setupCategoryAnimation()
            } else {
                categoryLabel.text = ""
                categoryLabel.isHidden = true
            }
        }
    }
    
    private func setupPoster() {
        guard posterImageView != nil else { return }
        
        if let poster = product.poster {
            if let data = Data(base64Encoded: poster),
                let image = UIImage(data: data) {
                posterImageView.image = image
            }
        }
    }
    
    private func setupMoreCaption() {
        if let delegate = delegate,
            let options = delegate.options,
            moreLabel != nil {
            
            moreLabel.text = options.contentCTACaption.uppercased()
        }
    }
    
    private func toggleMoreCaptionDisplay(into show: Bool) {
        if moreLabel != nil, arrowImageView != nil {
            moreLabel.isHidden = !show
            arrowImageView.isHidden = !show
            
            if show {
                setupMoreAnimation()
            }
        }
    }
    
    private func setupMoreAnimation() {
        let trans = CAKeyframeAnimation(keyPath: "position.y")
        trans.values = [0, 5, -2, 3, 0]
        trans.keyTimes = [0.0, 0.35, 0.7, 0.9, 1]
        trans.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.8, 1, 1)
        trans.duration = 2.0
        trans.isAdditive = true
        trans.repeatCount = Float.infinity
        trans.beginTime = CACurrentMediaTime() + 2.0
        trans.isRemovedOnCompletion = false
        trans.fillMode = kCAFillModeForwards
        arrowImageView.layer.add(trans, forKey: "bouncing")
    }
    
    private func setupCategoryAnimation() {
        let totalDuration: Double = 1.2
        
        var currentPosition: CGPoint = categoryLabel.layer.position
        currentPosition.x = startPositionX
        
        var startFrame = categoryLabel.frame
        let endFrame = startFrame
        startFrame.size.width = 0
        categoryLabel.frame = startFrame
        
        UIView.animateKeyframes(withDuration: totalDuration,
                                delay: 0.0,
                                options: UIViewKeyframeAnimationOptions.calculationModeLinear,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.7,
                                                       relativeDuration: 0.3, animations: { [unowned self] in
                                                        self.categoryLabel.alpha = 1.0
                                                        self.categoryLabel.frame = endFrame
                                    })
        }, completion: nil)
    }
    
}

extension TrailerViewController : MultiPlayerDelegate {
    
    func didChange(player: AVPlayer?) {
        playerView.playerLayer.player = player
    }
    
    func showLoadingScreen() {
        waveView?.startAnimating()
    }
    
    func hideLoadingScreen() {
        waveView?.stopAnimating()
    }
    
}
