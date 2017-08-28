//
//  PageViewController.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation
import AVFoundation

protocol PlayPageViewControllerProtocol {
    var product: ProductModel! { get set }
    var delegate: PlayPageViewControllerDelegate? { get set }
}

protocol PlayPageViewControllerDelegate : class {
    func readyForPlayback()
    var visibleToPlay: Bool { get }
}

class PlayPageViewController : PaginatorViewController, PlayPageViewControllerProtocol {
    
    weak var player: PlayerProtocol!
    weak var manager: PreloadingManagerProtocol!
    
    var trailerVC: TrailerViewController!
    var htmlVC: DetailsHTMLViewController!
    
    var didStartPlayback = false
    
    weak var delegate: PlayPageViewControllerDelegate?
    
    var product: ProductModel! {
        didSet {
            trailerVC.product = product
            htmlVC.product = product
        }
    }
    
    public required init(withProduct product: ProductModel,
                         player: PlayerProtocol,
                         manager: PreloadingManagerProtocol) {
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
    
    override func moveTo(pageIndex targetPageIndex: Int) {
        if targetPageIndex == 1 {
            player.pause()
        } else {
            if let cp = player.currentPlayer {
                if cp.isPlaying == false {
                    player.play()
                }
            }
        }
        
        super.moveTo(pageIndex: targetPageIndex)
    }
    
    func startPreloading() {
        manager.delegate = self
        manager.startPreloading()
        
        if let currentPlayer = player.currentPlayer {
            trailerVC.set(player: currentPlayer)
        }
        
        trailerVC.showLoadingScreen()
    }
    
}

extension PlayPageViewController : PreloadingManagerDelegate {
    
    func didPreload(_ asset: Asset) {
        if let currentAsset = self.manager?.currentAsset, currentAsset === asset, didStartPlayback {
            DispatchQueue.main.async { [unowned self] in
                self.trailerVC.hideLoadingScreen()

                self.player.automaticallyReplay = self.player.automaticallyReplay
                
                guard let delegate = self.delegate else { return }
                
                if delegate.visibleToPlay {
                    self.player.play()
                }
                
                if let cp = self.player.currentPlayer {
                    self.trailerVC.set(player: cp)
                }
                
            }
        }
    }
    
    func managerIsReadyForPlayback() {
        didStartPlayback = true
        
        DispatchQueue.main.async { [unowned self] in
            log.debug("Finished buffering minimum required assets!!!")
            self.trailerVC.hideLoadingScreen()
            self.delegate?.readyForPlayback()
            self.player.play()
            self.player.automaticallyReplay = self.player.automaticallyReplay
            
            if let cp = self.player.currentPlayer {
                self.trailerVC.set(player: cp)
            }
        }
    }
    
    var playingIndex: Int {
        return player.currentIndex
    }
    
}
