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
class ThinSliderView: UIView {
    
    var progress: UISlider!
    var time: UILabel!
    
    private let timeInterval = 0.01
    
    private var timeObserver : AnyObject?
    
    weak var player: BCPlayer? {
        willSet {
            self.removeObservers()
        }
        didSet {
            self.timeObserver = self.player?.addPeriodicTimeObserverForInterval(CMTimeMakeWithSeconds(timeInterval, CMTimeScale(NSEC_PER_SEC)), queue: nil) { [weak self] (time) in
                if (self!.player != nil && self!.player?.currentItem != nil ) {
                    self!.progress.value = Float(CMTimeGetSeconds(time) / CMTimeGetSeconds(self!.player!.currentItem!.asset.duration));
                    let secondsPlayed = max(0,CMTimeGetSeconds(time))
                    let minutes = Int(secondsPlayed / 60)
                    let seconds = Int(secondsPlayed % 60)
                    self!.time.text = String(format:"%01d:%02d",minutes,seconds)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        progress = CustomSlider(frame: self.bounds)
        progress.minimumTrackTintColor = UIColor.whiteColor()
        progress.maximumTrackTintColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.6)
        progress.thumbTintColor = UIColor.whiteColor()
        let thumbImage = UIImage(named: "thumbImage")
        progress.setThumbImage(thumbImage, forState: .Normal)
        progress.setThumbImage(thumbImage, forState: .Highlighted)
        progress.minimumValue = 0.0
        progress.maximumValue = 1.0
        
        time = UILabel(frame: self.bounds)
        time.text = "0:00"
        time.textColor = UIColor.li5_whiteColor()
        
        self.addSubview(progress)
        self.addSubview(time)
    }
    
    override func updateConstraints() {
        progress.snp_makeConstraints {(make) -> Void in
            make.leading.equalTo(self).offset(20)
            make.centerY.equalTo(self)
            make.trailing.equalTo(time.snp_leadingMargin).offset(-30)
        }
        time.snp_makeConstraints { (make) -> Void in
            make.trailing.equalTo(self).offset(-20)
            make.centerY.equalTo(self)
            make.width.equalTo(50)
        }
        super.updateConstraints()
    }
    
    override func prepareForInterfaceBuilder() {
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
    
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        var rect = super.trackRectForBounds(bounds)
        rect.size.height = 3
        return rect
    }
    
}
