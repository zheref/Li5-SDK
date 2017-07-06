//
//  PlaybackAssetsManager.swift
//  li5
//
//  Created by Sergio Daniel on 7/5/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

protocol Li5PlaybackAssetsManagerDelegate {
    func managerDidFinishDownloadingRequiredAssets()
}

class PlaybackAssetsManager {
    
    // MARK: - CLASS PROPERTIES
    
    fileprivate static var surroundBy = 2
    
    // MARK: - INSTANCE PROPERTIES
    
    // MARK: Stored Properties
    
    let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "assetDownloadConfIdentifier")
    
    var assets = [Li5Asset]()
    
    var delegate: Li5PlaybackAssetsManagerDelegate?
    
    var assetURLSession: AVAssetDownloadURLSession!
    
    // MARK: - INSTANCE OPERATIONS
    
    // MARK: Public Operations
    
    /// Starts downloading the very first required assets to start a smooth experience
    func startDownloading() {
//        for i in 0...PlaybackAssetsManager.surroundBy {
//            download(index: i)
//        }
        
        download(index: 0)
    }
    
    /// Returns an AVPlayerItem ready with the already downloaded or pending to download asset
    /// - Parameter index: Required index
    /// - Returns: AVPlayerItem with its corresponding asset attached
    func itemReady(forIndex index: Int) -> AVPlayerItem {
        let asset = assets[index].asset
        return AVPlayerItem(asset: asset)
    }
    
    // MARK: Private Operations
    
    /// Starts the download process for the asset with the given index
    /// - Parameter index: Index of the asset, assuming its existence is sanity checked
    fileprivate func download(index: Int) {
        let pAsset = assets[index]
        
        log.debug("Starting download for index: \(index) -> \(pAsset.asset.url.absoluteURL)")
        
        let assetDownloadDelegate = PlaybackAssetsDownloadHandler(id: pAsset.id, delegate: self)
        
        assetURLSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration,
                                                    assetDownloadDelegate: assetDownloadDelegate,
                                                    delegateQueue: OperationQueue.main)
        
        let task = assetURLSession.makeAssetDownloadTask(asset: pAsset.asset, assetTitle: pAsset.id,
                                                         assetArtworkData: nil,
                                                         options: nil)
        pAsset.task = task
        pAsset.task?.resume()
        pAsset.status = .Downloading
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

