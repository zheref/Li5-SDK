//
//  DismissViewInteractor.swift
//  li5
//
//  Created by gustavo hansen on 9/22/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

import UIKit

public class DismissInteractor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
    var fromController : UIViewController?;
    var finalFrame : CGRect;
    var toController : UIViewController?;
    
    init(withFinalFrame frame: CGRect) {
        finalFrame = frame;
    }
    
    func handleGesture(sender: UIPanGestureRecognizer, controller: UIViewController) {
        
        let percentThreshold:CGFloat = 0.6
        
        // convert y-position to downward pull progress (percentage)
        let translation = sender.translationInView(controller.view)
        let verticalMovement = translation.y / controller.view.bounds.height
        let downwardMovement = fmaxf(Float(verticalMovement), 0.0)
        let downwardMovementPercent = fminf(downwardMovement, 1.0)
        let progress = CGFloat(downwardMovementPercent)
        fromController = controller;
        
        switch sender.state {
        case .Began:
            self.hasStarted = true
            
            controller.view.backgroundColor = UIColor.clearColor()
            
        case .Changed:
            self.shouldFinish = progress > percentThreshold
            
            if(shouldFinish) {
                complete({ (bb) in
                    
                    self.fromController!.dismissViewControllerAnimated(false, completion: nil)
                });
            }else {
                self.updateInteractiveTransition(progress)
            }
        case .Cancelled:
            
            self.cancelInteractiveTransition()
            self.hasStarted = false
        case .Ended:
            
            if(self.shouldFinish) {
                
                self.complete({ (bb) in
                    
                    self.fromController!.dismissViewControllerAnimated(false, completion: nil)
                });
                
            }else {
                fromController!.view.frame =  UIScreen.mainScreen().bounds
            }
            self.hasStarted = false
        default:
            break
        }
    }
    
    func complete(completion: ((Bool) -> Void)?) {
        
        self.fromController!.view.layoutIfNeeded()
        UIView.animateKeyframesWithDuration(
            2,
            delay: 0.5,
            options: .BeginFromCurrentState,
            animations: {
                
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/3, animations: {
                    
                    let origin = CGPoint(x: self.finalFrame.origin.x + 20, y:self.finalFrame.origin.y  + 20);
                    
                    self.fromController!.view.frame = CGRect(origin: origin, size: self.finalFrame.size);
                })
                
                UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 2/3, animations: {
                    
                    let origin = CGPoint(x: self.finalFrame.origin.x + 10, y:self.finalFrame.origin.y  + 10);
                    
                    self.fromController!.view.frame = CGRect(origin: origin, size: self.finalFrame.size);
                })
                
                UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1, animations: {
                    self.fromController!.view.frame = self.finalFrame;
                })
            },
            completion: { _ in
                UIView.animateKeyframesWithDuration(
                    1,
                    delay: 1,
                    options: .BeginFromCurrentState,
                    animations: {
                        
                        
                    },
                    completion: { _ in
                        completion?(true);
                })
        })
    }
    
    override public func updateInteractiveTransition(percentComplete: CGFloat) {
        
        let screenBounds = UIScreen.mainScreen().bounds
        
        let percent = (1 - percentComplete);
        
        let size = CGSize(width: screenBounds.width * percent,
                          height: screenBounds.height * percent);
        
        let origin = CGPoint(x: screenBounds.width - size.width , y: screenBounds.height - size.height);
        
        fromController!.view.frame = CGRect(origin: origin, size: size);
    }
}
