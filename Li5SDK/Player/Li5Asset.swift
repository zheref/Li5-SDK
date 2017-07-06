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

class Li5Asset {
    
    let id: String
    let asset: AVURLAsset
    
    var status: Li5AssetStatus = .NotStarted
    
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
    
    init(id: String, asset: AVURLAsset) {
        self.id = id
        self.asset = asset
    }
    
}
