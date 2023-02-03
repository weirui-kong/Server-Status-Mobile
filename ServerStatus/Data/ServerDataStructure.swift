//
//  ServerDataStructure.swift
//  Server Status
//
//  Created by 孔维锐 on 2022/11/19.
//

import Foundation
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
func byteToKB_MB_GB(byte: UInt64?) -> String{
    let B = byte ?? 0
    switch(B){
    case 0..<1024:
        return String(format: "%.1fB", B)
    case 1024..<1024*1024:
        return String(format: "%.1fKB", Double(B)/1024)
    case 1024*1024..<1024*1024*1024:
        return String(format: "%.1fMB", Double(B)/1024/1024)
    case 1024*1024*1024..<1024*1024*1024*1024:
        return String(format: "%.1fGB", Double(B)/1024/1024/1024)
    default:
        return "OVERFLOW"
        
    }
    
}
struct ServerStatus_Single: Identifiable {
    let id: String
    var name: String
    var type: String
    var host: String
    var location: String
    var online4: Bool
    var online6: Bool
    var uptime: String?
    var uptime_EN: String
    var load: Double?
    var network_rx: UInt64?
    var network_rx_text: String
    var network_tx: UInt64?
    var network_tx_text: String
    var network_in: UInt64?
    var network_out: UInt64?
    var cpu: UInt64?
    var cpu_p: Double? //converted from int to double
    var memory_total: UInt64?
    var memory_used: UInt64?
    var memory_p: Double?
    var memory_text: String
    var swap_total: UInt64?
    var swap_used: UInt64?
    var swap_p: Double?
    var swap_text: String
    var hdd_total: UInt64?
    var hdd_used: UInt64?
    var hdd_p: Double?
    let hdd_text: String
    var custom: String?
    var region: String
    init(server: RawServerStatus_Single){
        self.id = server.name + server.location
        self.name = server.name
        self.type = server.type
        self.host = server.host
        self.location = server.location
        self.online4 = server.online4
        self.online6 = server.online6
        self.uptime = server.uptime
        if let ut = uptime{
            //self.uptime_EN = ut.replacing("天", with: "days")
            self.uptime_EN = ut.replacingOccurrences(of: "天", with: "days")
        }else{
            self.uptime = server.uptime
            self.uptime_EN = "OFFLINE"
        }
        
        self.load = server.load
        self.network_rx = server.network_rx
        self.network_rx_text = byteToKB_MB_GB(byte: network_rx)
        self.network_tx = server.network_tx
        self.network_tx_text = byteToKB_MB_GB(byte: network_tx)
        self.network_in = server.network_in
        self.network_out = server.network_out
        //cpu
        self.cpu = server.cpu
        if let c = cpu{
            self.cpu_p = Double(c) / 100.0
        }
        //memory
        self.memory_total = server.memory_total
        self.memory_used = server.memory_used
        if let mu = memory_used, let mt = memory_total{
            let p = Double(mu) / Double(mt)
            if !p.isNaN{
                self.memory_p = p
            }
        }
        self.memory_text = "\(byteToKB_MB_GB(byte: (server.memory_used ?? 0) * 1024 ))/\(byteToKB_MB_GB(byte: (server.memory_total ?? 0) * 1024))"
        //swap
        self.swap_total = server.swap_total
        self.swap_used = server.swap_used
        if let su = swap_used, let st = swap_total{
            let p = Double(su) / Double(st)
            if !p.isNaN{
                self.swap_p = p
            }
        }
        self.swap_text = "\(byteToKB_MB_GB(byte: (server.swap_used ?? 0) * 1024))/\(byteToKB_MB_GB(byte: (server.swap_total ?? 0) * 1024))"
        //hdd
        self.hdd_total = server.hdd_total
        self.hdd_used = server.hdd_used
        self.hdd_text = "\(byteToKB_MB_GB(byte: (server.hdd_used ?? 0) * 1024 * 1024))/\(byteToKB_MB_GB(byte: (server.hdd_total ?? 0) * 1024 * 1024))"
        if let hu = hdd_used, let ht = hdd_total{
            let p = Double(hu) / Double(ht)
            if !p.isNaN{
                self.hdd_p = p
            }
        }
       
        self.custom = server.custom
        self.region = server.region
    }
    
}

func toServerItems(servers: [RawServerStatus_Single]) -> [ServerStatus_Single]{
    var serverItems:[ServerStatus_Single] = []
    for server in servers{
        serverItems.append(ServerStatus_Single(server: server))
    }
    return serverItems
}

struct RawServerStatus_Single: Codable {
    let name: String
    let type: String
    let host: String
    let location: String
    let online4: Bool
    let online6: Bool
    let uptime: String?
    let load: Double?
    let network_rx: UInt64?
    let network_tx: UInt64?
    let network_in: UInt64?
    let network_out: UInt64?
    let cpu: UInt64?
    let memory_total: UInt64?
    let memory_used: UInt64?
    let swap_total: UInt64?
    let swap_used: UInt64?
    let hdd_total: UInt64?
    let hdd_used: UInt64?
    let custom: String?
    let region: String
}

struct RawServerResponse: Codable{
    let servers: [RawServerStatus_Single]
    let updated: String
}




