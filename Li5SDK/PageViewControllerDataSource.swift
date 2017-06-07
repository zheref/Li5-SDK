//
//  PageViewControllerDataSource.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/7/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit


public protocol PageViewControllerDataSource : NSObjectProtocol {
    var pagesCount: Int { get }
    
    func viewController(before viewController: UIViewController!) -> UIViewController?
    
    func viewController(after viewController: UIViewController!) -> UIViewController?
    
    func viewControllerViewController(at index: Int) -> UIViewController?
}
