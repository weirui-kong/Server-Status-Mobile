//
//  Extensions.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023/1/2.
//

import Foundation
import UIKit
extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    static var isWatch: Bool {
        UIDevice.current.userInterfaceIdiom == .mac
    }
}
