//
//  Li5Asset.swift
//  li5
//
//  Created by Sergio Daniel on 7/5/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

enum Li5AssetStatus {
    case NotStarted
    case Downloading
    case Downloaded
}

enum Li5BufferStatus {
    case Pending
    case Buffering
    case Buffered
}

enum Li5QueueStatus {
    case NotEnqueued
    case Enqueued
    case Playing
    case Played
}

class Li5Asset {
    
    // MARK: - STORED PROPERTIES
    
    let id: String
    let media: AVURLAsset
    
    var status: Li5AssetStatus = .NotStarted
    var bufferStatus: Li5BufferStatus = .Pending
    var queueStatus: Li5QueueStatus = .NotEnqueued
    
    var task: AVAssetDownloadTask?
    
    var locationUrl: Foundation.URL? {
        didSet {
            log.verbose("Saving URL for \(persistenceKey)")
            UserDefaults.standard.set(locationUrl, forKey: persistenceKey)
        }
    }
    
    var persistenceKey: String {
        return "downloadedAsset(\(id))"
    }
    
    init(id: String, media: AVURLAsset) {
        self.id = id
        self.media = media
    }
    
}
