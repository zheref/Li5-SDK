//
//  VideoViewController.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 6/8/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit


protocol VideoViewControllerProtocol : Displayable {
    
//    - (void)setPriority:(BCPriority)priority;
//    
//    - (BCPlayer *)getPlayer;
    
    
    
}


class VideoViewController : UIViewController, VideoViewControllerProtocol, UIGestureRecognizerDelegate {
    
    // MARK: - PUBLIC INTERFACE
    
    // MARK: - Stored Properties
    
    var product: Product!
    
    var teaserViewController: TeaserViewController!
    var unlockedViewController: UnlockedViewController?
    
    var currentViewController: UIViewController?
    
    // MARK: - Computed Properties
    
    
    var player: BCPlayer {
        return teaserViewController.getPlayer()
    }
    
    
    // MARK: - Initializers
    
    
    required init(withProduct product: Product, andContext context: PContext) {
        self.product = product
        
        teaserViewController = TeaserViewController(product: self.product,
                                                    andContext: context.legacyVersion)
        
        if product.videoURL != nil && !product.videoURL.isEmpty {
            //  unlockedViewController = [UnlockedViewController unlockedWithProduct:self.product andContext:ctx];
        }
        
        currentViewController = nil
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Routines
    
    
    func setPriority(_ priority: BCPriority) {
        teaserViewController.setPriority(priority)
    }
    
    
    // MARK: - Lifecycle
    
    
    override func viewDidLoad() {
        log.verbose("VideoViewController did load for product id: \(product.id)")
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = UIColor.red
        
        present(viewController: teaserViewController, withAppearanceTransition: false)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentViewController?.beginAppearanceTransition(true, animated: animated)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        log.verbose("VideoViewController did appear for product id: \(product.id)")
        super.viewDidAppear(animated)
        
        currentViewController?.endAppearanceTransition()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentViewController?.beginAppearanceTransition(false, animated: animated)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        log.verbose("VideoViewController did disappear for product id: \(product.id)")
        super.viewDidDisappear(animated)
        
        currentViewController?.endAppearanceTransition()
    }
    
    
    // From the container view controller (???)
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        log.verbose("VideoViewController did receive memory warning: \(product.id)")
        super.didReceiveMemoryWarning()
    }
    
    
    deinit {
        log.verbose("Deinitializing VideoViewController for product with id: \(product.id)")
        
        teaserViewController = nil
        unlockedViewController = nil
        currentViewController = nil
    }
    
    // MARK: - PRIVATE INTERFACE
    
    
    /// Present the given view controller calling the appearance methods and keeping the reference
    /// into the currentViewController variable
    /// - Parameters:
    ///   - vc: The viewController willing to present
    ///   - appearance: Whether it's appearing or not
    func present(viewController vc: UIViewController, withAppearanceTransition appearance: Bool) {
        log.debug("Presenting VC from VideoViewController \(product.id)")
        
        vc.willMove(toParentViewController: self)
        addChildViewController(vc)
        vc.view.frame = view.bounds
        view.alpha = 1.0
        
        if appearance == true {
            vc.beginAppearanceTransition(true, animated: false)
        }
        
        view.addSubview(vc.view)
        
        if appearance == true {
            vc.endAppearanceTransition()
        }
        
        vc.didMove(toParentViewController: self)
        
        currentViewController = vc
    }
    
    
    /// Unpresents (dismisses) the given view controller calling the appearance methods and
    /// forcing its complete disappearance in case a true force flag is passed
    /// - Parameters:
    ///   - vc: The viewController willing to unpresent
    ///   - appearance: Whether it's appearing or not (???)
    ///   - force: Whether we need to force its complete disappearance or not
    func unpresent(viewController vc: UIViewController,
                   withAppearanceTransition appearance: Bool,
                   byForcing force: Bool) {
        
        log.debug("Unpresenting VC from VideoViewController \(product.id)")
        
        vc.willMove(toParentViewController: nil)
        
        if appearance == true {
            vc.beginAppearanceTransition(false, animated: false)
        }
        
        if force {
            vc.view.removeFromSuperview()
        } else {
            vc.view.alpha = 0.5
        }
        
        if appearance == true {
            vc.endAppearanceTransition()
        }
        
        if force {
            vc.removeFromParentViewController()
        }
        
        vc.didMove(toParentViewController: nil)
    }
    
    
    func userDidLongTap(_ recognizer: UITapGestureRecognizer) {
        log.verbose("User did long tap")
        
//        unlockedViewController.initialPoint = [sender locationInView:teaserViewController.view];
//        
//        unlockedViewController.providesPresentationContextTransitionStyle = true;
//        unlockedViewController.definesPresentationContext = true;
//        unlockedViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
//        
//        [self showViewController:unlockedViewController withAppearanceTransition:YES];
//        [self hideViewController:teaserViewController withAppearanceTransition:YES force:NO];
    }
    
    
    func userDidTapForLock(_ recognizer: UITapGestureRecognizer) {
        log.verbose("User did tap for lock")
        
//        [self hideViewController:unlockedViewController withAppearanceTransition:YES force:YES];
//        [self showViewController:teaserViewController withAppearanceTransition:YES];
    }
    
}