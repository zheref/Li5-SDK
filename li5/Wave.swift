//
//  Wave.swift
//  li5
//
//  Created by gustavo hansen on 6/27/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

import UIKit

public class Wave : UIView {
    
    let heightProportion : CGFloat = 0.2
    let numberOfLines = 28;
    weak var parenView : UIView?
    var shapeLayer = CAShapeLayer();
    
    public init(withView view: UIView) {
        
        let height = view.frame.height * heightProportion;
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width, height: height);
        
        super.init(frame: rect);
        parenView = view;
        
        self.alpha = 0;
        
        view.addSubview(self)
        view.bringSubviewToFront(self)
    }
    
    public func createCurvePath(x: CGFloat,
                                y: CGFloat ,
                                height: CGFloat,
                                lineWidth: CGFloat,
                                delta: CGFloat) -> UIBezierPath {
        
        let checkpoint1DeltaX: CGFloat = 30.0
        let checkpoint2DeltaX: CGFloat = 20.0 + delta
        let checkpoint1DeltaY: CGFloat = 0.3
        let checkpoint2DeltaY: CGFloat = 0.6
        
        let path = UIBezierPath()
        
        let endX = x + (height * 0.8);
        
        path.moveToPoint(CGPointMake(x, y))
        
        addCurve(path,
                 p1X: checkpoint1DeltaX + x,
                 p1Y: checkpoint1DeltaY * height,
                 p2X: endX - checkpoint2DeltaX,
                 p2Y: checkpoint2DeltaY * height,
                 enX: endX,
                 enY: height);
        
        path.moveToPoint(CGPointMake(x, y))
        
        addCurve(path,
                 p1X: checkpoint1DeltaX + x ,
                 p1Y: checkpoint1DeltaY * height,
                 p2X: endX - checkpoint2DeltaX + 5,
                 p2Y: checkpoint2DeltaY * height - 4,
                 enX: endX + 8,
                 enY: height - 3);
        
        path.moveToPoint(CGPointMake(x + 5, y))
        
        path.closePath()
        
        return path
    }
    
    func addCurve(path: UIBezierPath,
                  p1X: CGFloat,
                  p1Y: CGFloat,
                  p2X: CGFloat,
                  p2Y: CGFloat,
                  enX: CGFloat,
                  enY: CGFloat) {
        
        let controlPoint1 = CGPointMake(p1X, p1Y)
        
        let controlPoint2 = CGPointMake(p2X, p2Y)
        
        let endPoint = CGPointMake(enX, enY)
        
        path.addCurveToPoint(endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
    
    var isAnimating = false;
    
    public func stopAnimating() {
        
        if (self.isAnimating)
        {
            UIView.animateWithDuration(1, delay: 0, options: .AllowUserInteraction, animations: {
                self.blurEffectView?.alpha = 0
                self.alpha = 0
                }, completion: { (t) in
                    self.isAnimating = false;
//                self.layer.sublayers?.removeAll()
                    self.alpha = 0
                     self.blurEffectView?.alpha = 0
                    self.shapeLayer.removeFromSuperlayer();
                    self.blurEffectView?.removeFromSuperview();
                    self.blurEffectView = nil;
                    self.layer.sublayers?.removeAll()
            })
        }
    }
    
    var  blurEffectView : UIVisualEffectView?
    
    public func startAnimating() {
        
        if(self.isAnimating) {
        
            return;
        }
        
        self.isAnimating = true;
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light);
        
        blurEffectView = UIVisualEffectView(effect: blurEffect);
        blurEffectView!.frame = parenView!.bounds;
        
        blurEffectView!.alpha = 0
        blurEffectView!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        parenView!.addSubview(blurEffectView!);
        parenView!.bringSubviewToFront(self)
        
        let height = self.frame.height;
        
        let colorLineWidth = self.frame.width / 28;
        let emptyLineWidth = colorLineWidth * 0.8;
        var start = -(3 * self.frame.width);
        let color = UIColor(red:0.34, green:0.34, blue:0.34, alpha:0.1)
        
        var i = 0;
        var delta : CGFloat = 0.00;
        
        while(start < self.frame.width) {
            
            shapeLayer = CAShapeLayer()
            
            shapeLayer.strokeColor = i % 2 == 0 ?  color.CGColor : UIColor.clearColor().CGColor
            
            start = start + colorLineWidth;
            
            shapeLayer.path = createCurvePath(start, y: -5.00, height: height, lineWidth: emptyLineWidth, delta: delta).CGPath
            shapeLayer.fillColor = UIColor.clearColor().CGColor
            shapeLayer.lineWidth = emptyLineWidth
            
            /* Gradient*/
            
            let gradientLayer = CAGradientLayer();
            gradientLayer.frame = parenView!.frame//CGRect(x: self.frame.width * -2, y: 0, width: self.frame.width * 3, height: height)
            
            
            var colors = [AnyObject]();
            colors.append(UIColor(red:0.85, green:0.05, blue:0.14, alpha:1).CGColor)
            
            colors.append(UIColor(red:0.85, green:0.05, blue:0.14, alpha:1).CGColor)
            
            colors.append(UIColor(red:0.85, green:0.05, blue:0.14, alpha:1).CGColor)
            
            colors.append(UIColor(red:0.85, green:0.05, blue:0.14, alpha:0).CGColor)
            
            colors.append(UIColor.clearColor())
            
            gradientLayer.colors = colors;
            gradientLayer.startPoint = CGPointMake(0,0.5);
            gradientLayer.endPoint = CGPointMake(1,0.5);
            
            self.layer.addSublayer(shapeLayer)
            //gradientLayer.mask = shapeLayer
            i = i + 1;
            
            if(delta >= 10) {
                delta = 0;
            }
            else {
                // delta += 3;
            }
        }
        
        UIView.animateWithDuration(1, delay: 0, options: .AllowUserInteraction, animations: {
            self.blurEffectView!.alpha = 0.70
            self.alpha = 1;
            
            }, completion: { (t) in      
        })
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let x = self.frame.origin.x;
            let max = (self.frame.width * CGFloat(2)) - CGFloat(2);
            
            while(self.isAnimating){
               
                //dispatch_after(delayTime, dispatch_get_main_queue()) {
                    dispatch_sync(dispatch_get_main_queue()) {

                    if(self.frame.origin.x <= max) {
                        self.frame.origin.x += 1.5;
                    }
                    else{
                        self.frame.origin.x = x;
                        }
                    };
               // }
            }
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    deinit {
        
    }
}
