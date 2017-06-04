//
//  HeartAnimationView.swift
//  AnimationText
//
//  Created by Martin Cocaro on 2016/07/05.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol HeartAnimationViewDelegate : NSObjectProtocol {
    @objc optional func didTapButton()
}

@objc open class HeartAnimationView : UIView {
    @IBOutlet open var delegate : HeartAnimationViewDelegate?
    
    var speed : Double = 0.1
    fileprivate let button = FwdButton(type: .custom)

    fileprivate var emptyHeart : CALayer = {
        let heart = EmptyHeart()
        heart.anchorPoint = CGPoint(x: 0.5, y: 1)
        heart.opacity = 0
        return heart
    }()

    fileprivate var barelyFullHeart : CALayer = {
        let heart = BarelyFullHeart()
        heart.anchorPoint = CGPoint(x: 0.5, y: 1)
        heart.opacity = 0
        return heart
    }()
    
    fileprivate var almostFullHeart : CALayer = {
        let heart = AlmostFullHeart()
        heart.anchorPoint = CGPoint(x: 0.5, y: 1)
        heart.opacity = 0
        return heart
    }()
    fileprivate var fullHeart : CALayer = {
        let heart = FullHeart()
        heart.anchorPoint = CGPoint(x: 0.5, y: 1)
        heart.opacity = 0
        return heart
    }()

    fileprivate var loveLayers : [LoveLayer] = {
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
    
    fileprivate var topBalls : [Ball] = {
        let balls = [
            Ball(radius: 4),
            Ball(radius: 8),
            ]
        
        for ball in balls {
            ball.opacity = 0.0
        }
        
        return balls
    }()

    fileprivate var leftBalls : [Ball] = {
        let balls = [
            Ball(radius: 3),
            Ball(radius: 5),
            ]
        
        for ball in balls {
            ball.opacity = 0.0
        }
        
        return balls
    }()

    fileprivate var rightBalls : [Ball] = {
        let balls = [
            Ball(radius: 3),
            ]
        
        for ball in balls {
            ball.opacity = 0.0
        }
        
        return balls
    }()

    fileprivate var allBalls : [Ball] {
        return self.topBalls + self.leftBalls + rightBalls
    }
    
    
    override open func layoutSubviews() {
        let hearts = [self.emptyHeart, self.barelyFullHeart, self.almostFullHeart, self.fullHeart]
        
        if self.fullHeart.superlayer == nil {
            self.addSubview(self.button)
            self.button.backgroundColor = UIColor.clear
            self.button.setBackgroundImage(UIImage(named:"bGbutton"), for: UIControlState())
            self.button.addTarget(self, action: #selector(self.didTapButton), for: .touchUpInside)
            
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
            
            if (self.button.isSelected) {
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
            CABasicAnimation(keyPath: "transform.rotation", toValue: -0.3 as AnyObject, duration: self.duration(2)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: 0.3 as AnyObject, duration: self.duration(2)),
            CAAnimationGroup(animations: [
                CABasicAnimation(keyPath: "transform", toValue: NSValue(caTransform3D: CATransform3DMakeScale(1.0, 0.65, 0.0)), duration: self.duration(2)),
                CABasicAnimation(keyPath: "transform.rotation", toValue: -0.3 as AnyObject, duration: self.duration(2)),
                ]),
            CABasicAnimation(keyPath: "transform", toValue: NSValue(caTransform3D: CATransform3DMakeScale(0.9, 1.1, 0.0)), duration: self.duration(2)),
            CABasicAnimation(keyPath: "transform", toValue: NSValue(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 0.0)), duration: self.duration(2)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: 0 as AnyObject, duration: self.duration(2)),
            ])

        
        let reveal1 = CABasicAnimation(keyPath: "opacity", toValue: 1.0 as AnyObject, duration: self.duration(1))
        reveal1.beginTime = self.duration(2)
        let group1 = CAAnimationGroup(animations: [heartSequence,
            reveal1,
            ])

        let reveal2 = CABasicAnimation(keyPath: "opacity", toValue: 1.0 as AnyObject, duration: self.duration(1))
        reveal2.beginTime = self.duration(4)
        let group2 = CAAnimationGroup(animations: [heartSequence,
            reveal2,
            ])
        
        let reveal3 = CABasicAnimation(keyPath: "opacity", toValue: 1.0 as AnyObject, duration: self.duration(1))
        reveal3.beginTime = self.duration(6)
        let group3 = CAAnimationGroup(animations: [heartSequence,
            reveal3,
            ])
        
        self.emptyHeart.add(heartSequence, forKey: nil)
        self.barelyFullHeart.add(group1, forKey: nil)
        self.almostFullHeart.add(group2, forKey: nil)
        self.fullHeart.add(group3, forKey: nil)
        
        let start = heartSequence.animations!.prefix(4).reduce(0, {$0 + $1.duration})
        let love0Sequence = ATAnimationSequence(animations: [
            HideAnimation(duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: -0.1 as AnyObject, duration: self.duration(2)),
            CABasicAnimation(keyPath: "opacity", toValue: 1.0 as AnyObject, duration: start), // also works as a delay
            CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(caTransform3D: CATransform3DIdentity), duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "position", toValue: NSValue(cgPoint: self.scale(CGPoint(x: 40, y: 40))), duration: self.duration(2)),
            HideAnimation(duration: self.duration(2)),
            
            ])
        love0Sequence.isRemovedOnCompletion = true
        self.loveLayers[0].add(love0Sequence, forKey: nil)
        
        
        let love1Sequence = ATAnimationSequence(animations: [
            HideAnimation(duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: -0.3 as AnyObject, duration: self.duration(2)),
            CABasicAnimation(keyPath: "opacity", toValue: 1.0 as AnyObject, duration: start), // also works as a delay
            CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(caTransform3D: CATransform3DIdentity), duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "position", toValue: NSValue(cgPoint: self.scale(CGPoint(x: 140, y: 60))), duration: self.duration(2.2)),
            HideAnimation(duration: self.duration(2)),
            
            ])
        love1Sequence.isRemovedOnCompletion = true
        self.loveLayers[1].add(love1Sequence, forKey: nil)
        
        
        let love2Sequence = ATAnimationSequence(animations: [
            HideAnimation(duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: 0.3 as AnyObject, duration: self.duration(2)),
            CABasicAnimation(keyPath: "opacity", toValue: 1.0 as AnyObject, duration: start), // also works as a delay
            CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(caTransform3D: CATransform3DIdentity), duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "position", toValue: NSValue(cgPoint: self.scale(CGPoint(x: 120, y: 160))), duration: self.duration(1.4)),
            CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 0.0)), duration: self.duration(0.5)),
            HideAnimation(duration: self.duration(0.5)),
            
            ])
        love2Sequence.isRemovedOnCompletion = true
        self.loveLayers[2].add(love2Sequence, forKey: nil)
        
        let path = UIBezierPath()
        path.move(to: self.scale(CGPoint(x: 100, y: 80)))
        path.addCurve(to: self.scale(CGPoint(x: 40, y: 80)), controlPoint1: self.scale(CGPoint(x: 100, y: 40)), controlPoint2: self.scale(CGPoint(x: 120, y: 200)))
        
        let love3Sequence = ATAnimationSequence(animations: [
            HideAnimation(duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "transform.rotation", toValue: -0.3 as AnyObject, duration: self.duration(2)),
            CABasicAnimation(keyPath: "opacity", toValue: 1.0 as AnyObject, duration: start), // also works as a delay
            CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(caTransform3D: CATransform3DIdentity), duration: self.duration(0.0001)),
            CABasicAnimation(keyPath: "position", toValue: NSValue(cgPoint: self.scale(CGPoint(x: 100, y: 80))), duration: self.duration(0.5)),
            CAKeyframeAnimation(keyPath: "position", path: path.cgPath, duration: self.duration(2)),
            HideAnimation(duration: self.duration(1)),
            
            ])
        love3Sequence.isRemovedOnCompletion = true
        self.loveLayers[3].add(love3Sequence, forKey: nil)

    
        var offset = 0.1
        for ball in self.topBalls {
            let animation = ATAnimationSequence(animations: [
                HideAnimation(duration: self.duration(0.0001)),
                CABasicAnimation(keyPath: "opacity", toValue: 1.0 as AnyObject, duration: start + offset), // also works as a delay
                CAAnimationGroup(animations: [
                    CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(caTransform3D: CATransform3DIdentity), duration: self.duration(1.5)),
                    CABasicAnimation(keyPath: "position", toValue: NSValue(cgPoint: self.scale(CGPoint(x: 100, y: 60))), duration: self.duration(1.5)),
                    ]),
                HideAnimation(duration: self.duration(1)),
                ])
            animation.isRemovedOnCompletion = true
            ball.add(animation, forKey: nil)
            offset += 0.3
        }
        
        offset = 0.2
        for ball in self.leftBalls {
            let animation = ATAnimationSequence(animations: [
                HideAnimation(duration: self.duration(0.0001)),
                CABasicAnimation(keyPath: "opacity", toValue: 1.0 as AnyObject, duration: start + offset), // also works as a delay
                CAAnimationGroup(animations: [
                    CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(caTransform3D: CATransform3DIdentity), duration: self.duration(1.5)),
                    CABasicAnimation(keyPath: "position", toValue: NSValue(cgPoint: self.scale(CGPoint(x: 60, y: 140))), duration: self.duration(1.5)),
                    ]),
                HideAnimation(duration: self.duration(1)),
                ])
            animation.isRemovedOnCompletion = true
            ball.add(animation, forKey: nil)
            offset += 0.2
        }

        offset = 0.3
        for ball in self.rightBalls {
            let animation = ATAnimationSequence(animations: [
                HideAnimation(duration: self.duration(0.0001)),
                CABasicAnimation(keyPath: "opacity", toValue: 1.0 as AnyObject, duration: start + offset), // also works as a delay
                CAAnimationGroup(animations: [
                    CABasicAnimation(keyPath: "transform.scale", toValue: NSValue(caTransform3D: CATransform3DIdentity), duration: self.duration(1.5)),
                    CABasicAnimation(keyPath: "position", toValue: NSValue(cgPoint: self.scale(CGPoint(x: 130, y: 130))), duration: self.duration(1.5)),
                    ]),
                HideAnimation(duration: self.duration(1)),
                ])
            animation.isRemovedOnCompletion = true
            ball.add(animation, forKey: nil)
            offset += 0.2
        }
        offset = 0
    }
    
    fileprivate func scale(_ point: CGPoint) -> CGPoint {
        // based on a 200x200 "default" size, return a scaled point
        return CGPoint(x: point.x * self.bounds.width / 200, y: point.y * self.bounds.height / 200)
    }
    
    fileprivate func scale(_ value: CGFloat) -> CGFloat {
        return value * self.bounds.width / 200
    }
    
    func duration(_ duration: CFTimeInterval) -> CFTimeInterval {
        return duration * self.speed
    }
    
    func stop() {
        self.layer.sublayers?.forEach({$0.removeAllAnimations()})
    }
    
    func didTapButton(_ sender: UIButton) {
        if (!self.button.isSelected) {
            self.start()
        }
        self.delegate?.didTapButton?()
    }
    
    open var selected: Bool = false {
        didSet {
            self.button.isSelected = selected
            
            if (!self.button.isSelected) {
                self.stop()
                self.fullHeart.opacity = 0
                self.emptyHeart.opacity = 1
            }
        }
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
    }
    
}

class FwdButton : UIButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.next!.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.next!.touchesEnded(touches, with: event)
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
            self.isRemovedOnCompletion = false
        }
    }
    
    convenience init(animations: [CAAnimation]) {
        self.init()
        self.animations = animations
        self.fillMode = kCAFillModeForwards
        self.isRemovedOnCompletion = false
    }
}

extension CAKeyframeAnimation {
    convenience init(keyPath: String, path: CGPath, duration: CFTimeInterval) {
        self.init(keyPath: keyPath)
        self.path = path
        self.duration = duration
        self.fillMode = kCAFillModeForwards
        self.isRemovedOnCompletion = false
    }
}

extension CAAnimationGroup {
    convenience init(animations: [CAAnimation]) {
        self.init()
        self.animations = animations
        self.duration = animations.reduce(0, {max($0, $1.duration)})
        self.fillMode = kCAFillModeForwards
        self.isRemovedOnCompletion = false
    }
}

extension CABasicAnimation {
    convenience init(keyPath: String, timingFunction: CAMediaTimingFunction? = nil, toValue: AnyObject?, duration: CFTimeInterval) {
        self.init()
        self.keyPath = keyPath
        self.toValue = toValue
        self.duration = duration
        self.fillMode = kCAFillModeForwards
        self.isRemovedOnCompletion = false
    }
}

class HideAnimation : CABasicAnimation {
    init(duration: CFTimeInterval) {
        super.init()
        self.keyPath = "transform.scale"
        self.toValue = NSValue(caTransform3D: CATransform3DMakeScale(0.000001, 0.000001, 0.0))
        self.duration = duration
        self.fillMode = kCAFillModeForwards
        self.isRemovedOnCompletion = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class LoveLayer : CALayer {
    var radius : CGFloat = 5
    
    override func draw(in context: CGContext) {
        UIGraphicsPushContext(context);
        let string : NSString = "LOVE"
        var fontSize : CGFloat = 64
        
        var width : CGFloat = 0
        repeat {
            fontSize -= 1
            let attributes = [
                NSFontAttributeName : UIFont.systemFont(ofSize: fontSize),
                NSForegroundColorAttributeName : UIColor.yellow,
                ]
            width = string.size(attributes: attributes).width
        } while width > self.bounds.width
        
        let attributes = [
            NSFontAttributeName : UIFont.systemFont(ofSize: fontSize),
            NSForegroundColorAttributeName : UIColor.yellow,
            ]
        
        string.draw(at: CGPoint.zero, withAttributes: attributes)
        
        let rect = CGRect(origin: CGPoint(x: (self.bounds.width / 2) - self.radius, y: self.bounds.height - self.radius * 2), size: CGSize(width: self.radius * 2, height: self.radius * 2))
        context.addEllipse(in: rect)
        UIColor.yellow.setFill()
        context.fillPath()
        
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
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    fileprivate func commonInit() {
        self.contentsScale = 10 // draw in hi res, will scale later
    }
}

class Ball : CALayer {
    override func draw(in context: CGContext) {
        UIGraphicsPushContext(context);
        context.addEllipse(in: self.bounds)
        UIColor(red: 0.894, green: 0, blue: 0.185, alpha: 1).setFill()
        context.fillPath()
        UIGraphicsPopContext()
    }
    
    convenience init(radius: CGFloat) {
        self.init()
        self.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: radius * 2, height: radius * 2))
    }
    
}

extension CGRect {
    func centeredIn(_ rect: CGRect) -> CGRect {
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
    static func midPoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint
    {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }
    
}
