//
//  ServerActivity.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023-04-03.
//

import Foundation
import ActivityKit
import SwiftUI
struct ServerStatusActivityAttributes: ActivityAttributes{
    public typealias ServerStatus = ContentState
    
    public struct ContentState: Codable, Hashable {
        var serverInfo: UnifiedServerInfomation
    }
}
