//
//  ViewController.swift
//  QVC
//
//  Created by Sergio Daniel on 10/15/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import Li5SDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func userDidTapHolidayGifts(_ sender: Any) {
        Li5SDK.shared.present()
    }

}

