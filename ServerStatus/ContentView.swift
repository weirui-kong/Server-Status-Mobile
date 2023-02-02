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
    @State private var serverItems: [ServerStatus_Single] = []
    @State private var autoRefresh = false
    @State private var requestLink = "https://server.onespirit.fyi/json/stats.json"
    @State private var isScrolling = false
    @Binding var serversStoredDict: [String : AnyObject]?
    var justPopIn = true
    var body: some View {
        //Text(serversStoredDict?.toJsonString() ?? "")
        ScrollView{
#if os(macOS)
            serverListView
#else
            serverListView
                .padding(10)
#endif  
        }.onAppear(perform: {startUpdating()})
        
    }
    var serverListView: some View{
#if os(macOS)
        VStack{
            LazyVGrid(columns: [GridItem(.adaptive(
                minimum: 360 * 0.9, maximum: 450 * 0.9
            ))], alignment: .center, spacing: 10 * 0.9){
                ForEach($serverItems, id: \.self.id) { item in
                    ServerCard(server: item)
                        .scrollSensor()
                }
            }.scrollStatusMonitor($isScrolling, monitorMode: .common)
                .scaleEffect(0.9)
        }
#else
        VStack{
            LazyVGrid(columns: [GridItem(.adaptive(
                minimum: 360, maximum: 450
            ))], alignment: .center, spacing: 10){
                ForEach($serverItems, id: \.self.id) { item in
                    ServerCard(server: item)
                        .scrollSensor()
                }
            }.scrollStatusMonitor($isScrolling, monitorMode: .common)
        }
#endif
        
    }
    func startUpdating(){
        if !autoRefresh{
            autoRefresh = true
            DispatchQueue.global().async {
                while (self.autoRefresh){
                    
                    let requestURL = self.requestLink
                    AF.request(requestURL).response { (response) in
                        switch response.result{
                        case.success(let jsonData):
                            let jsonString = String(decoding: jsonData!, as: UTF8.self)
                            let serversResponse = try! JSONDecoder().decode(RawServerResponse.self, from: jsonString.data(using: .utf8)!)
                            if (!self.isScrolling){
                                withAnimation(customizedSpringAnimatation){
                                    serverItems = toServerItems(servers: serversResponse.servers)
                                }
                                
                            }
                            
                            //print(serversResponse)
                            break
                        case.failure(_):
                            break
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
