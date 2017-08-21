//
//  MultiPlayer.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation
import AVFoundation

/// Context for recognizing context where the observer is been invoked from
private var queuePlayerViewKVOContext = 0

public protocol MultiPlayerDelegate: class {
    func didChange(player: AVPlayer?)
    func showLoadingScreen()
    func hideLoadingScreen()
}

public protocol MultiPlayerProtocol : PlayerProtocol {
    weak var delegate: MultiPlayerDelegate? { get set }
}


public class MultiPlayer: NSObject, MultiPlayerProtocol {
    
    // MARK: - STORED PROPERTIES
    
    weak public var delegate: MultiPlayerDelegate?
    
    /// Backup array of the items enqueued to be played
    var enqueuedItems = [Asset]()
    
    /// The object observing when the playback of the current item ends
    private var endPlayObserver: NSObjectProtocol?
    
    public var currentPlayer: AVPlayer? { return currentAsset?.player }
    
    /// The instance to the original AVPlayer
    public var originalPlayer: AVPlayer { return currentAsset!.player! }
    
    /// The index of the item currently being played
    public var currentIndex: Int = 0
    
    internal var currentAsset: Asset? {
        if enqueuedItems.count > currentIndex {
            return enqueuedItems[currentIndex]
        }
        
        return nil
    }
    
    public var currentItem: AVPlayerItem? {
        return currentAsset?.playerItem
    }
    
    public func append(asset: Asset) {
        enqueuedItems.append(asset)
    }
    
    /// Whether the current item should be played all over again once it ends
    public var automaticallyReplay: Bool = false {
        didSet {
            if automaticallyReplay {
                currentPlayer?.actionAtItemEnd = .none
                
                if let observer = endPlayObserver {
                    NotificationCenter.default.removeObserver(observer)
                    endPlayObserver = nil
                }
                
                endPlayObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                                         object: currentItem,
                                                                         queue: OperationQueue.main)
                { [weak self] _ in
                    self?.goToZero()
                    self?.play()
                }
            }
        }
    }
    
    
    private func goToZero() {
        //        self.seek(to: kCMTimeZero)
        self.currentItem?.seek(to: kCMTimeZero)
    }
    
    public func goNext() {
        goNext(startPlaying: true)
    }
    
    public func goNext(startPlaying: Bool) {
        if currentIndex == enqueuedItems.count - 1 {
            log.error("Trying to go to next player item when there are no more enqueued")
        } else {
            pause()
            let lastItem = currentItem
            currentIndex += 1
            currentItem?.seek(to: kCMTimeZero)
            
            if startPlaying { play() }
            
            lastItem?.seek(to: kCMTimeZero)
            automaticallyReplay = true
        }
    }
    
    public var status: AVPlayerStatus {
        return currentPlayer?.status ?? .unknown
    }
    
    public func goPrevious() {
        goPrevious(startPlaying: true)
    }
    
    public func goPrevious(startPlaying: Bool) {
        if currentIndex == 0 {
            log.error("Trying to go to previous player item when the cursor is on zero position")
        } else {
            pause()
            let lastItem = currentItem
            currentIndex -= 1
            currentItem?.seek(to: kCMTimeZero)
            
            if startPlaying { play() }
            
            lastItem?.seek(to: kCMTimeZero)
            automaticallyReplay = true
        }
    }
    
    public func play() {
        delegate?.didChange(player: currentPlayer)
        if let player = currentPlayer, player.status == .readyToPlay {
            player.play()
        } else {
            delegate?.showLoadingScreen()
            log.warning("Tried to play but not ready yet for index: \(currentIndex)")
        }
    }
    
    public func pause() {
        currentPlayer?.pause()
    }
    
    public func settle() {
        addObserver(self, forKeyPath: #keyPath(currentItem.status),
                    options: [.new, .initial], context: &queuePlayerViewKVOContext)
        addObserver(self, forKeyPath: #keyPath(currentItem),
                    options: [.new, .initial], context: &queuePlayerViewKVOContext)
    }
    
    
    public func loosen() {
        removeObserver(self, forKeyPath: #keyPath(currentItem.status),
                       context: &queuePlayerViewKVOContext)
        
        removeObserver(self, forKeyPath: #keyPath(currentItem),
                       context: &queuePlayerViewKVOContext)
    }
    
    
    // MARK: KVO Observation
    
    // Update our UI when player or `player.currentItem` changes.
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &queuePlayerViewKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == #keyPath(currentItem) {
            //queueDidChangeWithOldPlayerItems(oldPlayerItems: [], newPlayerItems: player.items())
        } else if keyPath ==  #keyPath(currentItem.status) {
            // Display an error if status becomes `.Failed`.
            
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItemStatus
            
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
                
                if newStatus == .readyToPlay {
                    goToZero()
                    play()
                }
            }
            else {
                newStatus = .unknown
            }
            
            if newStatus == .failed {
                handleError(with: currentItem?.error?.localizedDescription, error: currentItem?.error)
            }
        }
    }
    
    
    private func handleError(with str: String?, error: Error?) {
        log.error(str ?? error?.localizedDescription ?? "Unknown error")
    }
    
}
