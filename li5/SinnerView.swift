//
//  SinnerView.swift
//  li5
//
//  Created by Martin Cocaro on 3/24/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import UIKit

//@IBDesignable
class SpinnerView : UIView {
    
    var outerCircle: SpinnerCircleView!
    var innerCircle: SpinnerCircleView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        outerCircle = SpinnerCircleView(frame:self.bounds, conf: SpinnerConf(direction: 1, lineWidth: 3, lineColor: UIColor.li5_white()))
        innerCircle = SpinnerCircleView(frame:self.bounds.insetBy(dx: 10, dy: 10), conf: SpinnerConf(direction: -1, lineWidth:  3, lineColor: UIColor.li5_white()))
        self.addSubview(outerCircle)
        self.addSubview(innerCircle)
    }
    
    override func prepareForInterfaceBuilder() {
        initialize()
    }
    
}

struct SpinnerConf {
    
    var direction: Int = 1
    var lineWidth: CGFloat = 3.0
    var lineColor: UIColor = UIColor.black
    
}

class SpinnerCircleView: UIView {
    
    var conf: SpinnerConf!
    
    override var layer: CAShapeLayer {
        get {
            return super.layer as! CAShapeLayer
        }
    }
    
    convenience init(frame: CGRect, conf c: SpinnerConf) {
        self.init(frame: frame)
        conf = c
    }
    
    override class var layerClass : AnyClass {
        return CAShapeLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.fillColor = nil
        layer.strokeColor = self.conf.lineColor.cgColor
        layer.lineWidth = self.conf.lineWidth
        setPath()
    }
    
    override func didMoveToWindow() {
        animate()
    }
    
    fileprivate func setPath() {
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: layer.lineWidth / 2, dy: layer.lineWidth / 2)).cgPath
    }
    
    struct Pose {
        let secondsSincePriorPose: CFTimeInterval
        let start: CGFloat
        let length: CGFloat
        init(_ secondsSincePriorPose: CFTimeInterval, _ start: CGFloat, _ length: CGFloat) {
            self.secondsSincePriorPose = secondsSincePriorPose
            self.start = start
            self.length = length
        }
    }
    
    class var poses: [Pose] {
        get {
            return [
                Pose(0.0, 0.000, 0.6),
                Pose(0.6, 0.500, 0.6),
                Pose(0.6, 1.000, 0.6)
            ]
        }
    }
    
    func animate() {
        var time: CFTimeInterval = 0
        var times = [CFTimeInterval]()
        var start: CGFloat = 0
        var rotations = [CGFloat]()
        var strokeEnds = [CGFloat]()
        
        let poses = SpinnerCircleView.poses
        let totalSeconds = poses.reduce(0) { $0 + $1.secondsSincePriorPose }
        
        for pose in poses {
            time += pose.secondsSincePriorPose
            times.append(time / totalSeconds)
            start = pose.start
            rotations.append(CGFloat(self.conf.direction) * start * 2 * CGFloat(Double.pi))
            strokeEnds.append(pose.length)
        }
        
        times.append(times.last!)
        rotations.append(rotations[0])
        strokeEnds.append(strokeEnds[0])
        
        animateKeyPath(keyPath: "strokeEnd", duration: totalSeconds, times: times, values: strokeEnds)
        animateKeyPath(keyPath: "transform.rotation", duration: totalSeconds, times: times, values: rotations)
        
        //        animateStrokeHueWithDuration(duration: totalSeconds * 5)
    }
    
    func animateKeyPath(keyPath: String, duration: CFTimeInterval, times: [CFTimeInterval], values: [CGFloat]) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]?
        animation.values = values
        animation.calculationMode = kCAAnimationLinear
        animation.duration = duration
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
    
    func animateStrokeHueWithDuration(duration: CFTimeInterval) {
        let count = 36
        let animation = CAKeyframeAnimation(keyPath: "strokeColor")
        animation.keyTimes = (0 ... count).map { NSNumber(value: CFTimeInterval($0) / CFTimeInterval(count) as Double) }
        animation.values = (0 ... count).map {
            UIColor(hue: CGFloat($0) / CGFloat(count), saturation: 1, brightness: 1, alpha: 1).cgColor
        }
        animation.duration = duration
        animation.calculationMode = kCAAnimationLinear
        animation.repeatCount = Float.infinity
        layer.add(animation, forKey: animation.keyPath)
    }
    
}
