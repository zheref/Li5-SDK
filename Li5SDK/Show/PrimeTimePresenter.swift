//
//  PrimeTimePresenter.swift
//  li5
//
//  Created by Sergio Daniel on 9/20/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

protocol PrimeTimePresenterProtocol {
    init(view: PrimeTimeViewControllerProtocol)
}

class PrimeTimePresenter : PrimeTimePresenterProtocol {
    
    unowned let view: PrimeTimeViewControllerProtocol
    
    required init(view: PrimeTimeViewControllerProtocol) {
        self.view = view
    }
    
}
