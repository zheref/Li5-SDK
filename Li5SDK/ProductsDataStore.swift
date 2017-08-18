//
//  ProductsDataStore.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/18/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

public typealias ProductsReturner = ([ProductModel]) -> Void

public class ProductsDataStore {
    
    public static var shared: ProductsDataStore = {
        return ProductsDataStore()
    }()
    
    private init() {}
    
    func asynchronouslyLoadProducts(_ returner: @escaping ProductsReturner) {
        
        DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
            guard let li5 = Li5ApiHandler.sharedInstance() else {
                log.error("No instance available for Li5 API Services")
                return
            }
            
            li5.requestDiscoverProducts() { [unowned self] (error, products) in
                
                if let error = error {
                    log.error("Error while fetching products: \(error)")
                } else if let products = products {
                    log.info("\(products.data.count) fetched products")
                    
                    let products = products.data as? [Product] ?? [Product]()
                    //this.endOfPrimeTime = products.endOfPrimeTime
                    log.info("Products set successfully")
                    
                    returner(products.map({ [unowned self] (product) -> ProductModel in
                        return self.toModel(product)
                    }))
                } else {
                    log.error("No retrieved products")
                }
                
            }
        }
        
    }
    
    private func toModel(_ product: Product) -> ProductModel {
        var pm = ProductModel()
        
        if let url = Foundation.URL(string: product.trailerURL) {
            pm.url = url
        } else { log.error("Couldn't parse URL for trailer") }
        
//        if let url = Foundation.URL(string: product.contentUrl) {
//            pm.detailsUrl = url
//        } else { log.error("Couldn't parse URL for content/details") }
        
        pm.poster = product.trailerPosterPreview
        pm.categoryName = product.categoryName
        
        return pm
    }
    
}
