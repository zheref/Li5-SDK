//
//  CommonPreloadingManager.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation
import AVFoundation


protocol CommonPreloadingManagerProtocol : PreloadingManagerProtocol {
    
    
    
}


public class CommonPreloadingManager : CommonPreloadingManagerProtocol {
    
    // MARK: - CLASS PROPERTIES
    
    // MARK: - STORED PROPERTIES
    
    /// The array where assets are stored along with its media, metadata and status
    private var assets = [Asset]()
    
    /// The responsible of handling the progress and completion of buffering and caching of assets
    public var delegate: PreloadingManagerDelegate?
    
    /// The instance responsible of buffering the video to play it
    private var bufferer: BufferPreloaderProtocol?
    
    /// The instance responsible of downloading into local storage to cache content
    private var downloader: DownloadPreloaderProtocol?
    
    /// The amount of videos that can be buffered at the same time
    var simultaneousBufferAmount: Int
    
    /// The minimum amount of videos that must be successfully buffered before starting playback
    var minimumBufferedVideosToStart: Int
    
    public var ready: Bool = false
    
    // MARK: - COMPUTED PROPERTIES
    
    public var currentAsset: Asset? {
        if let delegate = delegate {
            return assets[delegate.playingIndex]
        }
        
        return nil
    }
    
    // MARK: - INSTANCE OPERATIONS
    
    /// MARK: - Initializers
    
    /// Initializes a new L5PreloadingManager with the given assets, delegate, bufferer and downloader
    ///
    /// - Parameters:
    ///   - assets: The list of assets to be managed
    ///   - sameTimeBufferAmount: The amount of videos that can be buffered at the same time
    ///   - minimumBufferedVideosToStart: The amount of videos that must be successfully buffered before playback
    ///   - delegate: The responsible to answer for the different events during the assets management
    ///   - bufferer: The responsible to provide a mechanism to preemptively load videos by buffering
    ///   - downloader: The reponsible to provide a mechanism to cache videos by downloading
    public required init(assets: [Asset],
                         sameTimeBufferAmount: Int,
                         minimumBufferedVideosToStartPlaying: Int,
                         bufferer: BufferPreloaderProtocol? =  nil,
                         downloader: DownloadPreloaderProtocol? = nil) {
        
        self.simultaneousBufferAmount = sameTimeBufferAmount
        self.minimumBufferedVideosToStart = minimumBufferedVideosToStartPlaying
        self.assets = assets
        setup(bufferer: bufferer, downloader: downloader)
    }
    
    // MARK: Public Operations
    
    /// Sets up a new bufferer or downloader.
    /// This method should be used to switch between mechanisms.
    /// - Parameters:
    ///   - bufferer: The responsible to provide a mechanism to preemptively load videos by buffering
    ///   - downloader: The reponsible to provide a mechanism to cache videos by downloading
    public func setup(bufferer: BufferPreloaderProtocol? = nil,
                      downloader: DownloadPreloaderProtocol? = nil) {
        
        self.bufferer = bufferer
        self.downloader = downloader
    }
    
    /// Starts preloading videos by buffering and/or caching according to the configuration
    public func startPreloading() {
        if ready {
            delegate?.managerIsReadyForPlayback()
        } else {
            for asset in assets {
                delegate?.player?.append(asset: asset)
            }
        }
        
        for i in 0...(self.simultaneousBufferAmount-1) {
            preload(index: i)
        }
    }
    
    // MARK: Private Operations
    
    /// Preload the video corresponding to the given index by buffering and/or downloading
    /// according to the setup configuration.
    /// - Parameter index: The index to be preloaded
    public func preload(index: Int) {
        let asset = assets[index]
        
        log.debug("Starting preloading: \(index) -> \(asset.url.absoluteURL)")
        
        asset.bufferStatus = .buffering
        
        downloader?.preload(asset: asset) { [weak self] (asset, error) in
            asset.bufferStatus = .buffered
            
            guard let `self` = self else {
                log.warning("Lost reference of L5PreloadingManager.self")
                return
            }
            
            if let nextIndexToDownload = self.assets.index(where: { $0.bufferStatus == .notStarted }) {
                self.preload(index: nextIndexToDownload)
            } else {
                log.verbose("No index found to continue buffering")
            }
            
            self.delegate?.didPreload(asset)
            
            let alreadyBufferedAssets = self.assets.filter { $0.bufferStatus == .buffered }
            
            if self.isEnough(bufferedAssetsAmount: alreadyBufferedAssets.count) {
                self.ready = true
                self.delegate?.managerIsReadyForPlayback()
            }
        }
    }
    
    /// Determines whether the given amount of buffered assets is enough to satisfy the setup
    /// requirements or not.
    /// - Parameter bufferedAssetsAmount: The amount of already buffered assets
    /// - Returns: Whether it is enough to satisfy requirements or not
    private func isEnough(bufferedAssetsAmount: Int) -> Bool {
        return bufferedAssetsAmount == self.minimumBufferedVideosToStart
    }
    
}


extension CommonPreloadingManager : PreloaderDelegate {
    
    public func didPreload(asset: Asset, by amount: Double) {
        
    }
    
    public func didFinishPreloading(asset: Asset) {
        
    }
    
    public func didFailPreloading(asset: Asset, withError error: Error) {
        
    }
    
}
