//
//  PlaybackManager.swift
//  li5
//
//  Created by Sergio Daniel on 7/2/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

class PlaybackManager : NSObject {
    
    // MARK: - CLASS MEMBERS
    
    static var shared: PlaybackManager = {
        return PlaybackManager()
    }()
    
    // MARK: - PROPERTIES
    
    // MARK: Stored Properties
    
    private var playerbackManagerKVOContext = 0
    
    @objc private var player: AVQueuePlayer? = AVQueuePlayer()
    
    private weak var delegate: PlaybackDelegate?
    
    private var endPlayObserver: NSObjectProtocol?
    
    private var automaticallyReplays = false {
        didSet {
            if automaticallyReplays {
                //player?.
                
                log.verbose("Setting up automatic replay for player on index: \(currentIndex)")
                
//                if endPlayObserver == nil {
//                    let item = playlistItems[currentIndex]
//                    
//                    endPlayObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
//                                                                             object: player?.currentItem,
//                                                                             queue: nil)
//                    { [weak self] (_) in
//                        log.verbose("Finished playing video.")
//                        
//                        DispatchQueue.main.async { [weak self] in
//                            self?.replay()
//                        }
//                    }
//                }
            } else {
//                if let observer = endPlayObserver {
//                    NotificationCenter.default.removeObserver(observer)
//                }
            }
        }
    }
    
    private var playlistItems = [AVPlayerItem]()
    
    private var currentIndex: Int = 0
    
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
    
    func attach(delegate: PlaybackDelegate, automaticallyReplays: Bool) -> AVPlayer {
        if player == nil {
            player = AVQueuePlayer()
        }
        
        self.delegate = delegate
        self.automaticallyReplays = automaticallyReplays
        
        addObserver(self, forKeyPath: #keyPath(PlaybackManager.player.currentItem.status),
                    options: [.new, .initial], context: &playerbackManagerKVOContext)
        
        return player!
    }
    
    
    func append(url: Foundation.URL) {
        let item = AVPlayerItem(url: url)
        playlistItems.append(item)
        player?.insert(item, after: nil)
    }
    
    
    func viewReadyToPlay() {
//        addObserver(self, forKeyPath: #keyPath(PlaybackManager.player.currentItem.duration),
//                    options: [.new, .initial], context: &playerbackManagerKVOContext)
        
        playIfReady()
    }
    
    
    private func playIfReady() {
        log.debug("Calling to play if ready...")
        
        if player?.status == .readyToPlay {
            player?.play()
        } else {
            log.warning("Tried to play but not ready yet for index: \(currentIndex)")
        }
    }
    
    
    private func play(index: Int) {
        player?.removeAllItems()
        
        for index in currentIndex...playlistItems.count {
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
    
    
    func playNext() {
        if currentIndex == playlistItems.count - 1 {
            log.error("Trying to go to next player item when there are no more enqueued")
        } else {
            currentIndex += 1
            player?.advanceToNextItem()
        }
    }
    
    
    func playPrevious() {
        if currentIndex == 0 {
            log.error("Trying to go to previous player item when the cursor is on zero position")
        } else {
            currentIndex -= 1
            play(index: currentIndex)
        }
    }
    
    
    
    
    
    private func goToZero() {
        player?.seek(to: kCMTimeZero)
    }
    
    
    func replay() {
        player?.seek(to: kCMTimeZero)
        player?.play()
    }
    
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        // Make sure the this KVO callback was intended for this view controller.
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
        } else if keyPath == #keyPath(PlaybackManager.player.currentItem.duration) {
            let newDuration: CMTime
            
            if let newDurationAsValue = change?[NSKeyValueChangeKey.newKey] as? NSValue {
                newDuration = newDurationAsValue.timeValue
            } else {
                newDuration = kCMTimeZero
            }
            
            guard let player = player else {
                return
            }
            
            let hasValidDuration = newDuration.isNumeric && newDuration.value != 0
            let newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0
            let currentTime = hasValidDuration ? Float(CMTimeGetSeconds(player.currentTime())) : 0.0
            
            log.verbose("Playback time: \(currentTime)")
            
            if currentTime == Float(newDurationSeconds) {
                replay()
            }
        }
    }
    
}
