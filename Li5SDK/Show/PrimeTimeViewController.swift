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
    
    // MARK: Stored Properties
    
    var currentController: PlayPageViewController!
    
    var products = [ProductModel]()
    
    var player: PlayerProtocol!
    var manager: PreloadingManagerProtocol!
    var bufferer: BufferPreloaderProtocol!
    var downloader: DownloadPreloaderProtocol?
    
    // MARK: Computed Properties
    
    var playerLayer: AVPlayerLayer? {
        return currentController.trailerVC.layer
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
        
        currentController = PlayPageViewController(withProduct: products[player.currentIndex],
                                                   player: player,
                                                   manager: manager)
        currentController.view.frame = view.bounds
        view.insertSubview(currentController.view, at: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let multiPlayer = player as? MultiPlayer {
            multiPlayer.delegate = currentController.trailerVC
        }
        
        player.settle()
        
        currentController.startPreloading()
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
    
    // MARK: Actions
    
    @IBAction func userDidTapLeftActiveSection(_ sender: Any) {
        player.goPrevious()
        currentController.product = products[player.currentIndex]
    }
    
    @IBAction func userDidTapRightActiveSection(_ sender: Any) {
        player.goNext()
        currentController.product = products[player.currentIndex]
    }
    
    
}
