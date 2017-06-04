//
//  ThinProgressUIView.swift
//  Spinner
//
//  Created by Martin Cocaro on 3/29/17.
//  Copyright © 2017 Martin Cocaro. All rights reserved.
//

import UIKit
import SnapKit
import CoreMedia

//@IBDesignable
@objc open class ThinSliderView: UIView {
    
    var progress: UISlider!
    var time: UILabel!
    
    fileprivate let timeInterval = 0.01
    
    fileprivate var timeObserver : AnyObject?
    
    weak var player: BCPlayer? {
        willSet {
            self.removeObservers()
        }
        didSet {
            self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(timeInterval, CMTimeScale(NSEC_PER_SEC)), queue: nil) { [weak self] (time) in
                if (self!.player != nil && self!.player?.currentItem != nil ) {
                    self!.progress.value = Float(CMTimeGetSeconds(time) / CMTimeGetSeconds(self!.player!.currentItem!.asset.duration));
                    let secondsPlayed = max(0,CMTimeGetSeconds(time))
                    let minutes = Int(secondsPlayed / 60)
                    let seconds = Int(secondsPlayed.truncatingRemainder(dividingBy: 60))
                    self!.time.text = String(format:"%01d:%02d",minutes,seconds)
                }
            } as AnyObject
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        progress = CustomSlider(frame: self.bounds)
        progress.minimumTrackTintColor = UIColor.white
        progress.maximumTrackTintColor = UIColor.lightGray.withAlphaComponent(0.6)
        progress.thumbTintColor = UIColor.white
        let thumbImage = UIImage(named: "thumbImage")
        progress.setThumbImage(thumbImage, for: UIControlState())
        progress.setThumbImage(thumbImage, for: .highlighted)
        progress.minimumValue = 0.0
        progress.maximumValue = 1.0
        
        time = UILabel(frame: self.bounds)
        time.text = "0:00"
        time.textColor = UIColor.li5_white()
        
        self.addSubview(progress)
        self.addSubview(time)
    }
    
    override open func updateConstraints() {
        progress.snp.makeConstraints { (make) in
            make.leading.equalTo(self).offset(20)
            make.centerY.equalTo(self)
            make.trailing.equalTo(time.snp.leadingMargin).offset(-30)
        }
        
        time.snp.makeConstraints { (make) -> Void in
            make.trailing.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
            make.width.equalTo(50)
        }
        super.updateConstraints()
    }
    
    override open func prepareForInterfaceBuilder() {
        progress.setValue(0.1, animated: false)
        self.updateConstraints()
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

//@IBDesignable
class CustomSlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.trackRect(forBounds: bounds)
        rect.size.height = 3
        return rect
    }
    
}
