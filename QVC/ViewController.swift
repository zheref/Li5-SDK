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
    
    @IBOutlet weak var animationImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = Bundle.main.url(forResource: "QVC", withExtension: "gif") {
            animationImageView.image = UIImage.animatedImage(withAnimatedGIFURL: url)
            backgroundImageView.isHidden = true
            animationImageView.isHidden = false
        }
        
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) { [weak self] in
            self?.animationImageView.isHidden = true
            self?.backgroundImageView.isHidden = false
        }
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

