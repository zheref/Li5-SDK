//
//  PlaybackManager.swift
//  li5
//
//  Created by Sergio Daniel on 7/2/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

@objc class PlaybackManager : NSObject {
    
    // MARK: - CLASS MEMBERS
    
    static var shared: PlaybackManager = {
        return PlaybackManager()
    }()
    
    // MARK: - PROPERTIES
    
    // MARK: Stored Properties
    
    var player: AVQueuePlayer? = AVQueuePlayer()
    
    private var playerbackManagerKVOContext = 0
    
    private weak var delegate: PlaybackDelegate?
    
    private var endPlayObserver: NSObjectProtocol?
    
    /// Determines whether the current played item should loop/repeat or not
    private var automaticallyReplays = false {
        didSet {
            if automaticallyReplays {
                log.verbose("Setting up automatic replay for player on index: \(currentIndex)")
                
                setAutomaticReplay()
            } else {
                player?.actionAtItemEnd = .pause
                
                if let observer = endPlayObserver {
                    NotificationCenter.default.removeObserver(observer)
                }
                
                endPlayObserver = nil
            }
        }
    }
    
    private var playlistItems = [AVPlayerItem]()
    
    /// The index of the item currently in playback
    private var currentIndex: Int = 0
    
    /// The index willing to be played right now
    private var continueWithIndex: Int = 0
    
    // MARK: Computed Properties
    
    var readyToPlayCurrentItem: Bool {
        if player == nil {
            return false
        } else {
            return player!.status == .readyToPlay
        }
    }
    
    // MARK: - INITIALIZERS
    
    private override init() {}
    
    // MARK: - ROUTINES
    
    /// Attaches the currently displayed view controller to back the media playback
    /// - Parameters:
    ///   - delegate: The currently displayed responsible of handling and playing the media
    ///   - automaticallyReplays: Whether the current item should play in loop or not
    func attach(delegate: PlaybackDelegate, index: Int, automaticallyReplays: Bool) {
        self.delegate = delegate
        self.automaticallyReplays = automaticallyReplays
        self.continueWithIndex = index
        
        addObserver(self, forKeyPath: #keyPath(PlaybackManager.player.currentItem.status),
                    options: [.new, .initial], context: &playerbackManagerKVOContext)
    }
    
    /// Enqueue URL as AVPlayerItem into the manager for it to be played when its turn comes
    /// - Parameter url: The URL of the media track to play
    func append(url: Foundation.URL) {
        let item = AVPlayerItem(url: url)
        playlistItems.append(item)
        player?.insert(item, after: nil)
    }
    
    /// Notifies the current playback host is ready to play (ex. is already displayed)
    func viewReadyToPlay() {
        if continueWithIndex == currentIndex {
            playIfReady()
        } else {
            continuePlayback()
        }
    }
    
    private func setAutomaticReplay() {
        if automaticallyReplays {
            player?.actionAtItemEnd = .none
            
            if endPlayObserver != nil {
                NotificationCenter.default.removeObserver(endPlayObserver!)
                endPlayObserver = nil
            }
            
            endPlayObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                                     object: player?.currentItem,
                                                                     queue: nil)
            { [weak self] (_) in
                log.verbose("Finished playing video.")
                
                DispatchQueue.main.async { [weak self] in
                    self?.replay()
                }
            }
        }
    }
    
    /// When current playback item index is different than the continueWithIndex (willing to play now)
    /// do the necessary procedures for it to start playing the following index and match the model
    private func continuePlayback() {
        if continueWithIndex == currentIndex + 1 {
            currentIndex = continueWithIndex
            
            player?.advanceToNextItem()
        } else {
            currentIndex = continueWithIndex
            
            player?.removeAllItems()
            
            for index in currentIndex...playlistItems.count-1 {
                let item = playlistItems[index]
                
                if player == nil { player = AVQueuePlayer() }
                
                guard let player = player else {
                    log.error("Player nil?!! But I just sanity-checked it! Dark magic!!!")
                    return
                }
                
                if player.canInsert(item, after: nil) {
                    player.seek(to: kCMTimeZero)
                    player.insert(item, after: nil)
                } else {
                    log.warning("Wasn't able to insert av player item while refreshign for specific play")
                }
            }
            
            printEnqueuedItems()
            
            if player?.status == .readyToPlay {
                player?.play()
            } else {
                log.warning("Tried to play but not ready yet for index: \(currentIndex)")
            }
        }
        
        setAutomaticReplay()
    }
    
    
    private func playIfReady() {
        log.debug("Calling to play if ready...")
        
        if player?.status == .readyToPlay {
            player?.play()
        } else {
            log.warning("Tried to play but not ready yet for index: \(currentIndex)")
        }
    }
    
    
    public func videoWillChange() {
        player?.pause()
        goToZero()
        
        
        
        //kvoController.unobserve(_playerItem)
        
        //        if let currentItem = currentItem {
        //            NotificationCenter.default.removeObserver(currentItem)
        //        }
        
        //        output = nil
        //        _playerItem = nil
        //
        //        if (self.timeObserver != nil) {
        //            self.removeTimeObserver(self.timeObserver!);
        //            self.timeObserver = nil;
        //        }
    }
    
    
    func printEnqueuedItems() {
        if let player = player {
            log.debug("Enqueued items:")
            
            for item in player.items() {
                log.debug(item.description)
            }
            
            log.debug("-------- ------")
        } else {
            log.debug("Playlist items:")
            
            for item in playlistItems {
                log.debug(item.description)
            }
            
            log.debug("-------- ------")
        }
    }
    
    
    /// Replay the current item from the beginning
    private func replay() {
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    
    private func playNext() {
        if currentIndex == playlistItems.count - 1 {
            log.error("Trying to go to next player item when there are no more enqueued")
        } else {
            currentIndex += 1
            player?.advanceToNextItem()
        }
    }
    
    
    private func playPrevious() {
        if currentIndex == 0 {
            log.error("Trying to go to previous player item when the cursor is on zero position")
        } else {
            continueWithIndex = currentIndex - 1
            continuePlayback()
        }
    }
    
    /// Goes to the position zero of the playback
    private func goToZero() {
        player?.seek(to: kCMTimeZero)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        guard context == &playerbackManagerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath ==  #keyPath(PlaybackManager.player.currentItem.status) {
            let newStatus: AVPlayerItemStatus
            
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItemStatus(rawValue: newStatusAsNumber.intValue)!
            } else {
                newStatus = .unknown
            }
            
            if newStatus == .failed {
                delegate?.handleError(with: player?.currentItem?.error?.localizedDescription,
                                      error: player?.currentItem?.error)
            } else if newStatus == .readyToPlay {
                delegate?.bufferIsReadyToPlay()
            }
        }
    }
    
}
