//
//  ExtendedViewController.swift
//  li5
//
//  Created by Sergio Daniel on 9/2/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation
import AVFoundation

protocol ExtendedViewControllerProtocol {
    var initialPoint: CGPoint! { get set }
    static func create(product: ProductModel) -> ExtendedViewController!
}


class ExtendedViewController : UIViewController, ExtendedViewControllerProtocol {
    
    let sliderHeight: CGFloat = 50.0
    let kCAHideControls: TimeInterval = 3.5
    
    var initialPoint: CGPoint!
    
    var product: ProductModel!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var waveView: Wave!
    
    var dot: CAShapeLayer!
    var dotColor: UIColor = UIColor.li5_red()
    var dismissThreshold: CGFloat = 0.05
    var presentAnimationDuration: Double = 0.35
    
    var locked = true
    var hasAppeared = false
    var renderingAnimations = false
    
    var playEndObserver: Any?
    var hideControlsTimer: Timer?
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var seekSlider: Li5PlayerUISlider!
    @IBOutlet weak var actionsView: ProductPageActionsView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
    
    @IBOutlet weak var castButton: UIButton!
    @IBOutlet weak var moreLabel: UILabel!
    
    @IBOutlet weak var embedSliderView: UIView!
    @IBOutlet weak var embedSlider: ThinSliderView!
    @IBOutlet weak var embedShareButton: UIButton!
    @IBOutlet weak var embedPlayButton: UIButton!
    
    var lockPanGestureRecognzier: UIPanGestureRecognizer?
    var simpleTapGestureRecognizer: UITapGestureRecognizer?
    
    var hasDetails: Bool {
        return product.detailsUrl != nil
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - INITIALIZERS
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    static func create(product: ProductModel) -> ExtendedViewController! {
        let storyboard = UIStoryboard(name: KUI.SB.ProductPageViews.rawValue,
                                      bundle: Bundle(for: ExtendedViewController.self))
        
        if let vc = storyboard.instantiateViewController(withIdentifier: KUI.VC.UnlockedView.rawValue)
            as? ExtendedViewController {
            
            vc.product = product
            
            if let videoUrl = product.extendedUrl {
                vc.player = AVPlayer(url: videoUrl)
                vc.playerLayer = AVPlayerLayer(player: vc.player)
            }
            
            return vc
        } else {
            return nil
        }
    }
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPoster()
        setupPlayerZone()
        
        //actionsView.setProduct(<#T##product: Product!##Product!#>, animate: false)
        
        setupDot()
        
        view.layer.mask = dot
        
        setupGestureRecognizers()
        renderAnimations()
        renderMore()
        
        waveView = Wave(withView: self.view)
        waveView.startAnimating()
        
        view.addSubview(Li5VolumeView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 5.0)))
        
        setupControls()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hasAppeared = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        hasAppeared = false
        
        removeObservers()
        
        player.pause()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hasAppeared = true
        
        if dot != nil && locked {
            locked = false
            
            view.isUserInteractionEnabled = false
            
            let rect = CGRect(x: initialPoint.x, y: initialPoint.y, width: 1, height: 1)
            let fromPath = mainPath(forRect: rect)
            let fromShadowPath = shadowPath(forRect: rect)
            
            let newPath = mainPath(forRect: fullRect)
            let shadePath = shadowPath(forRect: fullRect)
            
            let opacity = basicAnimation(withKeyPath: "opacity", toValue: 1.0, andDuration: presentAnimationDuration)
            let pathAnimation = basicAnimation(withKeyPath: "path", toValue: newPath.cgPath, andDuration: presentAnimationDuration)
            pathAnimation.fromValue = fromPath.cgPath
            let shadowPathAnimation = basicAnimation(withKeyPath: "shadowPath", toValue: shadePath.cgPath, andDuration: presentAnimationDuration)
            shadowPathAnimation.fromValue = fromShadowPath.cgPath
            
            let animation = animationsGroup([opacity, pathAnimation, shadowPathAnimation], duration: presentAnimationDuration)
            animation.isRemovedOnCompletion = true
            animation.delegate = self
            dot.add(animation, forKey: "initial")
        } else {
            show()
        }
    }
    
    private func setupPoster() {
        if let poster = product.poster {
            guard let posterData = Data(base64Encoded: poster) else { return }
            let image = UIImage(data: posterData)
            let posterImageView = UIImageView(image: image)
            posterImageView.frame = view.bounds
            playerView.addSubview(posterImageView)
        }
    }
    
    private func setupPlayerZone() {
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerView.layer.addSublayer(playerLayer)
    }
    
    private func setupDot() {
        let rect = CGRect(x: initialPoint.x, y: initialPoint.y, width: 1, height: 1)
        
        dot = CAShapeLayer()
        dot.anchorPoint = CGPoint.zero
        dot.contentsScale = UIScreen.main.scale
        dot.shouldRasterize = true
        dot.backgroundColor = UIColor.clear.cgColor
        dot.path = mainPath(forRect: rect).cgPath
        dot.shadowRadius = 5
        dot.shadowColor = view.backgroundColor?.cgColor
        dot.shadowOpacity = 1
        dot.shadowOffset = CGSize.zero
        dot.shadowPath = shadowPath(forRect: rect).cgPath
        dot.opacity = 0.9
    }
    
    private func setupGestureRecognizers() {
        simpleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSimpleTap))
        view.addGestureRecognizer(simpleTapGestureRecognizer!)
        
        lockPanGestureRecognzier = UIPanGestureRecognizer(target: self, action: #selector(handleLockTap))
        lockPanGestureRecognzier?.delegate = self
        lockPanGestureRecognzier?.cancelsTouchesInView = false
        lockPanGestureRecognzier?.maximumNumberOfTouches = 1
        lockPanGestureRecognzier?.minimumNumberOfTouches = 1
        
        view.addGestureRecognizer(lockPanGestureRecognzier!)
    }
    
    private func renderAnimations() {
        if renderingAnimations == false {
            if seekSlider.isHidden || actionsView.isHidden {
                seekSlider.isHidden = false
                actionsView.isHidden = false
                muteButton.isHidden = false
                
                castButton.isHidden = false
                
                renderingAnimations = true
                
                UIView.animate(withDuration: 0.5, animations: { [unowned self] in
                    self.seekSlider.center = __CGPointApplyAffineTransform(self.seekSlider.center,
                                                                           CGAffineTransform(translationX: 0, y: 2 * self.sliderHeight))
                    self.actionsView.center = __CGPointApplyAffineTransform(self.actionsView.center,
                                                                            CGAffineTransform(translationX: -100, y: 0))
                    self.muteButton.center = __CGPointApplyAffineTransform(self.muteButton.center,
                                                                           CGAffineTransform(translationX: 100, y: 0))
                    self.castButton.center = __CGPointApplyAffineTransform(self.castButton.center,
                                                                           CGAffineTransform(translationX: -100, y: 0))
                }) { [weak self] (finished: Bool) in
                    self?.renderingAnimations = false
                }
                
                setupTimers()
            }
        }
    }
    
    @objc private func removeAnimations() {
        if renderingAnimations == false {
            if seekSlider.isHidden == false || actionsView.isHidden == false {
                renderingAnimations = true
                
                UIView.animate(withDuration: 0.5, animations: { [unowned self] in
                    self.seekSlider.center = __CGPointApplyAffineTransform(self.seekSlider.center,
                                                                           CGAffineTransform(translationX: 0, y: -2 * self.sliderHeight))
                    self.actionsView.center = __CGPointApplyAffineTransform(self.actionsView.center,
                                                                            CGAffineTransform(translationX: 100, y: 0))
                    self.muteButton.center = __CGPointApplyAffineTransform(self.muteButton.center,
                                                                           CGAffineTransform(translationX: -100, y: 0))
                    self.castButton.center = __CGPointApplyAffineTransform(self.castButton.center,
                                                                           CGAffineTransform(translationX: 100, y: 0))
                }) { [weak self] (finished: Bool) in
                    self?.seekSlider.isHidden = finished
                    self?.actionsView.isHidden = finished
                    self?.muteButton.isHidden = finished
                    self?.castButton.isHidden = finished
                    self?.renderingAnimations = false
                }
                
                removeTimers()
            }
        }
    }
    
    private func renderMore() {
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
    
    private func setupControls() {
        seekSlider.isHidden = true
        castButton.isHidden = true
        embedShareButton.isHidden = false
        
        muteButton.setImage(UIImage(named: "muted"), for: .normal)
        muteButton.setImage(UIImage(named: "unmuted"), for: .selected)
        moreLabel.isHidden = true
        
        if hasDetails == false {
            moreLabel.isHidden = true
            arrowImageView.isHidden = true
        }
    }
    
    private func setupTimers() {
        hideControlsTimer = Timer(timeInterval: kCAHideControls, target: self, selector: #selector(removeAnimations), userInfo: nil, repeats: false)
    }
    
    private func removeTimers() {
        if hideControlsTimer != nil {
            if hideControlsTimer!.isValid {
                hideControlsTimer?.invalidate()
            }
            
            hideControlsTimer = nil
        }
    }
    
    fileprivate func show() {
        if player.status == .readyToPlay {
            waveView.stopAnimating()
            
            seekSlider.player = player
            
            if hasAppeared {
                player.play()
                setupObservers()
                renderAnimations()
            }
        } else {
            waveView.startAnimating()
        }
    }
    
    private func setupObservers() {
        if playEndObserver == nil {
            playEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: OperationQueue(), using: { [weak self] (notification) in
                
                self?.player.seek(to: kCMTimeZero)
                self?.player.isMuted = true
                self?.muteButton.isSelected = true
                self?.player.play()
                self?.renderAnimations()
            })
        }
        
        setupTimers()
    }
    
    private func removeObservers() {
        if playEndObserver == nil {
            NotificationCenter.default.removeObserver(playEndObserver!)
            playEndObserver = nil
        }
        
        removeTimers()
    }
    
    private func exitView(_ gr: UIPanGestureRecognizer) {
        waveView.stopAnimating()
        parent?.performSelector(onMainThread: #selector(handleLockTap), with: gr, waitUntilDone: false)
        player.seek(to: kCMTimeZero)
        muteButton.isSelected = false
        embedPlayButton.isSelected = false
        player.isMuted = false
        locked = true
    }

    // MARK: - ANIMATIONS DRAWING
    
    fileprivate func center(rect: CGRect, inside container: CGRect) -> CGRect {
        let containerCenter = CGPoint(x: container.origin.x + container.size.width / 2,
                                      y: container.origin.y + container.size.height / 2)
        
        var rectCopy = rect
        
        rectCopy.origin = CGPoint(x: containerCenter.x - rect.size.width / 2,
                              y: containerCenter.y - rect.size.height / 2)
        return rectCopy
    }
    
    fileprivate var threshold: CGFloat {
        return UIScreen.main.bounds.size.height * dismissThreshold
    }
    
    fileprivate var diameter: CGFloat {
        let bounds = view.bounds.size
        return sqrt(bounds.width * bounds.width + bounds.height * bounds.height)
    }
    
    fileprivate var fullRect: CGRect {
        let h = diameter
        let size = CGSize(width: h, height: h)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return center(rect: rect, inside: view.bounds)
    }
    
    fileprivate func mainPath(forRect rect: CGRect) -> UIBezierPath {
        return UIBezierPath(ovalIn: rect).reversing()
    }
    
    fileprivate func shadowPath(forRect rect: CGRect) -> UIBezierPath {
        return UIBezierPath(ovalIn: rect.insetBy(dx: -10, dy: -10)).reversing()
    }
    
    private func animationsGroup(_ animations: [CAAnimation], duration: CFTimeInterval) -> CAAnimationGroup {
        let animation = CAAnimationGroup()
        animation.animations = animations
        animation.duration = duration
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        return animation
    }
    
    private func basicAnimation(withKeyPath keyPath: String, toValue value: Any, andDuration duration: CFTimeInterval) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        
        animation.toValue = value
        animation.duration = duration
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        return animation
    }
    
    // MARK: - GESTURE RECOGNIZERS
    
    @objc private func handleLockTap(_ gr: UIPanGestureRecognizer) {
        if dot != nil {
            switch gr.state {
            case .changed:
                let current = gr.translation(in: view)
                let h = max(diameter - current.y * 3, 10)
                let size = CGSize(width: h, height: h)
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                let newRect = center(rect: rect, inside: view.bounds)
                
                dot.path = mainPath(forRect: newRect).cgPath
                dot.shadowPath = shadowPath(forRect: newRect).cgPath
            case .ended:
                let current = gr.translation(in: view)
                
                if current.y > threshold {
                    exitView(gr)
                } else {
                    let newPath = mainPath(forRect: fullRect)
                    let shadePath = shadowPath(forRect: fullRect)
                    
                    let opacityAnimation = basicAnimation(withKeyPath: "opacity", toValue: 1.0, andDuration: 0.1)
                    let pathAnimation = basicAnimation(withKeyPath: "opacity", toValue: newPath.cgPath, andDuration: 0.1)
                    let shadowPathAnimation = basicAnimation(withKeyPath: "shadowPath", toValue: shadePath.cgPath, andDuration: 0.1)
                    
                    let animationGroup = animationsGroup([opacityAnimation, pathAnimation, shadowPathAnimation], duration: 0.1)
                    animationGroup.isRemovedOnCompletion = true
                    
                    dot.add(animationGroup, forKey: nil)
                    dot.path = newPath.cgPath
                    dot.shadowPath = shadePath.cgPath
                    dot.opacity = 1
                }
            case .cancelled:
                dot.path = mainPath(forRect: fullRect).cgPath
                dot.shadowPath = shadowPath(forRect: fullRect).cgPath
                dot.opacity = 1.0
            default:
                break
            }
        }
    }
    
    @objc private func handleSimpleTap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            if actionsView.isHidden {
                renderAnimations()
            } else {
                removeAnimations()
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touch = gestureRecognizer.location(in: view)
        
        if gestureRecognizer == lockPanGestureRecognzier, let gr = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gr.velocity(in: gestureRecognizer.view)
            let degree = atan(velocity.y / velocity.x) * 180 / CGFloat.pi
            return touch.y >= sliderHeight && fabs(degree) > 70.0 && velocity.y > 0
        }
        
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view is UIScrollView {
            if otherGestureRecognizer == lockPanGestureRecognzier {
                return true
            }
        }
        
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeTimers()
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeTimers()
        super.touchesEnded(touches, with: event)
        setupTimers()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeTimers()
        super.touchesCancelled(touches, with: event)
        setupTimers()
    }
    
    
}

extension ExtendedViewController : UIGestureRecognizerDelegate {
    
}

extension ExtendedViewController : CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if dot != nil {
            let newPath = mainPath(forRect: fullRect)
            let shadePath = shadowPath(forRect: fullRect)
            
            dot.opacity = 1
            dot.path = newPath.cgPath
            dot.shadowPath = shadePath.cgPath
            
            dot.removeAnimation(forKey: "initial")
            view.isUserInteractionEnabled = true
            
            show()
        }
    }
}
