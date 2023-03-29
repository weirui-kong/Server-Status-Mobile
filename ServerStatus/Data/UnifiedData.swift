//
//  ServerDataStructure.swift
//  Server Status
//
//  Created by 孔维锐 on 2022/11/19.
//

import Foundation
import SwiftUI
/*
 * see https://onevcat.com/2020/11/codable-default/
 */
protocol DefaultValue {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}
extension UUID: DefaultValue{
    static let defaultValue:UUID = UUID()
}
@propertyWrapper
struct Default<T: DefaultValue> {
    var wrappedValue: T.Value
}
extension Default: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
    }
}
extension KeyedDecodingContainer {
    func decode<T>(
        _ type: Default<T>.Type,
        forKey key: Key
    ) throws -> Default<T> where T: DefaultValue {
        try decodeIfPresent(type, forKey: key) ?? Default(wrappedValue: T.defaultValue)
    }
}


struct UnifiedServerInfomation: Identifiable {
    let id: String
    let apiType: APIType
    var name: String
    var type: String
    var location: String
    /*
     Online/Offline status
     Supported: HAROKU
     */
    var isOnline = false
    /*
     Network status
     Supported: HAROKU
     */
    var ipv4StatusAvaliable = false
    var online4: Bool = false
    var ipv6StatusAvaliable = false
    var online6: Bool = false
    /*
     Uptime status
     Supported: HAROKU
     */
    var uptimeStatusAvaliable = false
    var uptime: String?
    var uptime_EN: String?
    /*
     Load status
     Supported: HAROKU
     */
    var loadStatusAvaliable = false
    var load: Double?
    /*
     Network recieve/transmit(per second) status
     Supported: HAROKU
     */
    var net_rx_txStatusAvaliable = false
    var network_rx: UInt64?
    var network_rx_text: String?
    var network_tx: UInt64?
    var network_tx_text: String?
    /*
     Network total in/out status status
     Supported: HAROKU
     */
    var net_inoutStatusAvaliable = false
    var network_in: UInt64?
    var network_out: UInt64?
    var network_inout_text: String?
    /*
     Cpu status(by 100%) status
     Supported: HAROKU
     */
    var cpuStatusAvaliable = false
    var cpu_p: Double?
    var cpu_text: String?
    
    /*
     Memory status
     Supported: HAROKU
     */
    var memStatusAvaliable = false
    var memory_p: Double?
    var memory_text: String?
    /*
     Swap status
     Supported: HAROKU
     */
    var swapStatusAvaliable = false
    var swap_p: Double?
    var swap_text: String?
    /*
     Drive status
     Supported: HAROKU
     */
    //change "hdd" to "drive" in the future
    var hddStatusAvaliable = false
    var hdd_p: Double?
    var hdd_text: String?
    /*
     Custom string status
     Supported:
     */
    var customStatusAvaliable = false
    var custom: String?
    /*
     Region status(to show flag)
     Supported: HAROKU
     */
    var region: String?
    // The following four keywords must be satisfied
    init(id: String, name: String, type: String, location: String, apiType : APIType) {
        self.id = id
        self.name = name
        self.type = type
        self.location = location
        self.apiType = apiType
    }
}

class UnifiedServerInfomationList: ObservableObject{
    @Published public var list: [String : UnifiedServerInfomation] = [:]
    func updateList(jsonString: String, apiType: APIType?, queryFail: inout QueryFailureType?){
        withAnimation(.easeInOut){
            switch(apiType){
            case .HOTARU:
                updateUnifiedServerInfomationList_HOTARU(jsonString: jsonString, list: &list)
            default:
                break
            }
            if list.isEmpty{
                queryFail = .noActiveSevers
            }
        }
    }
}



