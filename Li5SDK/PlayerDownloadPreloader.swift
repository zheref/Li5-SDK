//
//  PlayerDownloadPreloader.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

import Foundation

protocol PlayerDownloadPreloaderProtocol: DownloadPreloaderProtocol {
    
}

public class PlayerDownloadPreloader: NSObject, PlayerDownloadPreloaderProtocol {
    
    struct Error: Swift.Error {
        static let unknownStatus = Error()
    }
    
    static var playerItemContext: String = "Dummy"
    
    public var delegate: PreloaderDelegate
    
    var knownAssets: [Foundation.URL: Asset]
    
    var preloadCompletion: PreloadCompletion?
    
    var playerItems: [Foundation.URL: AVPlayerItem]
    var players: [Foundation.URL: AVPlayer]
    
    public init(delegate: PreloaderDelegate) {
        knownAssets = [:]
        playerItems = [:]
        players = [:]
        self.delegate = delegate
    }
    
    private func media(for asset: Asset) -> AVAsset {
        if let media = asset.media {
            return media
        }
        
        return AVAsset(url: asset.url)
    }
    
    public func preload(asset: Asset, completion: @escaping PreloadCompletion) {
        asset.downloadStatus = .downloading
        
        if let existingAsset = knownAssets[asset.url] {
            print("Already have asset \(asset.url)")
            if existingAsset.downloadStatus == .downloaded {
                completion(existingAsset, nil)
            }
            
            return
        }
        knownAssets[asset.url] = asset
        
        preloadCompletion = completion
        let avAsset = media(for: asset)
        let playerItem = AVPlayerItem(asset: avAsset, automaticallyLoadedAssetKeys: ["playable", "hasProtectedContent"])
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &PlayerDownloadPreloader.playerItemContext)
        let player = AVPlayer(playerItem: playerItem)
        
        players[asset.url] = player
        playerItems[asset.url] = playerItem
    }
    
    deinit {
        print("Deallocating!")
        //        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &L5PlayerPreloader.playerItemContext)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &PlayerDownloadPreloader.playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        guard let preloadCompletion = preloadCompletion else { return }
        guard let playerItem = object as? AVPlayerItem else { return }
        guard let urlAsset = playerItem.asset as? AVURLAsset else { return }
        guard let knownAsset = knownAssets[urlAsset.url] else { return }
        guard let player = players[urlAsset.url] else { return }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItemStatus
            
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItemStatus(rawValue: statusNumber.intValue) ?? .unknown
            } else {
                status = .unknown
            }
            
            switch status {
            case .readyToPlay:
                print("The item is ready to play! \(urlAsset.url)")
                knownAsset.downloadStatus = .downloaded
                knownAsset.playerItem = playerItem
                knownAsset.player = player
                preloadCompletion(knownAsset, nil)
                playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &PlayerDownloadPreloader.playerItemContext)
            case .failed:
                print("The item failed to load!")
                preloadCompletion(knownAsset, playerItem.error)
            case .unknown:
                print("Something weird happened!")
                preloadCompletion(knownAsset, playerItem.error ?? Error.unknownStatus)
            }
        }
    }
    
}
