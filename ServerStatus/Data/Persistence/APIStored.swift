//
//  ServersStored.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023-02-03.
//

import Foundation
import SwiftUI

enum APIType: String, Codable{
    case HAROKU = "HAROKU"
    case undefined = "UNDEFINED"
}

struct API: Codable, Identifiable{
    var id = UUID()
    
    let code: String
    let type: APIType
    let api: String
}

func loadServersStoredPlist() -> [API]{
    var apis = [API]()
    if let path = Bundle.main.path(forResource: "ServersStored", ofType: "plist") {
        let content = NSArray(contentsOfFile: path) as! [Dictionary<String, String>]
        for api in content{
            apis.append(API(code: api["CODE"]!, type: APIType(rawValue: api["TYPE"]!) ?? APIType.undefined, api: api["API"]!))
        }
    }
    return apis
}
func loadSupportedAPIPlist() -> [String]{
    if let path = Bundle.main.path(forResource: "SupportedAPI", ofType: "plist") {
        return NSArray(contentsOfFile: path) as! [String]
    }
    return [String]()
}
