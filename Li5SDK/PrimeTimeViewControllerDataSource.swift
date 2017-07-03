//
//  PrimeTimeDataSource.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/6/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit

typealias ProductsReturner = ([Product]) -> Void

public enum PContext : UInt {
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


@objc class PrimeTimeViewControllerDataSource : NSObject, PaginatorViewControllerDataSource {
    
    // MARK: - PUBLIC INTERFACE
    
    
    override init() {
        
    }
    
    
    func fetchProducts(returner: @escaping ProductsReturner, handler: @escaping ErrorReturner) {
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let li5 = Li5ApiHandler.sharedInstance() else {
                log.error("No instance available for Li5 API Services")
                return
            }
            
            li5.requestDiscoverProducts() { [weak self] (error, products) in
                if let error = error {
                    log.error("Error while fetching products: \(error)")
                    handler(error)
                } else if let products = products {
                    log.info("\(products.data.count) fetched products")
                    log.verbose(products)
                    
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
    
    
    func productPageViewController(atIndex index: Int) -> ProductPageViewController {
        let product = products[index]
        log.verbose("Delivering new instance of ProductViewController for product with id \(product.id ?? "nil")")
        return ProductPageViewController(withProduct: product, andContext: PContext.Discover)
    }
    
    
    func lastPageViewController() -> LastPageViewController {
        let storyboard = UIStoryboard(name: KUI.SB.DiscoverViews.rawValue, bundle: Bundle(for: PrimeTimeViewControllerDataSource.self))
        
        let vc = storyboard.instantiateViewController(withIdentifier: KUI.VC.LastPage.rawValue) as! LastPageViewController
        vc.scrollPageIndex = products.count
        vc.lastVideoUrl = endOfPrimeTime
        
        return vc
    }
    
    
    // MARK: - PRIVATE INTERFACE
    
    private var expirationTimer: Timer?
    
    private var expiration: Date?
    
    private var products = [Product]() {
        didSet {
            for product in products {
                if let url = Foundation.URL(string: product.trailerURL) {
                    PlaybackManager.shared.append(url: url)
                } else {
                    log.error("Wasn't able to parse into URL: \(product.trailerURL)")
                }
            }
            
            PlaybackManager.shared.printEnqueuedItems()
        }
    }
    
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
        if let viewController = viewController as? ProductPageViewController {
            let index = viewController.scrollPageIndex
            
            if index >= products.count || index == NSNotFound {
                log.verbose("No more viewcontrollers to deliver. Exceeded amount of products.")
                return nil
            } else {
                log.verbose("Delivered next viewcontroller")
                return productPageViewController(atIndex: index + 1)
            }
        } else {
            return nil
        }
    }
    
    
    func viewControllerViewController(at index: Int) -> UIViewController? {
        if index < 0 || index >= products.count || index == NSNotFound {
            if index == products.count {
                log.debug("No more viewcontrollers to deliver. Delivering LastPage")
                return lastPageViewController()
            } else {
                log.verbose("No more viewcontrollers to deliver. Index below 0 or above products count")
                return nil
            }
        } else {
            return productPageViewController(atIndex: index)
        }
    }
    
}
