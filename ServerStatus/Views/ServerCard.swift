//
//  ServerCard.swift
//  Server Status
//
//  Created by 孔维锐 on 2022/11/19.
//

import SwiftUI

struct ServerCard: View {
    @State var detailedMode = false
    @State var arrowAngle: Double = 0
    @Binding var server: ServerItem
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .fill(server.online4 || server.online6
                      ? Color.blue.opacity(0.68).gradient : Color.gray.gradient)
                .shadow(color: .gray.opacity(0.7), radius: 5, x: 3, y: 3)
                //.animation(.spring((response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)))
            VStack{
                basicInfo
                Spacer()
                Spacer()
                if (detailedMode) {
                    pipeMeters
                }else{
                    arcMeters
                }
            }.padding(20)
            VStack{
                HStack{
                    Spacer()
                    realTimeToggler
                }
                Spacer()
            }.padding(10)
        }.frame(maxWidth: 400, maxHeight: detailedMode ? nil : 350)
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .padding(10)

    }
    var realTimeToggler: some View{
        Image(systemName: "projective")
            .rotationEffect(Angle(degrees: arrowAngle), anchor: .center)
            .background(Circle().foregroundColor(.gray.opacity(detailedMode ? 0.15 : 0)).frame(width: 25, height: 25, alignment: .center))
            .foregroundColor(.white).opacity(detailedMode ? 0.8 : 0.6)
            .onTapGesture {
                withAnimation(.spring()){
                    detailedMode.toggle()
                    if detailedMode{
                        arrowAngle += 180
                    }else{
                        arrowAngle -= 180
                    }
                }
            }
    }
    var basicInfo: some View{
        VStack{
            HStack{
                Text(Region[server.region] ?? "🇺🇳")
                    .font(.system(size: detailedMode ? 80 : 50))
                if(detailedMode){
                    Spacer()
                    VStack{
                        Text("\(server.name)")
                        Text("\(server.location)")
                    }.font(.system(size: 21, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.5)
                    Spacer()
                }else{
                    Text("\(server.name)")
                    Text("\(server.location)")
                }
            }
            
            VStack{
                if(detailedMode){
                    //Network Label
                    HStack{
                        Image(systemName: "arrow.left.and.right.square")
                        Text("IPv4:")
                        Text(server.online4 ? "ONLINE" : "OFFLINE")
                            .foregroundColor(server.online4 ? .white : .black.opacity(0.5))
                        Spacer()
                        Image(systemName: "shippingbox")
                        Text("VZ:")
                        Text(server.type)
                        
                    }
                    HStack{

                        Image(systemName: "arrow.left.and.right.square")
                        Text("IPv6:")
                        Text(server.online6 ? "ONLINE" : "OFFLINE")
                            .foregroundColor(server.online6 ? .white : .black.opacity(0.5))
                        Spacer()
                        Image(systemName: "network")
                        Text("BW:")
                        Text(byteToKB_MB_GB(byte: (server.network_in ?? 0) + (server.network_out ?? 0)))
                    }
                    Text("Up Time：\(server.uptime_EN )")
                        .padding(1)
                        .id("uptime")
                    //Network capsule
                    ZStack{
                        HStack{
                            Image(systemName: "tray.and.arrow.down")
                            Text(server.network_rx_text + "/s")
                            Spacer()
                            
                            Text(server.network_tx_text + "/s")
                            Image(systemName: "tray.and.arrow.up")
                        }
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }.background(Capsule().foregroundColor(.gray.opacity(0.6)).padding(-5))
                }
            }
        }.foregroundColor(.white)
        
    }
    var arcMeters: some View{
        VStack{
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60, maximum: 80))], alignment: .center, spacing: 20, content: {
                
                Meter(percentage: $server.cpu_p, lable: "CPU", icon: "cpu", displayMode: Meter.DisplayMode.arc)
                Meter(percentage: $server.memory_p, lable: "MEM", icon: "memorychip", displayMode: Meter.DisplayMode.arc)
                Meter(percentage: $server.swap_p, lable: "SWAP", icon: "shuffle", displayMode: Meter.DisplayMode.arc)
                Meter(percentage: $server.hdd_p, lable: "DISK", icon: "opticaldiscdrive", displayMode: Meter.DisplayMode.arc)
                
            }).padding(15)
        }.foregroundColor(.white)
       
    }
    var pipeMeters: some View{
        VStack{
            Meter(percentage: $server.cpu_p,
                  lable: "CPU",
                  icon: "cpu",
                  displayMode: Meter.DisplayMode.line,
                  optionalValue: "\(server.cpu ?? 0)%")
            Meter(percentage: $server.memory_p,
                  lable: "MEM",
                  icon: "memorychip",
                  displayMode: Meter.DisplayMode.line,
                  optionalValue: server.memory_text)
            Meter(percentage: $server.swap_p,
                  lable: "SWP",
                  icon: "shuffle",
                  displayMode: Meter.DisplayMode.line,
                  optionalValue: server.swap_text)
            Meter(percentage: $server.hdd_p,
                  lable: "DISK",
                  icon: "opticaldiscdrive",
                  displayMode: Meter.DisplayMode.line,
                  optionalValue: server.hdd_text)
            
        }.foregroundColor(.white)
    }
    
}

struct ServerCard_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
