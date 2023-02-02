//
//  Extensions.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023/1/2.
//

import Foundation

//extension UIDevice {
//    static var isIPad: Bool {
//        UIDevice.current.userInterfaceIdiom == .pad
//    }
//    
//    static var isIPhone: Bool {
//        UIDevice.current.userInterfaceIdiom == .phone
//    }
//}

extension Dictionary {
    
    func toJsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: []) else {
            return nil
        }
        guard let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
    }
    
}
