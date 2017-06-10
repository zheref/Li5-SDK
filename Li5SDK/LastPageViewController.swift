//
//  LastPageViewController.swift
//  li5
//
//  Created by Sergio Daniel L. García on 6/10/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation


protocol LastPageViewControllerProtocol {
    
    var content: EndOfPrimeTime { get set }
    
}


class LastPageVC : ProductPageViewController {
    
    // MARK: - CLASS MEMBERS
    
    static func instance(content: EndOfPrimeTime) {
        
    }
    
    // MARK: - INSTANCE MEMBERS
    
    // MARK: - Stored Properties
    
    
    
}


extension LastPageVC : UIGestureRecognizerDelegate {
    
    
    
}


extension LastPageVC : BCPlayerDelegate {
    
    func readyToPlay() {
        
    }
    
    
    func failToLoadItem(_ error : NSError) {
        
    }
    
    
    func networkFail(_ error : NSError) {
        
    }
    
    
    func bufferEmpty() {
        
    }
    
    
    func bufferReady() {
        
    }
    
}
