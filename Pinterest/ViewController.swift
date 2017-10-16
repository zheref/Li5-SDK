//
//  ViewController.swift
//  Pinterest
//
//  Created by Sergio Daniel on 10/15/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import Li5SDK

class ViewController: UIViewController {
    
    @IBOutlet weak var animationImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: "PINTEREST", withExtension: "gif") {
            animationImageView.image = UIImage.animatedImage(withAnimatedGIFURL: url)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
            Li5SDK.shared.present()
            self?.animationImageView.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

