//
//  DetailsHTMLViewController.swift
//  li5
//
//  Created by Martin Cocaro on 3/23/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import WebKit

@objc open class DetailsHTMLViewController: UIViewController {

    fileprivate var webView: WKWebView?
    
    var product : Product!
    var context : ProductContext!
    
    public convenience init(withProduct product: Product, andContext context:ProductContext) {
        self.init()
        
        self.product = product
        self.context = context
    }
    
    open override func loadView() {
        webView = WKWebView()
        
        view = webView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = (self.product.contentUrl != nil) ? URL(string:self.product.contentUrl) : URL(string: "https://www.li5.tv")
        let req = URLRequest(url: url!)
        webView?.load(req)
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
