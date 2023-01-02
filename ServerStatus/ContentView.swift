//
//  ContentView.swift
//  Server Status
//
//  Created by 孔维锐 on 2022/11/19.
//

import SwiftUI
import Alamofire
struct ContentView: View {
    @State var serverItems: [ServerItem] = []
    @State var autoRefresh = false
    @State var domain = "server.onespirit.fyi"
    var justPopIn = true
    var body: some View {
        ScrollView{
            VStack {
                serverListView
                    .padding(10)
            }
        }
        
    }
    var serverListView: some View{
        VStack{
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 340, maximum: 450))], alignment: .center, spacing: 10){
                ForEach($serverItems, id: \.self.id) { item in
                    ServerCard(server: item)
                }
            }.onAppear(perform: {
                startUpdating()
           })
        }
        
        
    }
    func startUpdating(){
        if !autoRefresh{
            autoRefresh = true
            DispatchQueue.global().async {
                while (self.autoRefresh){
                    
                    let requestURL = "https://" + self.domain + "/json/stats.json"
                    AF.request(requestURL).response { (response) in
                        switch response.result{
                        case.success(let jsonData):
                            let jsonString = String(decoding: jsonData!, as: UTF8.self)
                            let serversResponse = try! JSONDecoder().decode(ServerResponse.self, from: jsonString.data(using: .utf8)!)
                            serverItems = toServerItems(servers: serversResponse.servers)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
