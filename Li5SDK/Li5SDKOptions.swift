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
}

struct Li5SDKOptions : Li5SDKOptionsProtocol {
    var appName: String?
    var contentCTACaption = "more"
}
