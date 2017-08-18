//
//  Displayable.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/7/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

protocol Displayable {
    
    var product: ProductModel { get set }
    
    init(product: ProductModel)
    
}
