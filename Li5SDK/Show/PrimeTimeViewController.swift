//
//  ShowViewController.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 7/4/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class PrimeTimeViewController: UIViewController {
    
    // MARK: - PROPERTIES
    
    // MARK: Outlets
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    // MARK: Stored Properties
    
    var currentIndex = 0
    var currentController: PageViewController!
    
    var products = [ProductModel]()
    
    var player: PlayerProtocol!
    var manager: PreloadingManagerProtocol!
    var bufferer: BufferPreloaderProtocol!
    var downloader: DownloadPreloaderProtocol?
    
    var didStartPlayback = false
    
    // MARK: Computed Properties
    
    var playerLayer: AVPlayerLayer? {
        return currentController.trailer.layer
    }
    
    // MARK: - INSTANCE OPERATIONS
    
    // MARK: Exposed Operations
    
    internal func setup(products: [ProductModel],
                        player: PlayerProtocol,
                        manager: PreloadingManagerProtocol,
                        bufferer: BufferPreloaderProtocol,
                        downloader: DownloadPreloaderProtocol?) {
        
        self.products = products
        self.player = player
        
        self.manager = manager
        self.bufferer = bufferer
        self.downloader = downloader
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentController = PageViewController(withProduct: products[currentIndex])
        currentController.view.frame = view.bounds
        view.insertSubview(currentController.view, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let multiPlayer = player as? MultiPlayer {
            multiPlayer.delegate = currentController.trailer
        }
        
        player.settle()
        
        if let currentPlayer = player.currentPlayer {
            // TODO: Fix this
            currentController.trailer.playerView.playerLayer.player = currentPlayer
        }
        
        manager.delegate = self
        
        manager.startPreloading()
        
        currentController.trailer.showLoadingScreen()
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
    
    // MARK: Actions
    
    @IBAction func userDidTapLeftActiveSection(_ sender: Any) {
        player.goPrevious()
    }
    
    @IBAction func userDidTapRightActiveSection(_ sender: Any) {
        player.goNext()
    }
    
    
}

extension PrimeTimeViewController : PreloadingManagerDelegate {
    
    func didPreload(_ asset: Asset) {
        if let currentAsset = self.manager?.currentAsset, currentAsset === asset, didStartPlayback {
            DispatchQueue.main.async { [unowned self] in
                self.currentController.trailer.hideLoadingScreen()
                self.player.play()
            }
        }
    }
    
    func managerIsReadyForPlayback() {
        didStartPlayback = true
        DispatchQueue.main.async { [unowned self] in
            log.debug("Finished buffering minimum required assets!!!")
            self.currentController.trailer.hideLoadingScreen()
            self.player.play()
        }
    }
    
    var playingIndex: Int {
        return player.currentIndex
    }
    
}
