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
open class ThinPlayerProgressView: UIView {

    fileprivate let timeInterval = 0.01
    
    fileprivate var overlay: UIView = UIView()
    
    fileprivate var timeObserver : AnyObject?
    
    open weak var player: BCPlayer? {
        willSet {
            self.removeObservers()
        }
        didSet {
            self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(timeInterval, CMTimeScale(NSEC_PER_SEC)), queue: nil) { (time) in
                if (self.player != nil && self.player?.currentItem != nil ) {
                    self.percentage = CMTimeGetSeconds(time) / CMTimeGetSeconds(self.player!.currentItem!.asset.duration);
                }
            } as AnyObject
        }
    }
    
    var percentage = 0.0 {
        didSet {
            UIView.animate(withDuration: timeInterval, delay: 0, options: .curveLinear, animations: {
                self.layoutSubviews()
            }, completion: nil)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame:frame)
        initialize()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        initialize()
    }
    
    func initialize() {
        overlay.backgroundColor = UIColor.white
        self.addSubview(overlay)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        overlay.frame = CGRect(x: 0, y: 0, width: self.frame.size.width * CGFloat(percentage), height: self.frame.size.height)
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
