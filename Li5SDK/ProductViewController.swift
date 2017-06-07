//
//  ProductViewController.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/6/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

@objc public class ProductViewController : Li5UIPageViewController, DisplayableProtocol {
    
    public var product: Product!
    
    
    public required init!(product thisProduct: Product!, andContext ctx: ProductContext) {
        log.info("Creating ProductVC for product with title \(thisProduct.title)")
        
        super.init(direction: Li5UIPageViewControllerDirectionVertical)
        
        self.product = thisProduct
        
        let lastProduct = self.product.isAd ||
            (self.product.type.caseInsensitiveCompare("url") == ComparisonResult.orderedSame && self.product.contentUrl == nil)
        
        if lastProduct {
            viewControllers = [
                VideoViewController(product: self.product, andContext: ctx)
            ]
        } else {
            viewControllers = [
                VideoViewController(product: self.product, andContext: ctx),
                
                self.product.type.caseInsensitiveCompare("url") == ComparisonResult.orderedSame ?
                    DetailsHTMLViewController(withProduct: self.product, andContext: ctx) :
                    DetailsViewController(product: self.product, andContext: ctx)
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
        currentViewController.view.frame = view.bounds
    }
    
    
    deinit {
        SDKLogger.shared.debug("Deinitializing ProductVC for: \(product.title)")
    }
    
    
    public override func didReceiveMemoryWarning() {
        SDKLogger.shared.warning("Received memory warning in ProductVC for: \(product.title)")
        super.didReceiveMemoryWarning()
    }
    
}
