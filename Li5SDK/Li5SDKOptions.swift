//
//  Li5SDKConfiguration.swift
//  li5
//
//  Created by Sergio Daniel on 9/7/17.
//  Copyright © 2017 Li5, Inc. All rights reserved.
//

import Foundation

public protocol Li5SDKOptionsProtocol {
    var appName: String? { get set }
    var contentCTACaption: String { get set }
    
    var playbackProgressColor: UIColor { get set }
    var extendablePlaybackProgressColor: UIColor? { get set }
    
    var logoImage: UIImage? { get set }
    var eosText: String? { get set }
}

struct Li5SDKOptions : Li5SDKOptionsProtocol {
    var appName: String?
    var contentCTACaption = "more"
    
    var playbackProgressColor = UIColor.white
    var extendablePlaybackProgressColor: UIColor?
    
    var logoImage: UIImage?
    var eosText: String?
}
