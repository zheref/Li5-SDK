//
//  ViewController.swift
//  Inmigrant141
//
//  Created by Sergio Daniel on 10/17/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import Li5SDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Li5SDK.shared.present()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

