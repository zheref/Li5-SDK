//
//  ShowViewController.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 7/4/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import AVFoundation

protocol PrimeTimeViewControllerProtocol : class {
    func setup(products: [ProductModel],
               eop: EndOfPrimeTime?,
               eos: EndOfShow?,
               player: PlayerProtocol,
               manager: PreloadingManagerProtocol,
               bufferer: BufferPreloaderProtocol,
               downloader: DownloadPreloaderProtocol?)
}

protocol PrimeTimeViewControllerDelegate : class {
    
    func primeTimeWasDismissed()
    
    func endOfShowWasReached()
    
}

class PrimeTimeViewController: UIViewController, PrimeTimeViewControllerProtocol {
    
    // MARK: - PROPERTIES
    
    // MARK: Outlets
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var auxiliarContainer: UIView!
    
    @IBOutlet weak var activityIndicator: SpinnerView!
    @IBOutlet weak var activityLayerAppName: UILabel!
    
    @IBOutlet weak var lastPageContainer: UIView!
    
    @IBOutlet weak var leftButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightButtonWidthConstraint: NSLayoutConstraint!
    
    // MARK: Subviewcontrollers
    
    private var currentController: PlayPageViewController!
    fileprivate var lastpageViewController: LastPageViewController?
    private var extendedViewController: ExtendedViewController?
    
    // MARK: Models
    
    private var products = [ProductModel]()
    private var eop: EndOfPrimeTime?
    private var eos: EndOfShow?
    
    var options: Li5SDKOptionsProtocol = Li5SDKOptions()
    
    // MARK: Delegates
    
    weak var mantleDelegate: RCMantleViewDelegate?
    weak var delegate: PrimeTimeViewControllerDelegate?
    
    // MARK: Playback
    
    private weak var player: PlayerProtocol!
    private var manager: PreloadingManagerProtocol!
    
    // MARK: Computed Properties
    
    private var playerLayer: AVPlayerLayer? {
        return currentController.trailerVC.layer
    }
    
    fileprivate var currentProduct: ProductModel {
        return products[player.currentIndex]
    }
    
    // MARK: - INSTANCE OPERATIONS
    
    // MARK: Exposed Operations
    
    func setup(products: [ProductModel],
               eop: EndOfPrimeTime?,
               eos: EndOfShow?,
               player: PlayerProtocol,
               manager: PreloadingManagerProtocol,
               bufferer: BufferPreloaderProtocol,
               downloader: DownloadPreloaderProtocol?) {
        
        self.products = products
        self.eop = eop
        self.eos = eos
        
        if self.player == nil {
            self.player = player
        }
        
        if self.manager == nil {
            self.manager = manager
        }
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayPageViewController()
        setupLastPageViewController()
        
        let gestureRecorgnizer = UILongPressGestureRecognizer(target: self, action: #selector(userDidHoldMiddleActiveSection))
        view.addGestureRecognizer(gestureRecorgnizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let multiPlayer = player as? MultiPlayer {
            multiPlayer.delegate = currentController.trailerVC
        }
        
        player.settle()
        
        presentActivityIndicator()
        currentController.startPreloading()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        player.goToFirst(startPlaying: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        player.play()
        player.automaticallyReplay = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    private func setupPlayPageViewController() {
        currentController = PlayPageViewController(withProduct: products[player.currentIndex],
                                                   player: player,
                                                   manager: manager)

        currentController.delegate = self
        currentController.view.frame = view.bounds
        view.insertSubview(currentController.view, at: 0)
    }

    private func setupLastPageViewController() {
        if let eop = eop {
            lastpageViewController = LastPageViewController.instance(withEOP: eop)
            lastpageViewController?.lastVideoUrl = eop
            lastpageViewController?.endOfShow = eos
            lastpageViewController?.delegate = self
            lastpageViewController?.view.frame = lastPageContainer.bounds
        }
    }

    private func displayLastPage() {
        if let lpvc = lastpageViewController {
            lastPageContainer.addSubview(lpvc.view)
            lastPageContainer.isHidden = false
            addChildViewController(lpvc)
            player.pause()
        }
    }

    private func hideLastPage() {
        if let lpvc = lastpageViewController {
            lpvc.view.removeFromSuperview()
            lastPageContainer.isHidden = true
            lpvc.removeFromParentViewController()
            player.goToZero()
            player.play()
        }
    }
    
    private func presentActivityIndicator() {
        auxiliarContainer.isHidden = false
        activityIndicator.isHidden = false
        
        activityLayerAppName.font = UIFont(name: "Rubik-Medium", size: 16)
        activityLayerAppName.text = options.appName ?? Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "Loading"
        
        leftButton.isUserInteractionEnabled = false
        rightButton.isUserInteractionEnabled = false
    }
    
    fileprivate func dismissActivityIndicator() {
        auxiliarContainer.isHidden = true
        activityIndicator.isHidden = true
        leftButton.isUserInteractionEnabled = true
        rightButton.isUserInteractionEnabled = true
    }
    
    private func setupExtended(withInitialPoint initialPoint: CGPoint) {
        extendedViewController = ExtendedViewController.create(product: currentProduct)
        
        extendedViewController?.initialPoint = initialPoint
        
        extendedViewController?.providesPresentationContextTransitionStyle = true
        extendedViewController?.definesPresentationContext = true
        extendedViewController?.modalPresentationStyle = .fullScreen
        
        extendedViewController?.view.frame = auxiliarContainer.bounds
    }
    
    private func presentExtended() {
        for view in auxiliarContainer.subviews {
            view.removeFromSuperview()
        }
        
        if let xvc = extendedViewController {
            auxiliarContainer.backgroundColor = UIColor.clear
            auxiliarContainer.addSubview(xvc.view)
            player.pause()
            addChildViewController(xvc)
            auxiliarContainer.isHidden = false
            leftButton.isUserInteractionEnabled = false
            rightButton.isUserInteractionEnabled = false
        }
    }
    
    private func dismissExtended() {
        if let xvc = extendedViewController {
            auxiliarContainer.isHidden = true
            xvc.view.removeFromSuperview()
            xvc.removeFromParentViewController()
            player.goToZero()
            player.play()
            leftButton.isUserInteractionEnabled = true
            rightButton.isUserInteractionEnabled = true
        }
    }
    
    // MARK: Actions
    
    @IBAction func userDidTapLeftActiveSection(_ sender: Any) {
        if let lpvc = lastpageViewController, lpvc.parent != nil {
            hideLastPage()
        } else {
            player.goPrevious()
            
            currentController.product = products[player.currentIndex]
            
            if let cp = player.currentPlayer {
                currentController.trailerVC.set(player: cp)
            }
            
            if currentController.currentPageIndex != 0 {
                currentController.moveTo(pageIndex: 0)
            }
        }
    }
    
    @IBAction func userDidTapRightActiveSection(_ sender: Any) {
        if player.currentIndex + 1 == products.count {
            displayLastPage()
        } else {
            player.goNext()
            
            currentController.product = products[player.currentIndex]
            
            if let cp = player.currentPlayer {
                currentController.trailerVC.set(player: cp)
            }
            
            if currentController.currentPageIndex != 0 {
                currentController.moveTo(pageIndex: 0)
            }
        }
    }
    
    func userDidHoldMiddleActiveSection(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.began {
            if let _ = currentProduct.extendedUrl {
                setupExtended(withInitialPoint: recognizer.location(in: currentController.view))
                presentExtended()
            }
        }
    }
    
    // MARK: - GESTURE RECOGNIZERS
    
    @objc private func handleLockTap(_ gr: UIPanGestureRecognizer) {
        dismissExtended()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - RELEASE MEMORY
    
    fileprivate func releaseAllocations() {
        products = []
        eos = nil
        eop = nil
    }
    
}

extension PrimeTimeViewController : PlayPageViewControllerDelegate {
    
    var visibleToPlay: Bool {
        return lastpageViewController?.parent == nil
    }
    
    func readyForPlayback() {
        dismissActivityIndicator()
    }
    
    func didChangeToTrailer() {
        leftButtonWidthConstraint.constant = leftButtonWidthConstraint.constant * 2
        rightButtonWidthConstraint.constant = rightButtonWidthConstraint.constant * 2
    }
    
    func didChangeToContent() {
        leftButtonWidthConstraint.constant = leftButtonWidthConstraint.constant / 2
        rightButtonWidthConstraint.constant = rightButtonWidthConstraint.constant / 2
    }
    
}

extension PrimeTimeViewController : LastPageViewControllerDelegate {
    
    func didReachEndOfShow() {
        delegate?.endOfShowWasReached()
    }
    
}

extension PrimeTimeViewController : RCMantleViewListener {
    
    func mantleWillClose() {
        releaseAllocations()
    }
    
    func mantleDidClose() {
        delegate?.primeTimeWasDismissed()
    }
    
}
