//
//  ProductViewController.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/6/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation


protocol ProductPageViewControllerProtocol : PageIndexedProtocol {
    
}


class ProductPageViewController : PaginatorViewController, ProductPageViewControllerProtocol {
    
    // MARK: - INSTANCE MEMBERS
    
    // MARK: - Properties
    
    // MARK: Stored Properties
    
    public var product: Product?
    
    // MARK: Computed Properties
    
    /// Index of the represented model object inside the main data source
    public var pageIndex: Int {
        return scrollPageIndex
    }
    
    var vcIdentity: String {
        if let product = product {
            return "\(scrollPageIndex):\(product.id ?? "nil")"
        } else {
            return "\(scrollPageIndex):"
        }
    }
    
    
    public required init(withProduct product: Product, pageIndex: Int, andContext context: PContext) {
        log.info("Creating ProductVC for product with id \(product.id ?? "nil")")
        
        self.product = product
        
        super.init(withDirection: .Vertical)
        
        self.scrollPageIndex = pageIndex
        
        guard let product = self.product else {
            log.error("This should have not entered here. Just assigned product value for ProductPage.")
            return
        }
        
        let lastProduct = product.isAd ||
            (product.type.caseInsensitiveCompare("url") == ComparisonResult.orderedSame && product.contentUrl == nil)
        
        if lastProduct {
            preloadedViewControllers = [
                VideoViewController(product: product, context: context, pageIndex: scrollPageIndex)
            ]
        } else {
            preloadedViewControllers = [
                VideoViewController(product: product, context: context, pageIndex: scrollPageIndex),
                
                product.type.caseInsensitiveCompare("url") == ComparisonResult.orderedSame ?
                    DetailsHTMLViewController(withProduct: product, andContext: context.legacyVersion) :
                    DetailsViewController(product: product, andContext: context.legacyVersion)
            ]
        }
    }
    
    override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        log.warning("ProductPageViewController initialized through coder. There will most likely be crashes!!!")
        super.init(coder: aDecoder)
    }
    
    // MARK: - LIFECYCLE
    
    public override func viewDidLoad() {
        log.verbose("Product page vc did load: \(vcIdentity)")
        view.backgroundColor = UIColor.yellow
        super.viewDidLoad()
    }
    
    
    public override func viewDidAppear(_ animated: Bool) {
        log.verbose("Product page vc did appear: \(vcIdentity)")
        super.viewDidAppear(animated)
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
    
    
    deinit {
        log.verbose("Deinitializing ProductVC for: \(vcIdentity)")
    }
    
    
    public override func didReceiveMemoryWarning() {
        log.warning("Received memory warning in ProductVC for: \(vcIdentity)")
        super.didReceiveMemoryWarning()
    }
    
}
