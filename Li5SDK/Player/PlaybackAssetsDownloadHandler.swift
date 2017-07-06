//
//  PlaybackAssetsDownloadHandler.swift
//  li5
//
//  Created by Sergio Daniel on 7/5/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import AVFoundation

protocol DownloadHandlerDelegate {
    
    func didFinishDownloadingAsset(withId id: String, intoLocation location: Foundation.URL)
    
}

class PlaybackAssetsDownloadHandler : NSObject {
    
    var id: String
    fileprivate var delegate: DownloadHandlerDelegate
    
    init(id: String, delegate: DownloadHandlerDelegate) {
        self.id = id
        self.delegate = delegate
    }
    
}


extension PlaybackAssetsDownloadHandler : AVAssetDownloadDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            log.error(error.localizedDescription)
        } else {
            log.warning("Finished??")
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        log.debug("\(loadedTimeRanges.count) time ranges loaded for id: \(id)")
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: Foundation.URL) {
        delegate.didFinishDownloadingAsset(withId: id, intoLocation: location)
    }
    
}
