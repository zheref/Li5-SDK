//
//  BufferPreloaderProtocol.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

public typealias PreloadProgressClosure = (Asset, Double) -> Void
public typealias PreloadCompletion = (Asset, Error?) -> Void

/// Determines a contract of how to preload certain asset and trigger the corresponding events
/// on progress, error or completion
public protocol PreloaderProtocol {
    
    var delegate: PreloaderDelegate { get set }
    
    func preload(asset: Asset, completion: @escaping PreloadCompletion)
    
}

public enum BufferPreloaderOption : String {
    case PreemptiveBufferPreloader
    case BuffereXPreloader
}

/// Specialization of L5PreloaderProtocol focused on buffering purposes meaning preemptive loading
/// that doesn't persist.
public protocol BufferPreloaderProtocol : PreloaderProtocol {
    
}

public enum DownloadPreloaderOption : String {
    case None
    case AssetDownloadTaskPreloader
    case HLSionDownloadPreloader
    case PlayerDownloadPreloader
}

/// Specialization of L5PreloaderProtocol focused on downloading purposes meaning caching
/// that persis on storage even after the app has been killed.
public protocol DownloadPreloaderProtocol : PreloaderProtocol {
    
}

/// Delegate contract of class instance that should respond to the completion events
public protocol PreloaderDelegate : class {
    
    func didPreload(asset: Asset, by amount: Double)
    
    func didFinishPreloading(asset: Asset)
    
    func didFailPreloading(asset: Asset, withError error: Error)
    
}
