//
//  ContentView.swift
//  Server Status
//
//  Created by 孔维锐 on 2022/11/19.
//

import SwiftUI
import Alamofire
import IsScrolling
let customizedSpringAnimatation: Animation = Animation.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5)
struct ContentView: View {
    //@Binding var serversStoredDict: [String : AnyObject]?
    @State private var serverItems: [ServerStatus_Single] = []
    @State private var autoRefresh = false
    //@State private var requestLink = "https://server.onespirit.fyi/json/stats.json"
    @State private var isScrolling = false
    @State var requestLink: String? = {
        print("Called @State var requestLink")
        let defaults = UserDefaults.standard
        if let defaultAPILink_Code = defaults.string(forKey: "DefaultAPILink"){
            let dict = loadServersStoredPlist()
            if let loaded_dict = dict{
                for server in loaded_dict{
                    if (server as! Dictionary<String, String>)["CODE"] == defaultAPILink_Code{
                        return (server as! Dictionary<String, String>)["API"]!
                    }
                }
            }
        }
        return nil
    }()
    @State var onSettings = false
    var body: some View {
        ZStack{
            //main layer
            VStack{
#if DEBUG
                HStack{
                    Button("set osp"){
                        let defaults = UserDefaults.standard
                        defaults.set("OSP", forKey: "DefaultAPILink")
                    }
                    Button("clear osp"){
                        let defaults = UserDefaults.standard
                        defaults.removeObject(forKey: "DefaultAPILink")
                    }
                    Button("server selection"){
                        withAnimation(customizedSpringAnimatation){
                            onSettings = true
                        }
                    }
                }
                
#endif
                if let _ = requestLink{
                    ScrollView{
                        
#if os(macOS)
                        serverListView_mac
#else
                        serverListView
                            .padding(10)
#endif
                        
                    }.onAppear(perform: {startUpdating()})
                }else{
                    VStack{
                        Spacer()
                        Text("没有可用服务器\n或读取数据失败")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }.blur(radius: onSettings ? 15 : 0)
            
            //settings layer
            if onSettings{
                ServerSelection(requestLink: $requestLink, onSet: $onSettings)
                    .transition(.move(edge: .top))
            }
            
        }
        
    }
    var serverListView_mac: some View{
        VStack{
            LazyVGrid(columns: [GridItem(.adaptive(
                minimum: 360 * 1, maximum: 450 * 1
            ))], alignment: .center, spacing: 10 * 1){
                ForEach($serverItems, id: \.self.id) { item in
                    ServerCard(server: item)
                        .scrollSensor()
                }
            }.scrollStatusMonitor($isScrolling, monitorMode: .common)
                .scaleEffect(0.9)
        }
    }
    var serverListView: some View{
        LazyVGrid(columns: [GridItem(.adaptive(
            minimum: 360, maximum: 400
        ))], alignment: .center, spacing: 10){
            ForEach($serverItems, id: \.self.id) { item in
                ServerCard(server: item)
                    .scrollSensor()
                
            }
            
        }.scrollStatusMonitor($isScrolling, monitorMode: .common)
    }
    func startUpdating(){
        if !autoRefresh{
            autoRefresh = true
            DispatchQueue.global().async {
                while (self.autoRefresh){
                    if let rl = requestLink{
                        AF.request(rl).response { (response) in
                            switch response.result{
                            case.success(let jsonData):
                                let jsonString = String(decoding: jsonData!, as: UTF8.self)
                                let serversResponse = try! JSONDecoder().decode(RawServerResponse.self, from: jsonString.data(using: .utf8)!)
                                if (!self.isScrolling){
                                    withAnimation(customizedSpringAnimatation){
                                        serverItems = toServerItems(servers: serversResponse.servers)
                                    }
                                }
                                break
                            case.failure(_):
                                break
                            }
                        }
                    }
                    sleep(2)
                }
                
            }
        }
    }
    
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
