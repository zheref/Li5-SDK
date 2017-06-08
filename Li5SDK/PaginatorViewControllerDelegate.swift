//
//  PageViewControllerDelegate.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/7/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit


public protocol PaginatorViewControllerDelegate {
    func isSwitching(toPage newPage: UIViewController!, fromPage oldPage: UIViewController!, progress: CGFloat)
    
    func didFinishSwitchingPage(_ finished: Bool)
}
