//
//  DetailsHTMLViewController.swift
//  li5
//
//  Created by Martin Cocaro on 3/23/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import WebKit

@objc public class DetailsHTMLViewController: UIViewController {

    private var webView: WKWebView?
    
    var product : Product!
    var context : ProductContext!
    
    public convenience init(withProduct product: Product, andContext context:ProductContext) {
        self.init()
        
        self.product = product
        self.context = context
    }
    
    public override func loadView() {
        webView = WKWebView()
        
        view = webView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = (self.product.contentUrl != nil) ? NSURL(string:self.product.contentUrl) : NSURL(string: "https://www.li5.tv")
        let req = NSURLRequest(URL: url!)
        webView?.loadRequest(req)
    }

    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
