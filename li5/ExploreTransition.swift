//
//  ExploreInteractor.swift
//  li5
//
//  Created by gustavo hansen on 9/27/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

import Foundation

class ExploreTransition : NSObject {
}

extension ExploreTransition : UIViewControllerAnimatedTransitioning {
    
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
        
        containerView!.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        let screenBounds = UIScreen.mainScreen().bounds
        let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: CGSize(width: 0, height: 0))
        
        UIView.animateWithDuration(
            transitionDuration(transitionContext),
            animations: {
                
                //  fromVC.view.layer.mask = UIBezierPath(ovalInRect:finalFrame).bezierPathByReversingPath().CGPath;
                //[[UIBezierPath bezierPathWithOvalInRect:rect] bezierPathByReversingPath];
                fromVC.view.alpha = 0;
                toVC.view.alpha = 1;
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
        )
    }
}
