//
//  PageIndexedProtocol.swift
//  li5
//
//  Created by Sergio Daniel on 7/2/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

protocol PageIndexedProtocol {
    
    /// Index of the represented model object inside the main data source
    var pageIndex: Int { get }
    
}
