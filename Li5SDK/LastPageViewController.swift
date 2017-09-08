//
//  LastPageViewController.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/10/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation
import Crashlytics


protocol LastPageViewControllerProtocol {
    
    var content: EndOfPrimeTime { get set }
    
}


class LastPageViewController : PaginatorViewController, LastPageViewControllerProtocol {
    
    var isBeingDisplayed = false
    
    var content: EndOfPrimeTime
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var showPlayer: AVPlayer?
    
    var playbackEndObserver: Any?
    var showPlaybackEndObserver: Any?
    
    var profilePanGestureRecognizer: UIPanGestureRecognizer?
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var staticView: UIView!
    @IBOutlet weak var showLogo: UIImageView!
    @IBOutlet weak var endOfShowVideoView: UIView!
    @IBOutlet weak var swipeDownView: UIView!
    @IBOutlet weak var turnOnNotifications: UIButton!
    @IBOutlet weak var dropDownArrow: UIImageView!
    @IBOutlet weak var closeMessage: UILabel!
    @IBOutlet var popcorns: [UIImageView]!
    @IBOutlet weak var endOfShowView: UIView!
    
    private var notificationsEnabled: Bool {
        return true
    }
    
    var lastVideoUrl: EndOfPrimeTime? {
        didSet {
            guard let lastVideoUrl = lastVideoUrl else {
                log.error("This doesn't make any sense. lastVideoUrl was set but it wasn't at the same time? It's nil!")
                return
            }
            
            if let url = Foundation.URL(string: lastVideoUrl.url) {
                player = AVPlayer(url: url)
                playerLayer = AVPlayerLayer(player: player)
                
                OperationQueue.main.addOperation { [weak self] in
                    guard let this = self else {
                        log.warning("Lost reference of LastPageViewController self while in queue operation closure")
                        return
                    }
                    
                    if let lastVideoUrl = this.lastVideoUrl {
                        guard let posterData = Data(base64Encoded: lastVideoUrl.poster) else {
                            log.error("Poster data for LastPageViewController could not be converted from base64")
                            return
                        }
                        
                        guard let posterImage = UIImage(data: posterData) else {
                            log.error("Poster data for LastPageViewController could not be converted to Image")
                            return
                        }
                        
                        let posterImageView = UIImageView(image: posterImage)
                        posterImageView.frame = this.view.bounds
                        this.videoView.insertSubview(posterImageView, at: 0)
                    }
                }
            } else {
                log.error("Coudln't create player because URL string could not be parsed for LastPageViewController")
            }
            
        }
    }
    
    var endOfShow: EndOfShow?
    
    init(content: EndOfPrimeTime) {
        self.content = content
        super.init()
        self.reset()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.content = EndOfPrimeTime()
        super.init(coder: aDecoder)
        self.reset()
    }
    
    public required init(withProduct product: ProductModel) {
        fatalError("init(withProduct:pageIndex:andContext:) has not been implemented")
    }
    
    static func instance(withEOP eop: EndOfPrimeTime) -> LastPageViewController {
        
        let storyboard = UIStoryboard(name: "DiscoverViews",
                                      bundle: Bundle(for: TrailerViewController.self))
        
        let vc = storyboard.instantiateViewController(withIdentifier: "LastPageView")
            as? LastPageViewController
        
        if vc == nil {
            log.error("Failed to cast ViewController from storyboard to LastPageViewController")
        }
        
        let viewController = vc!
        
        log.verbose("Initializing new LastPageVC")
        
        viewController.content = eop
        
        return viewController
    }
    
    // MARK: - LIFECYCLE
    
    override func viewDidLoad() {
        log.verbose("LastPageViewController did load")
        super.viewDidLoad()
        
        staticView.isHidden = true
        
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        if let playerLayer = playerLayer {
            videoView.layer.addSublayer(playerLayer)
        }
        
        view.addSubview(Li5VolumeView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 5)))
        
        updateNotificationsView()
        
        showLogo.image = showLogo.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        showLogo.tintColor = UIColor.li5_white()
        
        if endOfShow?.url != nil, let videoUrl = Foundation.URL(string: endOfShow!.url) {
            showPlayer = AVPlayer(url: videoUrl)
            showPlayer?.actionAtItemEnd = .none
            showPlayer?.isMuted = true
            
            let videoLayer = AVPlayerLayer(player: showPlayer)
            
            videoLayer.frame = view.bounds
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            endOfShowVideoView.layer.addSublayer(videoLayer)
            staticView.isHidden = true
            swipeDownView.isHidden = true
        } else {
            log.error("Could not get URL for resource end_of_show.mp4 in LastPageViewController")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNotificationsView()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        log.verbose("LastPageViewController did appear")
        super.viewDidAppear(animated)
        isBeingDisplayed = true
        play()
        setupObservers()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        log.verbose("LastPageViewController did disappear")
        super.viewDidDisappear(animated)
        isBeingDisplayed = false
        player?.pause()
        showPlayer?.pause()
        clearObservers()
        staticView.isHidden = player != nil
    }
    
    @objc private func updateNotificationsView() {
        log.verbose("Updating notifications view")
        
        if notificationsEnabled {
            turnOnNotifications.isHidden = true
            dropDownArrow.isHidden = true
            
            for popcorn in popcorns {
                popcorn.isHidden = false
            }
        } else {
            turnOnNotifications.isHidden = false
            dropDownArrow.isHidden = false
            
            for popcorn in popcorns {
                popcorn.isHidden = true
            }
            
            bounce(view: dropDownArrow)
        }
        
        UIView.animate(withDuration: 0.25) { [unowned self] in
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func play() {
        if lastVideoUrl != nil, isBeingDisplayed, let player = player {
            player.seek(to: kCMTimeZero)
            player.play()
        } else {
            replayEndOfShow()
        }
    }
    
    private func setupObservers() {
        log.verbose("Setting up observers for LastPageViewController")
        
        if playbackEndObserver == nil && player != nil {
            playbackEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil, using: { [weak self] (notification) in
                self?.presentSwipeDownViewIfNeeded()
            })
        }
        
        if showPlaybackEndObserver == nil && showPlayer != nil {
            showPlaybackEndObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: showPlayer?.currentItem, queue: nil, using: { [weak self] (notification) in
                self?.replayEndOfShow()
            })
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNotificationsView), name: NSNotification.Name(rawValue: "kUserSettingsUpdated"), object: nil)
    }
    
    
    private func clearObservers() {
        log.verbose("Clearing observers for LastPageViewController")
        
        if let observer = playbackEndObserver {
            NotificationCenter.default.removeObserver(observer)
            playbackEndObserver = nil
        }
        
        if let observer = showPlaybackEndObserver {
            NotificationCenter.default.removeObserver(observer)
            showPlaybackEndObserver = nil
        }
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func bounce(view: UIView) {
        let transition = CAKeyframeAnimation(keyPath: "position.y")
        transition.values = [0, 5, -2.0, 3, 0]
        transition.keyTimes = [0.0, 0.35, 0.7, 0.9, 1]
        transition.timingFunction = CAMediaTimingFunction(controlPoints: 0.5, 1.8, 1, 1)
        transition.duration = 2.0
        transition.isAdditive = true
        transition.repeatCount = Float.infinity
        transition.beginTime = CACurrentMediaTime() + 2.0
        transition.isRemovedOnCompletion = false
        transition.fillMode = kCAFillModeForwards
        view.layer.add(transition, forKey: "bouncing")
    }
    
    
    private func presentSwipeDownViewIfNeeded() {
        log.verbose("Running presentSwipeDownViewIfNeeded")
        clearObservers()
        
        hideVideo()
        showPlayer?.isMuted = false
        showPlayer?.play()
        setupObservers()
    }
    
    
    private func hideVideo() {
        if player != nil {
            videoView.isHidden = true
            playerLayer?.removeFromSuperlayer()
            playerLayer = nil
            player = nil
        }
    }
    
    
    func replayEndOfPrimeTime() {
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    
    private func replayEndOfShow() {
        showPlayer?.seek(to: kCMTimeZero)
        showPlayer?.play()
    }
    
    
    // MARK: GESTURE RECOGNIZERS
    
    func userDidPan(_ recognizer: UIPanGestureRecognizer) {
        if videoView.isHidden {
            if recognizer.state == .began {
                if swipeDownView.isHidden == false {
                    swipeDownView.isHidden = true
                    UserDefaults.standard.set(true, forKey: "Li5SwipeDownExplainerViewPresented")
                    view.bringSubview(toFront: staticView)
                }
            }
            
            //    [searchInteractor userDidPan:recognizer];
        }
    }

    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touch = gestureRecognizer.location(in: gestureRecognizer.view)
        
        if gestureRecognizer == profilePanGestureRecognizer {
            if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
                let velocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
                return touch.y < 150 && velocity.y > 0
            }
        }
        
        return false
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.view is UIScrollView {
            return otherGestureRecognizer == profilePanGestureRecognizer
        }
        
        return gestureRecognizer == profilePanGestureRecognizer
    }
    
    
}


extension LastPageViewController : UIGestureRecognizerDelegate {
    
    
    
}
