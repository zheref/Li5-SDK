//
//  PlaybackAssetsManager.swift
//  li5
//
//  Created by Sergio Daniel on 7/5/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

protocol Li5PlaybackAssetsManagerDelegate {
    
    func requiredAssetIsBuffering(_ asset: Li5Asset)
    
    func requiredAssetIsReady(_ asset: Li5Asset)
    
    func managerDidFinishBufferingMinimumRequiredAssets()
    
    func managerDidFinishDownloadingRequiredAssets()
}

class PlaybackAssetsManager {
    
    // MARK: - CLASS PROPERTIES
    
    fileprivate static var surroundBy = 1
    
    fileprivate static var minimumRequiredPreloadedAssets = 4
    
    // MARK: - INSTANCE PROPERTIES
    
    // MARK: Stored Properties
    
    let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "assetDownloadConfIdentifier")
    
    /// The array where assets are stored along with its media, metadata and status
    var assets = [Li5Asset]()
    
    /// The responsible of handling the progress and completion of buffering and caching of assets
    var delegate: Li5PlaybackAssetsManagerDelegate?
    
    var assetURLSession: AVAssetDownloadURLSession!
    
    // MARK: - INSTANCE OPERATIONS
    
    // MARK: Public Operations
    
    func startPreemptive() {
        for i in 0...PlaybackAssetsManager.surroundBy {
            preemptiveLoad(index: i)
        }
    }
    
    /// Starts downloading the very first required assets to start a smooth experience
    func startDownloading() {
        for i in 0...PlaybackAssetsManager.surroundBy {
            download(index: i)
        }
    }
    
    /// Returns an AVPlayerItem ready with the already downloaded or pending to download asset
    /// - Parameter index: Required index
    /// - Returns: AVPlayerItem with its corresponding asset attached
    func itemReady(forIndex index: Int) -> AVPlayerItem {
        return AVPlayerItem(asset: assets[index].media)
    }
    
    // MARK: Private Operations
    
    fileprivate func preemptiveLoad(index: Int) {
        let asset = assets[index]
        
        log.debug("Starting preemptive loading for index: \(index) -> \(asset.media.url.absoluteURL)")
        
        asset.bufferStatus = .Buffering
        
        asset.media.loadValuesAsynchronously(forKeys: ["playable", "tracks", "duration", "hasProtectedContent"]) { [weak self] in
            guard let this = self else {
                log.warning("PlaybackAssetsManager self instance lost on callback of asset loadValuesAsynchronously")
                return
            }
            
            asset.bufferStatus = .Buffered
            
            this.delegate?.requiredAssetIsReady(asset)
            
            if let nextIndexToDownload = this.assets.index(where: { [weak self] (asset) -> Bool in
                return asset.bufferStatus == .Pending
            }) {
                guard let this = self else {
                    log.warning("Lost reference to PlaybackAssetsManager.self")
                    return
                }
                
                this.preemptiveLoad(index: nextIndexToDownload)
            } else {
                log.debug("No index found to continue buffering")
            }
            
            let alreadyBufferedAssets = this.assets.filter { (asset) -> Bool in
                return asset.bufferStatus == .Buffered
            }
            
            if alreadyBufferedAssets.count > PlaybackAssetsManager.minimumRequiredPreloadedAssets &&
                alreadyBufferedAssets.count < PlaybackAssetsManager.minimumRequiredPreloadedAssets + 2 {
                
                this.delegate?.managerDidFinishBufferingMinimumRequiredAssets()
            }
        }
        
        delegate?.requiredAssetIsBuffering(asset)
    }
    
    /// Starts the download process for the asset with the given index
    /// - Parameter index: Index of the asset, assuming its existence is sanity checked
    fileprivate func download(index: Int) {
        let asset = assets[index]
        
        log.debug("Starting download for index: \(index) -> \(asset.media.url.absoluteURL)")
        
        let assetDownloadDelegate = PlaybackAssetsDownloadHandler(id: asset.id, delegate: self)
        
        assetURLSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration,
                                                    assetDownloadDelegate: assetDownloadDelegate,
                                                    delegateQueue: OperationQueue.main)
        
        let task = assetURLSession.makeAssetDownloadTask(asset: asset.media, assetTitle: asset.id,
                                                         assetArtworkData: nil,
                                                         options: nil)
        asset.task = task
        asset.task?.resume()
        asset.status = .Downloading
    }
    
    /// Update asset with given id as downloaded setting its assigned location URL and updating
    /// its status to downloaded
    /// - Parameters:
    ///   - id: The id of the asset to update as downloaded
    ///   - location: The location given to its persisted resources after being completely downloaded
    fileprivate func updateAssetAsDownloaded(id: String, location: Foundation.URL) {
        if let asset = assets.first(where: { (asset) -> Bool in
            asset.id == id
        }) {
            asset.locationUrl = location
            asset.status = .Downloaded
        } else {
            log.error("Asset not found with id: \(id)")
        }
    }
    
}


extension PlaybackAssetsManager : DownloadHandlerDelegate {
    
    func didFinishDownloadingAsset(withId id: String, intoLocation location: Foundation.URL) {
        log.verbose("Finished downloading asset with id: \(id)")
        updateAssetAsDownloaded(id: id, location: location)
        
        if let nextIndexToDownload = assets.index(where: { (asset) -> Bool in
            asset.status == .NotStarted
        }) {
            download(index: nextIndexToDownload)
        }
        
        let alreadyDownloadedAssets = assets.filter { (asset) -> Bool in
            asset.status == .Downloaded
        }
        
        if alreadyDownloadedAssets.count > PlaybackAssetsManager.surroundBy {
            delegate?.managerDidFinishDownloadingRequiredAssets()
        }
    }
    
}

