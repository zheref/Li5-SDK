//
//  PlaybackManager.swift
//  li5
//
//  Created by Sergio Daniel on 7/2/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

class PlaybackManager {
    
    // MARK: - CLASS MEMBERS
    
    static var shared: PlaybackManager = {
        return PlaybackManager()
    }()
    
    // MARK: - PROPERTIES
    
    var player: AVQueuePlayer? = AVQueuePlayer()
    
    // MARK: - INITIALIZERS
    
    private init() {
        
    }
    
    
}
