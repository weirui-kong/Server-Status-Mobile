//
//  DisplayMode.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023-02-27.
//

import Foundation
import SwiftUI
enum DisplayMode{
    case arc
    case pipe
}
enum DefaultResponsiveMeterColor{
    case low, medium, high
    var color: Color {
        switch self {
        case .low:
            return Color.green.opacity(0.8)
        case .medium:
            return Color.orange.opacity(0.8)
        case .high:
            return Color.red.opacity(0.8)
        }
    }
}

let meterBaseColor: Color = Color.white.opacity(0.4)
let defaultMeterOverlapColor: [Color] = [Color.green.opacity(0.8), Color.orange.opacity(0.8), Color.red.opacity(0.8)]
let undefinedCaseColor = Color.black.opacity(0.8)

func castResponsiveMeterColor(percent: Double?) -> Color{
    if let p = percent{
        switch(Int(p * 100)){
        case 0..<50:
            return DefaultResponsiveMeterColor.low.color
        case 50..<80:
            return DefaultResponsiveMeterColor.medium.color
        case 80..<100:
            return DefaultResponsiveMeterColor.high.color
        default:
            return undefinedCaseColor
        }
    }else{
        return undefinedCaseColor
    }
    
}
