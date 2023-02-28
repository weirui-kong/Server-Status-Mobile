//
//  ServersStored.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023-02-03.
//

import Foundation
import SwiftUI
//var SERVER_STORED_DICT: [String : AnyObject]?

struct APIAddress: Codable{
    let code: String
    let type: String
    let API: String
}

func loadServersStoredPlist() -> NSArray?{
    if let path = Bundle.main.path(forResource: "ServersStored", ofType: "plist") {
        return NSArray(contentsOfFile: path)
    }
    return nil
}
