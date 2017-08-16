//
//  PreloadingManagerProtocol.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

public enum PreloadingManagerOption : String {
    case CommonPreloadingManager
    case InstantPreloadingManager
}

public protocol PreloadingManagerProtocol : PreloaderDelegate {
    
    init(assets: [Asset],
         sameTimeBufferAmount: Int,
         minimumBufferedVideosToStartPlaying: Int,
         bufferer: BufferPreloaderProtocol?,
         downloader: DownloadPreloaderProtocol?)
    
    var currentAsset: Asset? { get }
    
    var delegate: PreloadingManagerDelegate? { get set }
    
    func setup(bufferer: BufferPreloaderProtocol?, downloader: DownloadPreloaderProtocol?)
    
    func startPreloading()
    
    func preload(index: Int)
    
}


public protocol PreloadingManagerDelegate {
    
    var playingIndex: Int { get }
    
    var player: PlayerProtocol! { get }
    
    func managerIsReadyForPlayback()
    
    func didPreload(_ asset: Asset)
}
