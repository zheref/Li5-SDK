//
//  PlaybackDelegate.swift
//  li5
//
//  Created by Sergio Daniel on 7/3/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

protocol PlaybackDelegate : class {
    
    func bufferIsReadyToPlay()
    
    func handleError(with message: String?, error: Error?)
    
    func isPlaying()
    
}
