//
//  ShowViewController.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 7/4/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import AVFoundation

protocol PrimeTimeViewControllerProtocol {
    
}

class PrimeTimeViewController: UIViewController, PrimeTimeViewControllerProtocol {
    
    // MARK: - PROPERTIES
    
    // MARK: Outlets
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var activityLayer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var activityLayerAppName: UILabel!
    
    var currentController: PlayPageViewController!
    var lastpageViewController: LastPageViewController?
    
    var products = [ProductModel]()
    var eop: EndOfPrimeTime?
    
    var player: PlayerProtocol!
    var manager: PreloadingManagerProtocol!
    
    // MARK: Computed Properties
    
    var playerLayer: AVPlayerLayer? {
        return currentController.trailerVC.layer
    }
    
    // MARK: - INSTANCE OPERATIONS
    
    // MARK: Exposed Operations
    
    internal func setup(products: [ProductModel],
                        eop: EndOfPrimeTime?,
                        player: PlayerProtocol,
                        manager: PreloadingManagerProtocol,
                        bufferer: BufferPreloaderProtocol,
                        downloader: DownloadPreloaderProtocol?) {
        
        self.products = products
        self.eop = eop
        self.player = player
        
        self.manager = manager
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlayPageViewController()
        setupLastPageViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let multiPlayer = player as? MultiPlayer {
            multiPlayer.delegate = currentController.trailerVC
        }
        
        player.settle()
        
        currentController.startPreloading()
        
        presentActivityIndicator()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        player.pause()
        player.loosen()
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
            lastpageViewController = LastPageViewController(content: eop)
            lastpageViewController?.view.frame = view.bounds
        }
    }

    private func displayLastPage() {
        if let lpvc = lastpageViewController {
            view.insertSubview(lpvc.videoView, aboveSubview: currentController.view)
        }
    }

    private func hideLastPage() {
        if let lpvc = lastpageViewController {
            lpvc.view.removeFromSuperview()
        }
    }
    
    private func presentActivityIndicator() {
        activityLayer.isHidden = false
        activityIndicator.startAnimating()
        activityLayerAppName.text = Bundle.main.infoDictionary?["CFBundleName"] as? String
        leftButton.isUserInteractionEnabled = false
        rightButton.isUserInteractionEnabled = false
    }
    
    fileprivate func dismissActivityIndicator() {
        activityLayer.isHidden = true
        activityIndicator.stopAnimating()
        leftButton.isUserInteractionEnabled = true
        rightButton.isUserInteractionEnabled = true
    }
    
    // MARK: Actions
    
    @IBAction func userDidTapLeftActiveSection(_ sender: Any) {
        player.goPrevious()
        
        currentController.product = products[player.currentIndex]
        
        if let cp = player.currentPlayer {
            currentController.trailerVC.set(player: cp)
        }
        
        if currentController.currentPageIndex != 0 {
            currentController.moveTo(pageIndex: 0)
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
    
}

extension PrimeTimeViewController : PlayPageViewControllerDelegate {
    
    func readyForPlayback() {
        dismissActivityIndicator()
    }
    
}
