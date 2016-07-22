//
//  TapAndHoldViewController.swift
//  AnimationText
//
//  Created by Martin Adoue on 2016/07/12.
//  Copyright © 2016 Ubernerden. All rights reserved.
//

import UIKit
import pop

extension CGFloat {
    static func random(positive: Bool = false) -> CGFloat {
        let random = CGFloat(arc4random()) / CGFloat(UInt32.max)
        if positive {
            return random
        }
        else {
            return random * (Bool.random() ? 1 : -1)
        }
    }
}

extension Bool {
    static func random() -> Bool {
        return arc4random_uniform(2) == 1
    }
}

func delay(delay: Double, queue: dispatch_queue_t = dispatch_get_main_queue(), closure: ()->()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), queue, closure)
}

@objc public protocol TapAndHoldViewControllerDelegate: class {
    func handleLongTap(sender: UILongPressGestureRecognizer)
}

class TapAndHoldViewController: UIViewController {
    
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak var subtitleLabel : UILabel!
    @IBOutlet weak var colorsImageView : UIImageView!
    @IBOutlet weak var bucketImageView : UIImageView!
    @IBOutlet weak var dynamicContainer : UIView!
    private var longTapGestureRecognizer : UILongPressGestureRecognizer!
    weak var gestureDelegate : TapAndHoldViewControllerDelegate?
    
    var kernels = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for view in [self.titleLabel, self.subtitleLabel, self.colorsImageView, self.bucketImageView] {
            view.hidden = true
        }
        
        for i in 1..<14 {
            let name = "popcorn\(i)"
            let view = UIImageView(image: UIImage(named: name))
            view.hidden = true
            self.view.insertSubview(view, aboveSubview: self.colorsImageView)
            self.kernels.append(view)
        }
        
        self.longTapGestureRecognizer = UILongPressGestureRecognizer(target: self.gestureDelegate!, action: #selector(handleLongTap))
        self.longTapGestureRecognizer.minimumPressDuration = 1.0
        self.longTapGestureRecognizer.allowableMovement = 100.0
        
        self.view.addGestureRecognizer(self.longTapGestureRecognizer)
    }
    
    func handleLongTap(gesture: UILongPressGestureRecognizer) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.startAnimationSequence()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @objc private func startAnimationSequence() {
        let bounds = UIScreen.mainScreen().bounds

        var center = bounds.center
        center.y = bounds.height + 100
        for kernel in kernels {
            var s = center
            s.x += CGFloat.random() * 30
            s.y += CGFloat.random() * 30
            kernel.center = s
            kernel.hidden = false
            
            let position = POPDecayAnimation(propertyNamed: "position")
            position.velocity = NSValue(CGPoint: CGPoint(x: bounds.width * 2 * CGFloat.random(), y: -(bounds.height * 2.7)))
            position.beginTime = CACurrentMediaTime() + max((Double)(CGFloat.random()), 0.4)
            kernel.layer.pop_addAnimation(position, forKey: "animation")
        }
        
        delay(0.3) {
            // title
            self.titleLabel.center = self.view.center
            self.titleLabel.layer.opacity = 0
            self.titleLabel.hidden = false
            
            var newTitleCenter = self.view.center
            newTitleCenter.y -= self.titleLabel.bounds.height
            
            let titleSequence = ATAnimationSequence(animations: [
                CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration: self.scale(1)),
                CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(CATransform3D: CATransform3DMakeScale(0.9, 0.9, 0.0)), duration:self.scale(0.2)),
                CAAnimationGroup(animations: [
                    CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(CATransform3D: CATransform3DIdentity), duration: self.scale(1.5)),
                    CABasicAnimation(keyPath: "position", toValue: NSValue(CGPoint: newTitleCenter), duration: self.scale(1.5)),
                    ]),
                ])
            self.titleLabel.layer.addAnimation(titleSequence, forKey: nil)
            
            // subtitle
            self.subtitleLabel.center = self.view.center
            self.subtitleLabel.layer.opacity = 0
            self.subtitleLabel.hidden = false
            let subtitleSequence = CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration:self.scale(0.5))
            subtitleSequence.beginTime = CACurrentMediaTime() + titleSequence.duration - self.scale(0.2)
            self.subtitleLabel.layer.addAnimation(subtitleSequence, forKey: nil)
            
            // colors
            var colorsFrame = bounds
            colorsFrame.size.height = 100
            colorsFrame.origin.y = bounds.height
            self.colorsImageView.frame = colorsFrame
            self.colorsImageView.hidden = false
            var newColorsCenter = colorsFrame.center
            newColorsCenter.y -= colorsFrame.size.height
            let colorsSequence = CABasicAnimation(keyPath: "position", toValue: NSValue(CGPoint: newColorsCenter), duration: self.scale(2))
            self.colorsImageView.layer.addAnimation(colorsSequence, forKey: nil)
            
            // bucket
            var bucketFrame = self.bucketImageView.frame
            bucketFrame.origin.y = bounds.height
            bucketFrame.origin.x = bounds.width - bucketFrame.width - 30
            self.bucketImageView.frame = bucketFrame
            self.bucketImageView.hidden = false
            var newBucketCenter1 = bucketFrame.center
            newBucketCenter1.y = 2 * (bounds.height / 3)
            var newBucketCenter2 = newBucketCenter1
            newBucketCenter2.y = bounds.height - (bucketFrame.height / 2) - 40
            
            let bucketSequence = CAAnimationGroup(animations: [
                ATAnimationSequence(animations: [
                    CABasicAnimation(keyPath: "transform.rotation", toValue: 0.5, duration: self.scale(1.5)),
                    CABasicAnimation(keyPath: "transform.rotation", toValue: 0, duration: self.scale(1.5)),
                    CABasicAnimation(keyPath: "transform.rotation", toValue: 0.1, duration: self.scale(1.2)),
                    ]),
                ATAnimationSequence(animations: [
                    CABasicAnimation(keyPath: "position", timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut), toValue: NSValue(CGPoint: newBucketCenter1), duration: self.scale(2)),
                    CASpringAnimation(keyPath: "position", timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn), toValue: NSValue(CGPoint: newBucketCenter2), duration: self.scale(2))
                    ])
                ])
            self.bucketImageView.layer.addAnimation(bucketSequence, forKey: nil)
        }
        
    }
    
    @IBAction func userDidTap(sender: AnyObject) {
        let bounds = UIScreen.mainScreen().bounds
        
        self.titleLabel.layer.addAnimation(CABasicAnimation(keyPath: "opacity", toValue: 0.0, duration:self.scale(1)), forKey: nil)
        self.subtitleLabel.layer.addAnimation(CABasicAnimation(keyPath: "opacity", toValue: 0.0, duration:self.scale(1)), forKey: nil)

        var newColorsCenter = self.colorsImageView.layer.presentationLayer()!.position
        newColorsCenter.y = bounds.height + 100
        self.colorsImageView.layer.addAnimation(CABasicAnimation(keyPath: "position", toValue: NSValue(CGPoint: newColorsCenter), duration: self.scale(1)), forKey: nil)
        var newBucketCenter = self.bucketImageView.layer.presentationLayer()!.position
        newBucketCenter.y = bounds.height + 100
        self.bucketImageView.layer.addAnimation(CABasicAnimation(keyPath: "position", toValue: NSValue(CGPoint: newBucketCenter), duration: self.scale(1)), forKey: nil)

        delay(self.scale(2)) {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
    }
    
    private func scale(value: CFTimeInterval) -> CFTimeInterval {
        return value * 0.2
    }
    
}
