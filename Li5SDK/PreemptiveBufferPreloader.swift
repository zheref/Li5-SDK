//
//  PreemptiveBufferPreloader.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

public protocol L5PreloaderDelegate : class {
    
    func didPreload(asset: Asset, by amount: Double)
    
    func didFinishPreloading(asset: Asset)
    
    func didFailPreloading(asset: Asset, withError error: Error)
    
}


public protocol L5PreemptiveBufferPreloaderProtocol : L5BufferPreloaderProtocol {
    
    var delegate: L5PreloaderDelegate { get set }
    
    func preload(asset: L5Asset, completion: @escaping PreloadCompletion)
    
}


public class PreemptiveBufferPreloader : L5PreemptiveBufferPreloaderProtocol {
    
    // MARK: - CLASS PROPERTIES
    
    private static var propertiesToPreload = ["playable",
                                              "tracks",
                                              "duration",
                                              "hasProtectedContent"]
    
    // MARK: - STORED PROPERTIES
    
    public var delegate: L5PreloaderDelegate
    
    // MARK: - INITIALIZERS
    
    public init(delegate: L5PreloaderDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - EXPOSED OPERATIONS
    
    public func preload(asset: L5Asset, completion: @escaping PreloadCompletion) {
        asset.bufferStatus = .buffering
        
        asset.media?.loadValuesAsynchronously(forKeys: L5PreemptiveBufferPreloader.propertiesToPreload) {
            [weak self] in
            
            asset.bufferStatus = .buffered
            
            self?.delegate.didFinishPreloading(asset: asset)
            completion(asset, nil)
        }
    }
    
}
