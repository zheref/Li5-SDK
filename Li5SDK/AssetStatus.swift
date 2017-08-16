//
//  AssetStatus.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

public enum L5AssetBufferStatus {
    
    case notStarted
    case buffering
    case buffered
    case discarded
    
}

public enum L5AssetDownloadStatus {
    
    case notStarted
    case downloading
    case downloaded
    
}
