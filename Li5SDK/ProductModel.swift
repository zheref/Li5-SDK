//
//  ProductModel.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/17/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

struct ProductModel {
    
    var id = -1
    
    var title = "Title"
    var categoryName: String? = "Category"
    var url: Foundation.URL?
    
    var detailsUrl: Foundation.URL?
    var extendedUrl: Foundation.URL?
    
    var poster: String?
    
    var isAd = false
    
}
