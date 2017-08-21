//
//  PageViewController.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation
import AVFoundation


protocol PageViewControllerProtocol {
    
}


class PlayPageViewController : PaginatorViewController, PageViewControllerProtocol {
    
    // MARK: - Stored Properties
    
    weak var player: PlayerProtocol!
    weak var manager: PreloadingManagerProtocol!
    
    var product: ProductModel! {
        didSet {
            trailerVC.product = product
            htmlVC.product = product
        }
    }
    
    var trailerVC: TrailerViewController!
    var htmlVC: DetailsHTMLViewController!
    
    var didStartPlayback = false
    
    // MARK: - Initializers
    
    public required init(withProduct product: ProductModel, player: PlayerProtocol, manager: PreloadingManagerProtocol) {
        self.product = product
        self.player = player
        self.manager = manager
        
        trailerVC = TrailerViewController.instance(withProduct: self.product)
        htmlVC = DetailsHTMLViewController(withProduct: product)
        
        super.init(withDirection: .Vertical)
        
        preloadedViewControllers = [trailerVC, htmlVC]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        log.warning("ProductPageViewController initialized through coder. There will most likely be crashes!!!")
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        currentViewController?.view.frame = view.bounds
    }
    
    override func viewDidLayoutSubviews() {
        log.verbose("viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Routines
    
    func startPreloading() {
        if let currentPlayer = player.currentPlayer {
            trailerVC.set(player: currentPlayer)
        }
        
        manager.delegate = self
        manager.startPreloading()
        trailerVC.showLoadingScreen()
    }
    
}

extension PlayPageViewController : PreloadingManagerDelegate {
    
    func didPreload(_ asset: Asset) {
        if let currentAsset = self.manager?.currentAsset, currentAsset === asset, didStartPlayback {
            DispatchQueue.main.async { [unowned self] in
                self.trailerVC.hideLoadingScreen()
                self.player.play()
            }
        }
    }
    
    func managerIsReadyForPlayback() {
        didStartPlayback = true
        
        DispatchQueue.main.async { [unowned self] in
            log.debug("Finished buffering minimum required assets!!!")
            self.trailerVC.hideLoadingScreen()
            self.player.play()
        }
    }
    
    var playingIndex: Int {
        return player.currentIndex
    }
    
}
