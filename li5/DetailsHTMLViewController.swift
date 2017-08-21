//
//  DetailsHTMLViewController.swift
//  li5
//
//  Created by Martin Cocaro on 3/23/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import WebKit

@objc class DetailsHTMLViewController: UIViewController {

    fileprivate var webView: WKWebView?
    
    var product : ProductModel! {
        didSet {
            resetView()
            loadUrl()
        }
    }
    
    convenience init(withProduct product: ProductModel) {
        self.init()
        self.product = product
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetView()
        loadUrl()
    }
    
    private func resetView() {
        if webView != nil {
            webView?.removeFromSuperview()
            webView = nil
        }
        
        webView = WKWebView()
        webView?.frame = view.bounds
        
        if webView != nil {
            view.addSubview(webView!)
        }
    }
    
    private func loadUrl() {
        let url = product.detailsUrl
        
        webView?.load(URLRequest(url: Foundation.URL(string: "about:blank")!))
        
        if url != nil {
            let req = URLRequest(url: url!)
            webView?.load(req)
        }
    }

}
