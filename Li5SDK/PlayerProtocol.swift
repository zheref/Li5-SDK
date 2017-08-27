//
//  PlayerProtocol.swift
//  li5
//
//  Created by Sergio Daniel Lozano on 8/16/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

import Foundation
import AVFoundation

public enum PlayerOption : String {
    case QueuePlayer
    case DVPlaylistPlayer
    case PlaylistPlayer
    case MultiPlayer
}

public protocol PlayerProtocol : class {
    
    var currentPlayer: AVPlayer? { get }
    
    var currentIndex: Int { get }
    
    var automaticallyReplay: Bool { get set }
    
    func play()
    
    func pause()
    
    func goNext(startPlaying: Bool)
    
    func goPrevious(startPlaying: Bool)
    
    func goNext()
    
    func goPrevious()
    
    func goToZero()
    
    func append(asset: Asset)
    
    func settle()
    
    func loosen()
    
}
