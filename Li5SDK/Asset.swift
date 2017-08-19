//
//  Asset.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

import Foundation
import AVFoundation


public class Asset {
    
    // MARK: - STORED PROPERTIES
    
    /// The URL this asset is representing. The validity should be checked before creating the asset.
    public let url: Foundation.URL
    
    public var poster: Data?
    
    /// The buffering status of the asset.
    public var bufferStatus: L5AssetBufferStatus = .notStarted
    
    /// The download (caching) status of the asset.
    public var downloadStatus: L5AssetDownloadStatus = .notStarted
    
    /// The local URL where the video has been stored after it has been successfully downloaded.
    public var localUrl: Foundation.URL?
    
    /// The AVAsset representing the actual in-memory asset with its seconds and its metadata.
    public var media: AVAsset?
    internal var player: AVPlayer?
    internal var playerItem: AVPlayerItem? {
        get {
            if let item = _playerItem {
                return item
            }
            if let asset = media {
                return AVPlayerItem(asset: asset)
            }
            return nil
        }
        set {
            _playerItem = newValue
        }
    }
    
    private var _playerItem: AVPlayerItem?
    
    // MARK: - INITIALIZERS
    
    public init(url: Foundation.URL) {
        self.url = url
        self.media = AVAsset(url: url)
    }
    
}
