//
//  CardStackUICollectionViewLayout.swift
//  li5
//
//  Created by Martin Cocaro on 6/17/16.
//  Copyright © 2016 Li5, Inc. All rights reserved.
//

import UIKit

public class CardStackUICollectionViewLayout: UICollectionViewLayout, UIGestureRecognizerDelegate {

    // MARK: - Properties
    
    /// The index of the card that is currently on top of the stack. The index 0 represents the oldest card of the stack.
    var index: Int = 0 {
        didSet {
            //workaround for zIndex
            draggedCellPath = oldValue > index ? NSIndexPath(forItem: index, inSection: 0) : NSIndexPath(forItem: oldValue, inSection: 0)
            let cell = collectionView!.cellForItemAtIndexPath(draggedCellPath!)
            collectionView?.bringSubviewToFront(cell!)
            
            collectionView?.performBatchUpdates({
                _ = self.invalidateLayout()
                }, completion: { (Bool) in
//                    _ = self.delegate?.cardDidChangeState(self.index)
            })
        }
    }
    
//    var delegate: TisprCardStackViewControllerDelegate?
    
    /// The maximum number of cards displayed on the top stack. This value includes the currently visible card.
    @IBInspectable public var topStackMaximumSize: Int = 3
    
    /// The maximum number of cards displayed on the bottom stack.
    @IBInspectable public var bottomStackMaximumSize: Int = 3
    
    /// The visible height of the card of the bottom stack.
    @IBInspectable public var bottomStackCardHeight: CGFloat = 50
    
    /// The size of a card in the stack layout.
    @IBInspectable var cardSize: CGSize = CGSizeMake(280, 380)
    
    // The inset or outset margins for the rectangle around the card.
    @IBInspectable public var cardInsets: UIEdgeInsets = UIEdgeInsetsZero
    
    //if new card should appear on the bottom
    @IBInspectable internal var newCardShouldAppearOnTheBottom: Bool = true
    
    /// A Boolean value indicating whether the pan and swipe gestures on cards are enabled.
    @IBInspectable var gesturesEnabled: Bool = false {
        didSet {
            if (gesturesEnabled) {
                tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                tapRecognizer?.delegate = self
                collectionView?.addGestureRecognizer(tapRecognizer!);
                
                let recognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
                collectionView?.addGestureRecognizer(recognizer)
                panGestureRecognizer = recognizer
                panGestureRecognizer!.delegate = self
                
                swipeRecognizerDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
                swipeRecognizerDown!.direction = UISwipeGestureRecognizerDirection.Down
                swipeRecognizerDown!.delegate = self
                collectionView?.addGestureRecognizer(swipeRecognizerDown!)
                swipeRecognizerDown!.requireGestureRecognizerToFail(panGestureRecognizer!)
                
                swipeRecognizerUp = UISwipeGestureRecognizer(target: self, action:  #selector(handleSwipe))
                swipeRecognizerUp!.direction = UISwipeGestureRecognizerDirection.Up
                swipeRecognizerUp!.delegate = self
                collectionView?.addGestureRecognizer(swipeRecognizerUp!)
                swipeRecognizerUp!.requireGestureRecognizerToFail(panGestureRecognizer!)
            } else {
                if let recognizer = panGestureRecognizer {
                    collectionView?.removeGestureRecognizer(recognizer)
                }
                if let swipeDownRecog = swipeRecognizerDown {
                    collectionView?.removeGestureRecognizer(swipeDownRecog)
                }
                if let swipeUpRecog = swipeRecognizerUp {
                    collectionView?.removeGestureRecognizer(swipeUpRecog)
                }
                if let tapRecog = tapRecognizer {
                    collectionView?.removeGestureRecognizer(tapRecog)
                }
                
            }
        }
    }
    
    // Index path of dragged cell
    private var draggedCellPath: NSIndexPath?
    
    // The initial center of the cell being dragged.
    private var initialCellCenter: CGPoint?
    
    // The rotation values of the bottom stack cards.
    private var bottomStackRotations = [Int: Double]()
    
    // Is the animation for new cards in progress?
    private var newCardAnimationInProgress: Bool = false
    
    /// Cards from bottom stack will be rotated with angle = coefficientOfRotation * hade.
    @IBInspectable private let coefficientOfRotation: Double = 0.25
    
    @IBInspectable private let angleOfRotationForNewCardAnimation: CGFloat = 0.25
    
    @IBInspectable private let verticalOffsetBetweenCardsInTopStack: CGFloat = 35
    @IBInspectable private let horizontalOffsetBetweenCardsInTopStack: CGFloat = 15.0
    @IBInspectable private let centralCardYPosition: CGFloat = 35
    
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var swipeRecognizerDown: UISwipeGestureRecognizer?
    private var swipeRecognizerUp: UISwipeGestureRecognizer?
    private var tapRecognizer: UITapGestureRecognizer?
    
    @IBInspectable private let minimumXPanDistanceToSwipe: CGFloat = 100
    @IBInspectable private let minimumYPanDistanceToSwipe: CGFloat = 60
    
    // MARK: - Getting the Collection View Information
    
    override public func collectionViewContentSize() -> CGSize {
        return collectionView!.frame.size
    }
    
    // MARK: - Providing Layout Attributes
    
    override public func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var result :UICollectionViewLayoutAttributes?
        if ((newCardShouldAppearOnTheBottom && itemIndexPath.item == collectionView!.numberOfItemsInSection(0) - 1) || (!newCardShouldAppearOnTheBottom && itemIndexPath.item == 0)) && newCardAnimationInProgress {
            result = UICollectionViewLayoutAttributes(forCellWithIndexPath: itemIndexPath)
            let yPosition = collectionViewContentSize().height - cardSize.height            //Random direction
            let directionFromRight = arc4random() % 2 == 0
            let xPosition = directionFromRight ? collectionViewContentSize().width : -cardSize.width
            
            let cardFrame = CGRectMake(CGFloat(xPosition), yPosition, cardSize.width, cardSize.height)
            result!.frame = cardFrame
            result!.zIndex = 1000 - itemIndexPath.item
            result!.hidden = false
            result!.transform3D = CATransform3DMakeRotation(directionFromRight ?angleOfRotationForNewCardAnimation : -angleOfRotationForNewCardAnimation, 0, 0, 1)
        }
        return result
    }
    
    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let indexPaths = indexPathsForElementsInRect(rect)
        let layoutAttributes = indexPaths.map { self.layoutAttributesForItemAtIndexPath($0) }.filter { $0 != nil }.map {
            $0!
        }
        return layoutAttributes
    }
    
    public override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        var result = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        if (indexPath.item >= index) {
            result = layoutAttributesForTopStackItemWithInitialAttributes(result)
            //we have to hide invisible cards in top stask due perfomance issues due shadows
            result.hidden = (result.indexPath.item >= index + topStackMaximumSize)
            result.alpha = 1.0 - 0.1*CGFloat( indexPath.item - index )
        } else {
            result = layoutAttributesForBottomStackItemWithInitialAttributes(result)
            //we have to hide invisible cards in bottom stask due perfomance issues due shadows
            result.hidden = (result.indexPath.item < (index - bottomStackMaximumSize))
        }
        
        if indexPath.item == draggedCellPath?.item  {
            //workaround for zIndex
            result.zIndex = 100000
        } else {
            result.zIndex = (indexPath.item >= index) ? (1000 - indexPath.item) : (1000 + indexPath.item)
        }
        
        return result
    }
    // MARK: - Implementation
    
    private func indexPathsForElementsInRect(rect: CGRect) -> [NSIndexPath] {
        var result = [NSIndexPath]()
        
        let count = collectionView!.numberOfItemsInSection(0)
        
        let topStackCount = min(count - (index + 1), topStackMaximumSize - 1)
        let bottomStackCount = min(index, bottomStackMaximumSize)
        
        let start = index - bottomStackCount
        let end = (index + 1) + topStackCount
        
        for i in start..<end {
            result.append(NSIndexPath(forItem: i, inSection: 0))
        }
        return result
    }
    
    private func layoutAttributesForTopStackItemWithInitialAttributes(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        //we should not change position for card which will be hidden for good animation
        let minYPosition = centralCardYPosition + verticalOffsetBetweenCardsInTopStack*CGFloat(topStackMaximumSize - 1)
        var yPosition = centralCardYPosition + verticalOffsetBetweenCardsInTopStack*CGFloat(attributes.indexPath.row - index)
        yPosition = min(yPosition,minYPosition)
        
        //right position for new card
        if attributes.indexPath.item == collectionView!.numberOfItemsInSection(0) - 1 && newCardAnimationInProgress {
            //New card has to be displayed if there are no topStackMaximumSize cards in the top stack
            if attributes.indexPath.item >= index && attributes.indexPath.item < index + topStackMaximumSize {
                yPosition = centralCardYPosition - verticalOffsetBetweenCardsInTopStack*CGFloat(attributes.indexPath.row - index)
            } else {
                attributes.hidden = true
                yPosition = centralCardYPosition
            }
        }
        
        let xPosition = (collectionView!.frame.size.width - cardSize.width)/2 + CGFloat(attributes.indexPath.row - index)*horizontalOffsetBetweenCardsInTopStack
        
        let cardWidth = cardSize.width - (CGFloat(attributes.indexPath.row) - CGFloat(index))*horizontalOffsetBetweenCardsInTopStack*2.0
        let cardHeight = cardWidth * ( cardSize.height / cardSize.width )
        yPosition += CGFloat(cardSize.height) - CGFloat(cardHeight)
        
        let cardFrame = CGRectMake(xPosition, CGFloat(yPosition), cardWidth, cardHeight)
        attributes.frame = cardFrame
        
        return attributes
    }
    
    private func layoutAttributesForBottomStackItemWithInitialAttributes(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let yPosition = collectionView!.frame.size.height - bottomStackCardHeight
        let xPosition = (collectionView!.frame.size.width - cardSize.width)/2
        
        let frame = CGRectMake(xPosition, CGFloat(yPosition), cardSize.width, cardSize.height)
        attributes.frame = frame
        
        if let angle = bottomStackRotations[attributes.indexPath.item] {
            attributes.transform3D = CATransform3DMakeRotation(CGFloat(angle), 0, 0, 1)
        }
        
        return attributes
    }
    
    // MARK: - Handling the Swipe and Pan Gesture
    
    internal func handleSwipe(sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case UISwipeGestureRecognizerDirection.Up:
            // Take the card at the current index
            // and process the swipe up only if it occurs below it
            //            var temIndex = index
            //            if temIndex >= collectionView!.numberOfItemsInSection(0) {
            //                temIndex--
            //            }
            //            let currentCard = collectionView!.cellForItemAtIndexPath(NSIndexPath(forItem: temIndex , inSection: 0))!
            //            let point = sender.locationInView(collectionView)
            //            if (point.y > CGRectGetMaxY(currentCard.frame) && index > 0) {
            if (index > 0) {
                index -= 1
            }
        //            }
        case UISwipeGestureRecognizerDirection.Down:
            if index + 1 < collectionView!.numberOfItemsInSection(0) {
                index += 1
            }
        default:
            break
        }
    }
    
    internal func handlePan(sender: UIPanGestureRecognizer) {
        if (sender.state == .Began) {
            let initialPanPoint = sender.locationInView(collectionView)
            findDraggingCellByCoordinate(initialPanPoint)
        } else if (sender.state == .Changed) {
            let newCenter = sender.translationInView(collectionView!)
            updateCenterPositionOfDraggingCell(newCenter)
        } else {
            if let indexPath = draggedCellPath {
                finishedDragging(collectionView!.cellForItemAtIndexPath(indexPath)!)
            }
        }
    }

    internal func handleTap(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) {
            let initialPanPoint = sender.locationInView(collectionView)
            if let indexPath = collectionView?.indexPathForItemAtPoint(initialPanPoint) {
                moveCard(indexPath)
            }
        }
    }
    
    //Define what card should we drag
    private func findDraggingCellByCoordinate(touchCoordinate: CGPoint) {
        if let indexPath = collectionView?.indexPathForItemAtPoint(touchCoordinate) {
            if indexPath.item >= index {
                //top stack
                draggedCellPath = NSIndexPath(forItem: index, inSection: 0)
                initialCellCenter = collectionView?.cellForItemAtIndexPath(draggedCellPath!)?.center
            } else {
                //bottomStack
                if (index > 0 ) {
                    draggedCellPath = NSIndexPath(forItem: index - 1, inSection: 0)
                }
                initialCellCenter = collectionView?.cellForItemAtIndexPath(draggedCellPath!)?.center
            }
            
            //workaround for fix issue with zIndex
            let cell = collectionView!.cellForItemAtIndexPath(draggedCellPath!)
            collectionView?.bringSubviewToFront(cell!)
            
        }
    }
    
    //Change position of dragged card
    private func updateCenterPositionOfDraggingCell(touchCoordinate:CGPoint) {
        if let strongDraggedCellPath = draggedCellPath {
            if let cell = collectionView?.cellForItemAtIndexPath(strongDraggedCellPath) {
                let newCenterX = (initialCellCenter!.x + touchCoordinate.x)
                let newCenterY =  (initialCellCenter!.y + touchCoordinate.y)
                cell.center = CGPoint(x: newCenterX, y:newCenterY)
                cell.transform = CGAffineTransformMakeRotation(CGFloat(storeAngleOfRotation()))
            }
        }
    }
    
    private func moveCard(indexPath: NSIndexPath) {
        if (index + 1 == collectionView!.numberOfItemsInSection(0))
        {
            while ( index != 0 )
            {
                index -= 1;
            }
        }
        else
        {
            if indexPath.item == index {
                index += 1
            } else {
                index = indexPath.item
            }
        }
        initialCellCenter = CGPointZero
        draggedCellPath = nil
    }
    
    private func finishedDragging(cell: UICollectionViewCell) {
        let deltaX = abs(cell.center.x - initialCellCenter!.x)
        let deltaY = abs(cell.center.y - initialCellCenter!.y)
        let shouldSnapBack = (deltaX < minimumXPanDistanceToSwipe && deltaY < minimumYPanDistanceToSwipe)
        if shouldSnapBack {
            UIView.setAnimationsEnabled(false)
            collectionView!.reloadItemsAtIndexPaths([self.draggedCellPath!])
            UIView.setAnimationsEnabled(true)
        } else {
            storeAngleOfRotation()
            if draggedCellPath?.item == index {
                index += 1
            } else {
                index -= 1
            }
            initialCellCenter = CGPointZero
            draggedCellPath = nil
        }
    }
    
    //Compute and Store angle of rotation
    private func storeAngleOfRotation() -> Double  {
        var result:Double = 0
        if let strongDraggedCellPath = draggedCellPath {
            if let cell = collectionView?.cellForItemAtIndexPath(strongDraggedCellPath) {
                let centerYIncidence = collectionView!.frame.size.height + cardSize.height - bottomStackCardHeight
                let gamma:Double = Double((cell.center.x -  collectionView!.bounds.size.width/2)/(centerYIncidence - cell.center.y))
                result = atan(gamma)
                bottomStackRotations[strongDraggedCellPath.item] = atan(gamma)*coefficientOfRotation
            }
        }
        return result
    }
    
    // MARK: - appearance of new card
    
    func newCardDidAdd(newCardIndex:Int) {
        collectionView?.performBatchUpdates({ [weak self] _ in
            self?.newCardAnimationInProgress = true
            self?.collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: newCardIndex, inSection: 0)])
            }, completion: {[weak self] _ in
                _ = self?.newCardAnimationInProgress = false
            })
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        var result:Bool = true
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocityInView(collectionView)
            result = abs(Int(velocity.y)) < 250
        }
        return result
    }
    
}
