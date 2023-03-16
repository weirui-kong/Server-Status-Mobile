//
//  ServerCard.swift
//  Server Status
//
//  Created by 孔维锐 on 2022/11/19.
//

import SwiftUI

struct ServerCard: View, Identifiable {
    var id = UUID()
    
    @State var detailedMode = false
    @State var arrowAngle: Double = 0
    @Binding var status: UnifiedServerInfomation
    //    var miniMode: Bool{
    //        return (!detailedMode) && UIDevice.isIPhone
    //    }
    var body: some View {
        ZStack{
            
                RoundedRectangle(cornerRadius: 20)
                .fill(status.isOnline ? Color.blue.opacity(0.65).gradient : Color.gray.gradient)
                    .shadow(color: .gray.opacity(0.7), radius: 5, x: 3, y: 3)
          
            //default layout
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
            
        }.frame(
            maxHeight: detailedMode ? nil : 210
        )
        
        .font(.system(size: 16, weight: .bold, design: .rounded))
        .padding(10)
    }
    
    var realTimeToggler: some View{
        Image(systemName: "projective")
            .rotationEffect(Angle(degrees: arrowAngle), anchor: .center)
            .background(Circle().foregroundColor(.gray.opacity(detailedMode ? 0.15 : 0)).frame(width: 25, height: 25, alignment: .center))
            .foregroundColor(.white).opacity(detailedMode ? 0.8 : 0.6)
            .onTapGesture {
                withAnimation(){
                    detailedMode.toggle()
                    if detailedMode{
                        arrowAngle += 180
                    }else{
                        arrowAngle -= 180
                    }
                }
            }
    }
    var miniModeInfo: some View{
        VStack{
            Text(Region[status.region ?? "UN"]!)
                .font(.system(size: 40))
        }
    }
    var basicInfo: some View{
        VStack{
            HStack{
                Text(Region[status.region ?? "UN"]!)
                    .font(.system(size: detailedMode ? 80 : 50))
                if(detailedMode){
                    Spacer()
                    VStack{
                        Text("\(status.name)")
                        Text("\(status.location)")
                    }.font(.system(size: 21, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.5)
                    Spacer()
                }else{
                    Text("\(status.name)")
                    Text("\(status.location)")
                }
            }
            
            VStack{
                if(detailedMode){
                    //Network Label
                    HStack{
                        Image(systemName: "arrow.left.and.right.square")
                        Text("IPv4:")
                        Text(status.online4 ? "ONLINE" : "OFFLINE")
                            .foregroundColor(status.online4 ? .white : .black.opacity(0.5))
                        Spacer()
                        Image(systemName: "shippingbox")
                        Text("VZ:")
                        Text(status.type)
                        
                    }
                    HStack{
                        
                        Image(systemName: "arrow.left.and.right.square")
                        Text("IPv6:")
                        Text(status.online6 ? "ONLINE" : "OFFLINE")
                            .foregroundColor(status.online6 ? .white : .black.opacity(0.5))
                        Spacer()
                        Image(systemName: "network")
                        Text("BW:")
                        Text(status.network_inout_text ?? "NaN")
                    }
                    Text("Up Time：\(status.uptime_EN!)")
                        .padding(1)
                    //Network capsule
                    ZStack{
                        HStack{
                            Image(systemName: "tray.and.arrow.down")
                            Text(status.network_rx_text ?? "0" + "/s")
                            Spacer()
                            
                            Text(status.network_tx_text ?? "0" + "/s")
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
            HStack{
                ArcMeter(percentage: $status.cpu_p, optionalOverlayText: $status.cpu_text, lable: "CPU", icon: "cpu")
                ArcMeter(percentage: $status.memory_p, optionalOverlayText: $status.memory_text, lable: "MEM", icon: "memorychip")
                ArcMeter(percentage: $status.swap_p, optionalOverlayText: $status.swap_text, lable: "SWAP", icon: "shuffle")
                ArcMeter(percentage: $status.hdd_p, optionalOverlayText: $status.hdd_text, lable: "DISK", icon: "opticaldiscdrive")
            }
        }
        
    }
    var pipeMeters: some View{
        VStack{
            PipeMeter(percentage: $status.cpu_p,
                      lable: "CPU",
                      icon: "cpu",
                      optionalOverlayText: $status.cpu_text)
            PipeMeter(percentage: $status.memory_p,
                      lable: "MEM",
                      icon: "memorychip",
                      optionalOverlayText: $status.memory_text )
            PipeMeter(percentage: $status.swap_p,
                      lable: "SWP",
                      icon: "shuffle",
                      optionalOverlayText: $status.swap_text)
            PipeMeter(percentage: $status.hdd_p,
                      lable: "DISK",
                      icon: "opticaldiscdrive",
                      optionalOverlayText: $status.hdd_text)
            
        }.foregroundColor(.white)
    }
    
}

//struct ServerCard_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(serversStoredDict: <#Binding<[String : AnyObject]?>#>)
//    }
//}
