//
//  HeartAnimationView.swift
//  AnimationText
//
//  Created by Martin Adoue on 2016/07/05.
//  Copyright © 2016 Ubernerden. All rights reserved.
//

import Foundation
import UIKit

@objc protocol HeartAnimationViewDelegate : NSObjectProtocol {
    optional func didTapButton()
}

class HeartAnimationView : UIView {
    @IBOutlet var delegate : HeartAnimationViewDelegate?
    
    var speed : Double = 0.2
    private let button = UIButton(type: .Custom)

    private var emptyHeart : CALayer = {
        let heart = EmptyHeart()
        heart.anchorPoint = CGPoint(x: 0.5, y: 1)
        heart.opacity = 0
        return heart
    }()

    private var barelyFullHeart : CALayer = {
        let heart = BarelyFullHeart()
        heart.anchorPoint = CGPoint(x: 0.5, y: 1)
        heart.opacity = 0
        return heart
    }()
    
    private var almostFullHeart : CALayer = {
        let heart = AlmostFullHeart()
        heart.anchorPoint = CGPoint(x: 0.5, y: 1)
        heart.opacity = 0
        return heart
    }()
    private var fullHeart : CALayer = {
        let heart = FullHeart()
        heart.anchorPoint = CGPoint(x: 0.5, y: 1)
        heart.opacity = 0
        return heart
    }()

    private var loveLayers : [LoveLayer] = {
        let layers = [
            LoveLayer(),
            LoveLayer(),
            LoveLayer(),
            LoveLayer(),
            ]
        
        for layer in layers {
            layer.opacity = 0.0
        }
        
        return layers
    }()
    
    private var topBalls : [Ball] = {
        let balls = [
            Ball(radius: 4),
            Ball(radius: 8),
            ]
        
        for ball in balls {
            ball.opacity = 0.0
        }
        
        return balls
    }()

    private var leftBalls : [Ball] = {
        let balls = [
            Ball(radius: 3),
            Ball(radius: 5),
            ]
        
        for ball in balls {
            ball.opacity = 0.0
        }
        
        return balls
    }()

    private var rightBalls : [Ball] = {
        let balls = [
            Ball(radius: 3),
            ]
        
        for ball in balls {
            ball.opacity = 0.0
        }
        
        return balls
    }()

    private var allBalls : [Ball] {
        return self.topBalls + self.leftBalls + rightBalls
    }
    
    
    override func layoutSubviews() {
        let hearts = [self.emptyHeart, self.barelyFullHeart, self.almostFullHeart, self.fullHeart]
        
        if self.fullHeart.superlayer == nil {
            self.addSubview(self.button)
            self.button.backgroundColor = UIColor.clearColor()
            self.button.setBackgroundImage(UIImage(named:"bGbutton"), forState: .Normal)
            self.button.addTarget(self, action: #selector(self.didTapButton), forControlEvents: .TouchUpInside)
            
            for layer in self.loveLayers {
                layer.radius = self.scale(5)
                self.layer.addSublayer(layer)
                layer.setNeedsDisplay()
            }

            for ball in self.allBalls {
                self.layer.addSublayer(ball)
                ball.setNeedsDisplay()
            }
            
            for heart in hearts {
                self.layer.addSublayer(heart)
                heart.setNeedsDisplay()
            }
            
            if (self.button.selected) {
                self.fullHeart.opacity = 1
                self.emptyHeart.opacity = 0
            } else {
                self.emptyHeart.opacity = 1
                self.fullHeart.opacity = 0
            }
        }
        let h = self.bounds.height / 5
        let w = self.bounds.width / 5
        let frame = CGRect(x: w * 2, y: h * 2, width: w, height: h)
        self.button.frame = frame.insetBy(dx: -10, dy: -10)

        for heart in hearts {
            heart.frame = frame
        }
        
        for layer in self.loveLayers {
            layer.frame = frame
        }
        for ball in self.allBalls {
            ball.frame = ball.frame.centeredIn(self.bounds)
        }
    }
    
    func start() {
        let heartSequence = ATAnimationSequence(animations: [
            CABasicAnimation(keyPath: "transform.rotation", toValue: -0.3, duration: self.duration(2)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: 0.3, duration: self.duration(2)),
            CAAnimationGroup(animations: [
                CABasicAnimation(keyPath: "transform", toValue: NSValue(CATransform3D: CATransform3DMakeScale(1.0, 0.65, 0.0)), duration: self.duration(2)),
                CABasicAnimation(keyPath: "transform.rotation", toValue: -0.3, duration: self.duration(2)),
                ]),
            CABasicAnimation(keyPath: "transform", toValue: NSValue(CATransform3D: CATransform3DMakeScale(0.9, 1.1, 0.0)), duration: self.duration(2)),
            CABasicAnimation(keyPath: "transform", toValue: NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 0.0)), duration: self.duration(2)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: 0, duration: self.duration(2)),
            ])

        
        let reveal1 = CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration: self.duration(1))
        reveal1.beginTime = self.duration(2)
        let group1 = CAAnimationGroup(animations: [heartSequence,
            reveal1,
            ])

        let reveal2 = CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration: self.duration(1))
        reveal2.beginTime = self.duration(4)
        let group2 = CAAnimationGroup(animations: [heartSequence,
            reveal2,
            ])
        
        let reveal3 = CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration: self.duration(1))
        reveal3.beginTime = self.duration(6)
        let group3 = CAAnimationGroup(animations: [heartSequence,
            reveal3,
            ])
        
        self.emptyHeart.addAnimation(heartSequence, forKey: nil)
        self.barelyFullHeart.addAnimation(group1, forKey: nil)
        self.almostFullHeart.addAnimation(group2, forKey: nil)
        self.fullHeart.addAnimation(group3, forKey: nil)
        
        let start = heartSequence.animations!.prefix(4).reduce(0, combine: {$0 + $1.duration})
        let love0Sequence = ATAnimationSequence(animations: [
            HideAnimation(duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: -0.1, duration: self.duration(2)),
            CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration: start), // also works as a delay
            CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(CATransform3D: CATransform3DIdentity), duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "position", toValue: NSValue(CGPoint: self.scale(CGPoint(x: 40, y: 40))), duration: self.duration(2)),
            HideAnimation(duration: self.duration(2)),
            
            ])
        love0Sequence.removedOnCompletion = true
        self.loveLayers[0].addAnimation(love0Sequence, forKey: nil)
        
        
        let love1Sequence = ATAnimationSequence(animations: [
            HideAnimation(duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: -0.3, duration: self.duration(2)),
            CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration: start), // also works as a delay
            CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(CATransform3D: CATransform3DIdentity), duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "position", toValue: NSValue(CGPoint: self.scale(CGPoint(x: 140, y: 60))), duration: self.duration(2.2)),
            HideAnimation(duration: self.duration(2)),
            
            ])
        love1Sequence.removedOnCompletion = true
        self.loveLayers[1].addAnimation(love1Sequence, forKey: nil)
        
        
        let love2Sequence = ATAnimationSequence(animations: [
            HideAnimation(duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: 0.3, duration: self.duration(2)),
            CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration: start), // also works as a delay
            CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(CATransform3D: CATransform3DIdentity), duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "position", toValue: NSValue(CGPoint: self.scale(CGPoint(x: 120, y: 160))), duration: self.duration(1.4)),
            CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(CATransform3D: CATransform3DMakeScale(1.2, 1.2, 0.0)), duration: self.duration(0.5)),
            HideAnimation(duration: self.duration(0.5)),
            
            ])
        love2Sequence.removedOnCompletion = true
        self.loveLayers[2].addAnimation(love2Sequence, forKey: nil)
        
        let path = UIBezierPath()
        path.moveToPoint(self.scale(CGPoint(x: 100, y: 80)))
        path.addCurveToPoint(self.scale(CGPoint(x: 40, y: 80)), controlPoint1: self.scale(CGPoint(x: 100, y: 40)), controlPoint2: self.scale(CGPoint(x: 120, y: 200)))
        
        let love3Sequence = ATAnimationSequence(animations: [
            HideAnimation(duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: -0.3, duration: self.duration(2)),
            CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration: start), // also works as a delay
            CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(CATransform3D: CATransform3DIdentity), duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "position", toValue: NSValue(CGPoint: self.scale(CGPoint(x: 100, y: 80))), duration: self.duration(0.5)),
            CAKeyframeAnimation(keyPath: "position", path: path.CGPath, duration: self.duration(2)),
            HideAnimation(duration: self.duration(1)),
            
            ])
        love3Sequence.removedOnCompletion = true
        self.loveLayers[3].addAnimation(love3Sequence, forKey: nil)

    
        var offset = 0.1
        for ball in self.topBalls {
            let animation = ATAnimationSequence(animations: [
                HideAnimation(duration: self.duration(0.0001)),
                CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration: start + offset), // also works as a delay
                CAAnimationGroup(animations: [
                    CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(CATransform3D: CATransform3DIdentity), duration: self.duration(1.5)),
                    CABasicAnimation(keyPath: "position", toValue: NSValue(CGPoint: self.scale(CGPoint(x: 100, y: 60))), duration: self.duration(1.5)),
                    ]),
                HideAnimation(duration: self.duration(1)),
                ])
            animation.removedOnCompletion = true
            ball.addAnimation(animation, forKey: nil)
            offset += 0.3
        }
        
        offset = 0.2
        for ball in self.leftBalls {
            let animation = ATAnimationSequence(animations: [
                HideAnimation(duration: self.duration(0.0001)),
                CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration: start + offset), // also works as a delay
                CAAnimationGroup(animations: [
                    CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(CATransform3D: CATransform3DIdentity), duration: self.duration(1.5)),
                    CABasicAnimation(keyPath: "position", toValue: NSValue(CGPoint: self.scale(CGPoint(x: 60, y: 140))), duration: self.duration(1.5)),
                    ]),
                HideAnimation(duration: self.duration(1)),
                ])
            animation.removedOnCompletion = true
            ball.addAnimation(animation, forKey: nil)
            offset += 0.2
        }

        offset = 0.3
        for ball in self.rightBalls {
            let animation = ATAnimationSequence(animations: [
                HideAnimation(duration: self.duration(0.0001)),
                CABasicAnimation(keyPath: "opacity", toValue: 1.0, duration: start + offset), // also works as a delay
                CAAnimationGroup(animations: [
                    CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(CATransform3D: CATransform3DIdentity), duration: self.duration(1.5)),
                    CABasicAnimation(keyPath: "position", toValue: NSValue(CGPoint: self.scale(CGPoint(x: 130, y: 130))), duration: self.duration(1.5)),
                    ]),
                HideAnimation(duration: self.duration(1)),
                ])
            animation.removedOnCompletion = true
            ball.addAnimation(animation, forKey: nil)
            offset += 0.2
        }
        offset = 0
    }
    
    private func scale(point: CGPoint) -> CGPoint {
        // based on a 200x200 "default" size, return a scaled point
        return CGPoint(x: point.x * self.bounds.width / 200, y: point.y * self.bounds.height / 200)
    }
    
    private func scale(value: CGFloat) -> CGFloat {
        return value * self.bounds.width / 200
    }
    
    func duration(duration: CFTimeInterval) -> CFTimeInterval {
        return duration * self.speed
    }
    
    func stop() {
        self.layer.sublayers?.forEach({$0.removeAllAnimations()})
    }
    
    func didTapButton(sender: UIButton) {
        if (!self.button.selected) {
            self.start()
        }
        self.delegate?.didTapButton?()
    }

    func setSelected(selected: Bool) {
        self.button.selected = selected
        
        if (!self.button.selected) {
            self.stop()
            self.fullHeart.opacity = 0
            self.emptyHeart.opacity = 1
        }
    }
    
    func selected() -> Bool {
        return self.button.selected
    }
}


class ATAnimationSequence : CAAnimationGroup {
    
    override var animations: [CAAnimation]? {
        didSet {
            guard let animations = self.animations else {
                return
            }
            var beginTime = 0.0
            for animation in animations {
                animation.beginTime = beginTime
                beginTime += animation.duration
            }
            self.duration = beginTime
            self.fillMode = kCAFillModeForwards
            self.removedOnCompletion = false
        }
    }
    
    convenience init(animations: [CAAnimation]) {
        self.init()
        self.animations = animations
        self.fillMode = kCAFillModeForwards
        self.removedOnCompletion = false
    }
}

extension CAKeyframeAnimation {
    convenience init(keyPath: String, path: CGPath, duration: CFTimeInterval) {
        self.init(keyPath: keyPath)
        self.path = path
        self.duration = duration
        self.fillMode = kCAFillModeForwards
        self.removedOnCompletion = false
    }
}

extension CAAnimationGroup {
    convenience init(animations: [CAAnimation]) {
        self.init()
        self.animations = animations
        self.duration = animations.reduce(0, combine: {max($0, $1.duration)})
        self.fillMode = kCAFillModeForwards
        self.removedOnCompletion = false
    }
}

extension CABasicAnimation {
    convenience init(keyPath: String, timingFunction: CAMediaTimingFunction? = nil, toValue: AnyObject?, duration: CFTimeInterval) {
        self.init()
        self.keyPath = keyPath
        self.toValue = toValue
        self.duration = duration
        self.fillMode = kCAFillModeForwards
        self.removedOnCompletion = false
    }
}

class HideAnimation : CABasicAnimation {
    init(duration: CFTimeInterval) {
        super.init()
        self.keyPath = "transform.scale"
        self.toValue = NSValue(CATransform3D: CATransform3DMakeScale(0.000001, 0.000001, 0.0))
        self.duration = duration
        self.fillMode = kCAFillModeForwards
        self.removedOnCompletion = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class LoveLayer : CALayer {
    var radius : CGFloat = 5
    
    override func drawInContext(context: CGContext) {
        UIGraphicsPushContext(context);
        let string : NSString = "LOVE"
        var fontSize : CGFloat = 64
        
        var width : CGFloat = 0
        repeat {
            fontSize -= 1
            let attributes = [
                NSFontAttributeName : UIFont.systemFontOfSize(fontSize),
                NSForegroundColorAttributeName : UIColor.yellowColor(),
                ]
            width = string.sizeWithAttributes(attributes).width
        } while width > self.bounds.width
        
        let attributes = [
            NSFontAttributeName : UIFont.systemFontOfSize(fontSize),
            NSForegroundColorAttributeName : UIColor.yellowColor(),
            ]
        
        string.drawAtPoint(CGPoint.zero, withAttributes: attributes)
        
        let rect = CGRect(origin: CGPoint(x: (self.bounds.width / 2) - self.radius, y: self.bounds.height - self.radius * 2), size: CGSize(width: self.radius * 2, height: self.radius * 2))
        CGContextAddEllipseInRect(context, rect)
        UIColor.yellowColor().setFill()
        CGContextFillPath(context)
        
        UIGraphicsPopContext()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init() {
        super.init()
        self.commonInit()
    }
    
    private func commonInit() {
        self.contentsScale = 10 // draw in hi res, will scale later
    }
}

class Ball : CALayer {
    override func drawInContext(context: CGContext) {
        UIGraphicsPushContext(context);
        CGContextAddEllipseInRect(context, self.bounds)
        UIColor(red: 0.894, green: 0, blue: 0.185, alpha: 1).setFill()
        CGContextFillPath(context)
        UIGraphicsPopContext()
    }
    
    convenience init(radius: CGFloat) {
        self.init()
        self.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: radius * 2, height: radius * 2))
    }
    
}

extension CGRect {
    func centeredIn(rect: CGRect) -> CGRect {
        var this = self
        this.center = rect.center
        return this
    }
    
    var center : CGPoint {
        get {
            return CGPoint(x: self.origin.x + self.size.width / 2, y: self.origin.y + self.size.height / 2)
        }
        mutating set {
            self.origin = CGPoint(x: newValue.x - self.size.width / 2, y: newValue.y - self.size.height / 2)
        }
    }
}

extension CGPoint {
    static func midPoint(p1: CGPoint, _ p2: CGPoint) -> CGPoint
    {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
}
