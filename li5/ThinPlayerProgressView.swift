//
//  Li5ThinPlayerProgressView.swift
//  li5
//
//  Created by Martin Cocaro on 3/21/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit
import CoreMedia

//@IBDesignable
class ThinPlayerProgressView: UIView {

    private let timeInterval = 0.01
    
    private var overlay: UIView = UIView()
    
    private var timeObserver : AnyObject?
    
    weak var player: BCPlayer? {
        willSet {
            self.removeObservers()
        }
        didSet {
            self.timeObserver = self.player?.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(timeInterval, CMTimeScale(NSEC_PER_SEC)), queue: nil) { (time) in
                if (self.player != nil && self.player?.currentItem != nil ) {
                    self.percentage = CMTimeGetSeconds(time) / CMTimeGetSeconds(self.player!.currentItem!.asset.duration);
                }
            }
        }
    }
    
    var percentage = 0.0 {
        didSet {
            UIView.animateWithDuration(timeInterval, delay: 0, options: .CurveLinear, animations: {
                self.layoutSubviews()
            }, completion: nil)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initialize()
    }
    
    func initialize() {
        overlay.backgroundColor = UIColor.whiteColor()
        self.addSubview(overlay)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        overlay.frame = CGRectMake(0, 0, self.frame.size.width * CGFloat(percentage), self.frame.size.height)
    }
    
    func removeObservers() {
        if (timeObserver != nil) {
            self.player?.removeTimeObserver(self.timeObserver!)
            timeObserver = nil
        }
    }
    
    deinit {
        self.removeObservers()
    }
    
}
