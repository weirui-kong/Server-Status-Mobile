//
//  ServersStored.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023-02-03.
//

import Foundation
import SwiftUI
struct ServersStored: Codable{
    private enum CodingKeys: String, CodingKey {
        case APITypes, APIAddresses
        
    }
    var APITypes: [APIType]
    var APIAddresses: [APIAddress]
}
struct APIType: Codable{
    let name: String
    let defaultpath: String
}
struct APIAddress: Codable{
    let API: String
    let name: String
}
