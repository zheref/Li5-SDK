//
//  PresentTransition.swift
//  li5
//
//  Created by gustavo hansen on 9/23/16.
//  Copyright © 2016 ThriveCom. All rights reserved.
//

import Foundation

class PrensentationTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var initialFrame = CGRectZero

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let containerView : UIView? = transitionContext.containerView()
            else {
                return
        }
        
        containerView!.insertSubview(toVC.view, aboveSubview: fromVC.view)
        
        toVC.view.frame = self.initialFrame;
        UIView.animateWithDuration(
            1.0,
            animations: {
                toVC.view.frame = UIScreen.mainScreen().bounds;
            },
            completion: { _ in
               // fromVC.view.hidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
}
