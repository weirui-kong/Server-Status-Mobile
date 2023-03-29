//
//  File.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023-02-27.
//

import Foundation
import SwiftUI
class RawServerResponse_HOTARU: Codable {
    let name: String
    let type: String
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
    let region: String?
    //    var id: String = {
    //        return name + location
    //    }
    func toUnifiedServerInfomation() -> UnifiedServerInfomation{
        var unified = UnifiedServerInfomation(
            id: self.name + self.location,
            name: self.name,
            type: self.type,
            location: self.location,
            apiType: .HOTARU
        )
        unified.location = self.location
        //online
        unified.isOnline = self.online4 || self.online6
        //network status
        unified.online4 = self.online4
        unified.ipv4StatusAvaliable = online4
        unified.online6 = self.online6
        unified.ipv6StatusAvaliable = online6
        //uptime status
        unified.uptime = self.uptime
        if let ut = uptime{
            //self.uptime_EN = ut.replacing("天", with: "days")
            unified.uptime_EN = ut.replacingOccurrences(of: "天", with: "days")
        }else{
            unified.uptime = self.uptime
            unified.uptime_EN = "OFFLINE"
        }
        unified.uptimeStatusAvaliable = uptime == nil
        //load status
        unified.load = self.load
        unified.loadStatusAvaliable = load == nil
        //network recieve/transmit(per second) status
        unified.network_rx = self.network_rx
        unified.network_rx_text = byteToKB_MB_GB(byte: network_rx)
        unified.network_tx = self.network_tx
        unified.network_tx_text = byteToKB_MB_GB(byte: network_tx)
        unified.net_rx_txStatusAvaliable = network_rx != nil && network_tx != nil
        //network total in/out status
        unified.network_in = self.network_in
        unified.network_out = self.network_out
        unified.network_inout_text = "\(byteToKB_MB_GB(byte: UInt64(self.network_in ?? UInt64()) + UInt64(self.network_out ?? UInt64(0))))"
        unified.net_inoutStatusAvaliable = network_in != nil && network_out != nil
        //cpu
        if let c = cpu{
            unified.cpu_p = Double(c) / 100.0
        }
        unified.cpu_text = "\(self.cpu ?? 0)%"
        unified.cpuStatusAvaliable = cpu != nil
        //memory
        if let mu = memory_used, let mt = memory_total{
            let p = Double(mu) / Double(mt)
            if !p.isNaN{
                unified.memory_p = p
            }
        }
        unified.memory_text = "\(byteToKB_MB_GB(byte: (self.memory_used ?? 0) * 1024 ))/\(byteToKB_MB_GB(byte: (self.memory_total ?? 0) * 1024))"
        unified.memStatusAvaliable = memory_used != nil && memory_total != nil
        //swap
        if let su = swap_used, let st = swap_total{
            let p = Double(su) / Double(st)
            if !p.isNaN{
                unified.swap_p = p
            }
        }
        unified.swap_text = "\(byteToKB_MB_GB(byte: (self.swap_used ?? 0) * 1024))/\(byteToKB_MB_GB(byte: (self.swap_total ?? 0) * 1024))"
        unified.swapStatusAvaliable = swap_used != nil && swap_total != nil
        //hdd
        unified.hdd_text = "\(byteToKB_MB_GB(byte: (self.hdd_used ?? 0) * 1024 * 1024))/\(byteToKB_MB_GB(byte: (self.hdd_total ?? 0) * 1024 * 1024))"
        if let hu = hdd_used, let ht = hdd_total{
            let p = Double(hu) / Double(ht)
            if !p.isNaN{
                unified.hdd_p = p
            }
        }
        unified.hddStatusAvaliable = hdd_used != nil && hdd_total != nil
        //region status(alpha-2)
        unified.region = self.region
        return unified
    }
    func byteToKB_MB_GB(byte: UInt64?) -> String{
        let B = byte ?? 0
        switch(B){
        case 0..<1024:
            return String(format: "%.1fB", B)
        case 1024..<1024*1024:
            return String(format: "%.1fKB", Double(B)/1024)
        case 1024*1024..<1024*1024*1024:
            return String(format: "%.1fMB", Double(B)/(1024*1024))
        case 1024*1024*1024..<1024*1024*1024*1024:
            return String(format: "%.1fGB", Double(B)/(1024*1024*1024))
        default:
            return "OVERFLOW"
        }
    }
}

struct RawServerResponses_HOTARU: Codable{
    let servers: [RawServerResponse_HOTARU]
    let updated: String
    
}

func updateUnifiedServerInfomationList_HOTARU(jsonString: String, list: inout [String : UnifiedServerInfomation]){
    //let serversResponses = try? JSONDecoder().decode(RawServerResponses_HAROKU.self, from: jsonString.data(using: .utf8) ?? Data())
    if let serversResponses = try? JSONDecoder().decode(RawServerResponses_HOTARU.self, from: jsonString.data(using: .utf8) ?? Data()){
        for server in serversResponses.servers{
            list[server.name + server.location] = server.toUnifiedServerInfomation()
            //id
            //If a server is deleted, server data in serverList(cache in memory) won't be deleted unless restart
        }
    }
}
