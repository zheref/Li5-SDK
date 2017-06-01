//
//  ViewController.swift
//  DemoSDK
//
//  Created by Sergio Daniel L. García on 5/3/17.
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

    @IBAction func userDidTapTriggerSDKButton(sender: AnyObject) {
        Li5SDK.shared.present()
    }

}

