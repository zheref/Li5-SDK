//
//  ProductViewController.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/6/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

import BCVideoPlayer

@objc public class ProductPageViewController : PaginatorViewController, Displayable {
    
    public var product: Product!
    
    
    public required init(withProduct product: Product, andContext context: PContext) {
        log.info("Creating ProductVC for product with title \(product.title)")
        
        super.init(withDirection: .Vertical)
        
        self.product = product
        
        let lastProduct = self.product.isAd ||
            (self.product.type.caseInsensitiveCompare("url") == ComparisonResult.orderedSame && self.product.contentUrl == nil)
        
        if lastProduct {
            viewControllers = [
                VideoViewController(product: self.product, andContext: context.legacyVersion)
            ]
        } else {
            viewControllers = [
                VideoViewController(product: self.product, andContext: context.legacyVersion),
                
                self.product.type.caseInsensitiveCompare("url") == ComparisonResult.orderedSame ?
                    DetailsHTMLViewController(withProduct: self.product, andContext: context.legacyVersion) :
                    DetailsViewController(product: self.product, andContext: context.legacyVersion)
            ]
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LIFECYCLE
    
    public override func viewDidLoad() {
        SDKLogger.shared.debug("ProductVC did load: \(product.title)")
        super.viewDidLoad()
    }
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SDKLogger.shared.debug("ProductVC did appear: \(product.title)")
    }
    
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    public func setPriority(_ priority: BCPriority) {
        if let videoVC = viewControllers.first as? VideoViewController {
            videoVC.setPriority(priority)
        }
    }
    
    
    public var player: BCPlayer? {
        if let videoVC = currentViewController as? VideoViewController {
            return videoVC.getPlayer()
        } else {
            return nil
        }
    }
    
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        currentViewController?.view.frame = view.bounds
    }
    
    
    deinit {
        SDKLogger.shared.debug("Deinitializing ProductVC for: \(product.title)")
    }
    
    
    public override func didReceiveMemoryWarning() {
        SDKLogger.shared.warning("Received memory warning in ProductVC for: \(product.title)")
        super.didReceiveMemoryWarning()
    }
    
}
