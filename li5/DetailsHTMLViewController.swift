//
//  DetailsHTMLViewController.swift
//  li5
//
//  Created by Martin Cocaro on 3/23/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import WebKit

class DetailsHTMLViewController: UIViewController {

    private var webView: WKWebView?
    
    var product : Product!
    var context : ProductContext!
    
    convenience init(withProduct product: Product, andContext context:ProductContext) {
        self.init()
        
        self.product = product
        self.context = context
    }
    
    override func loadView() {
        webView = WKWebView()
        
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = (self.product.contentUrl != nil) ? NSURL(string:self.product.contentUrl) : NSURL(string: "https://www.li5.tv")
//        let url = NSURL(string: "https://www.li5.tv")
        let req = NSURLRequest(URL: url!)
        webView?.loadRequest(req)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
