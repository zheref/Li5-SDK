//
//  ProductViewController.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/6/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

import BCVideoPlayer

@objc class ProductPageViewController : PaginatorViewController, Displayable {
    
    public var product: Product!
    
    
    public required init(withProduct product: Product, andContext context: PContext) {
        log.info("Creating ProductVC for product with id \(product.id ?? "nil")")
        
        super.init(withDirection: .Vertical)
        
        self.product = product
        
        let lastProduct = self.product.isAd ||
            (self.product.type.caseInsensitiveCompare("url") == ComparisonResult.orderedSame && self.product.contentUrl == nil)
        
        if lastProduct {
            preloadedViewControllers = [
                VideoViewController(withProduct: self.product, andContext: context)
            ]
        } else {
            preloadedViewControllers = [
                VideoViewController(withProduct: self.product, andContext: context),
                
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
        log.debug("Product page vc did load: \(product.id ?? "nil")")
        view.backgroundColor = UIColor.yellow
        super.viewDidLoad()
    }
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log.debug("Product page vc did appear: \(product.id ?? "nil")")
    }
    
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    public func setPriority(_ priority: BCPriority) {
        if let videoVC = preloadedViewControllers.first as? VideoViewController {
            videoVC.setPriority(priority)
        }
    }
    
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        currentViewController?.view.frame = view.bounds
    }
    
    
    override func viewDidLayoutSubviews() {
        log.debug("viewDidLayoutSubviews")
        super.viewDidLayoutSubviews()
    }
    
    
    deinit {
        log.debug("Deinitializing ProductVC for: \(product.id ?? "nil")")
    }
    
    
    public override func didReceiveMemoryWarning() {
        log.warning("Received memory warning in ProductVC for: \(product.id ?? "nil")")
        super.didReceiveMemoryWarning()
    }
    
}
