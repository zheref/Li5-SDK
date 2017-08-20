//
//  PageViewController.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation


protocol PageViewControllerProtocol {
    
}


class PageViewController : PaginatorViewController, PageViewControllerProtocol {
    
    // MARK: - Stored Properties
    
    public var product: ProductModel!
    
    // TODO: UNSAFE
    var trailer: TrailerViewController!
    
    // MARK: - Initializers
    
    public required init(withProduct product: ProductModel) {
        self.product = product
        
        super.init(withDirection: .Vertical)
        
        guard let product = self.product else {
            log.error("This should have not entered here. Just assigned product value for ProductPage.")
            return
        }
        
        trailer = TrailerViewController.instance(withProduct: self.product)
        
        preloadedViewControllers = [
            trailer!,
            DetailsHTMLViewController(withProduct: product)
        ]
    }
    
    override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        log.warning("ProductPageViewController initialized through coder. There will most likely be crashes!!!")
        super.init(coder: aDecoder)
    }
    
    // MARK: - LIFECYCLE
    
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
    
}
