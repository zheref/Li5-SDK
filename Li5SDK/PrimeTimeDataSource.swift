//
//  PrimeTimeDataSource.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/6/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit

typealias ProductsReturner = ([Product]) -> Void

enum PContext : UInt {
    case Discover
    case Search
    
    var legacyVersion: ProductContext {
        switch self {
        case .Discover:
            return ProductContext.discover
        case .Search:
            return ProductContext.search
        }
    }
}


@objc class PrimeTimeDataSource : NSObject, PageViewControllerDataSource {
    
    // MARK: - PUBLIC INTERFACE
    
    
    override init() {
        
    }
    
    
    func fetchProducts(withReturner returner: @escaping ProductsReturner, andHandler handler: @escaping ErrorReturner) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let li5 = Li5ApiHandler.sharedInstance() else {
                log.error("No instance available for Li5 API Services")
                return
            }
            
            li5.requestDiscoverProducts() { [weak self] (error, products) in
                if let error = error {
                    log.error("Error while fetching products: \(error.localizedDescription)")
                    handler(error)
                } else if let products = products {
                    log.debug("\(products.data.count) fetched products")
                    log.debug(products)
                    
                    if products.data.count > 0 {
                        if let this = self {
                            this.products = products.data as? [Product] ?? [Product]()
                            this.endOfPrimeTime = products.endOfPrimeTime
                            log.info("Products and EOPT set successfully")
                            returner(this.products)
                        } else {
                            log.warning("Lost reference to self after products have been fetched")
                        }
                    } else {
                        log.warning("0 retrieved products")
                    }
                } else {
                    log.error("No retrieved products")
                }
            }
        }
    }
    
    
    func productPageViewController(atIndex index: Int) -> ProductViewController {
        let product = products[index]
        log.debug("Delivering new instance of ProductViewController for product with id \(product.id)")
        return ProductViewController(product: product, andContext: PContext.Discover.legacyVersion)
    }
    
    
    func productPageViewController(atIndex index: Int, withPriority priority: BCPriority) -> ProductViewController {
        let productViewController = productPageViewController(atIndex: index)
        productViewController.setPriority(priority)
        return productViewController
    }
    
    
    // MARK: - PRIVATE INTERFACE
    
    private var expirationTimer: Timer?
    
    private var expiration: Date?
    
    private var products = [Product]()
    
    private var endOfPrimeTime: EndOfPrimeTime?
    
    
    @objc func applicationWillResignActiveNotification(_ notification: Notification?) {
        log.info("Application will resign active...")
        
        disableExpirationTimer()
    }
    
    
    func disableExpirationTimer() {
        log.info("Disabling expiration timer")
        
        if let expirationTimer = expirationTimer,
            expirationTimer.isValid {
            expirationTimer.invalidate()
            self.expirationTimer = nil
        }
    }
    
    
    // MARK: - Li5UIPageViewControllerDataSource
    
    var pagesCount: Int {
        return products.count
    }
    
    
    func viewController(before viewController: UIViewController!) -> UIViewController? {
        let index = viewController.scrollPageIndex
        
        if index == 0 || index == NSNotFound {
            return nil
        } else {
            return productPageViewController(atIndex: index - 1)
        }
    }
    
    
    func viewController(after viewController: UIViewController!) -> UIViewController? {
        if let viewController = viewController as? ProductViewController {
            let index = viewController.scrollPageIndex
            
            if index >= products.count || index == NSNotFound {
                log.debug("No more viewcontrollers to deliver. Exceeded amount of products.")
                return nil
            } else {
                log.debug("Delivered next viewcontroller")
                return productPageViewController(atIndex: index + 1)
            }
        } else {
            return nil
        }
    }
    
    
    func viewControllerViewController(at index: Int) -> UIViewController? {
        if index < 0 || index > products.count || index == NSNotFound {
            log.debug("No more viewcontrollers to deliver. Index below 0.")
            return nil
        } else {
            return productPageViewController(atIndex: index)
        }
    }
    
}
