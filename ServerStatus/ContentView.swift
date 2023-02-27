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
    @StateObject var serverList = UnifiedServerInfomationList()
    @State private var autoRefresh = false
    //@State private var requestLink = "https://server.onespirit.fyi/json/stats.json"
    @State private var isScrolling = false
    //splash app icon
    @State private var showSplashAppIcon = false
    @State private var appIconOpacity = 0.7
    @State private var appIconScale = 1.0
    @State private var queryJSONFail = false
    @State var requestLink: (String?, APITypes?, String?) = {
        //print("Called @State var requestLink")
        let defaults = UserDefaults.standard
        if let defaultAPILink_Code = defaults.string(forKey: "DefaultAPILink"){
            let dict = loadServersStoredPlist()
            if let loaded_dict = dict{
                for server in loaded_dict{
                    if (server as! Dictionary<String, String>)["CODE"] == defaultAPILink_Code{
                        //amendments needed
                        return (
                            (server as! Dictionary<String, String>)["API"]!,
                            APITypes(rawValue: (server as! Dictionary<String, String>)["TAG"]!),
                            (server as! Dictionary<String, String>)["CODE"]!
                        )
                    }
                }
            }
        }
        return (nil, nil, nil)
    }()
    @State var onSettings = false
    var body: some View {
        ZStack{
            //main layer and splash layer must be written in the same level of branch
            if !showSplashAppIcon{
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
                        Button("print status"){
                            print(serverList.list)
                        }
                    }
#endif
                    if !queryJSONFail{
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
                            Text("读取数据失败")
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
                
            }else{
                //splash icon
                VStack{
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 280)
                        .offset(y: 100 - 100 * appIconScale)
                    //orginal offset: 100 * 1.1^3 = 133
                        .scaleEffect(appIconScale)
                        .opacity(appIconOpacity)
                        .ignoresSafeArea()
                        .onAppear{
                            DispatchQueue.global().async {
                                for _ in 0..<3{
                                    sleep(1)
                                    withAnimation(customizedSpringAnimatation){
                                        appIconOpacity += 0.1
                                        appIconScale *= 1.1
                                    }
                                }
                                sleep(1)
                                withAnimation(){
                                    self.showSplashAppIcon = false
                                }
                            }
                        }
                }.background(Rectangle().frame(width: 10000,height: 10000).foregroundColor(.white))
                //frame should use infinity instead
                    .transition(.opacity)
            }
        }
    }
    var serverListView_mac: some View{
        VStack{
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 360 * 1, maximum: 450 * 1))], alignment: .center, spacing: 10 * 1){
                ForEach(Array($serverList.list.values)) { item in
                    ServerCard(status: item)
                        .scrollSensor()
                }
            }.scrollStatusMonitor($isScrolling, monitorMode: .common)
                .scaleEffect(0.9)
        }
    }
    var serverListView: some View{
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 360, maximum: 400))], alignment: .center, spacing: 10){
            ForEach(Array($serverList.list.values)) { item in
                ServerCard(status: item)
                    .scrollSensor()
            }
        }.scrollStatusMonitor($isScrolling, monitorMode: .common)
    }
    func startUpdating(){
        if !autoRefresh{
            autoRefresh = true
            DispatchQueue.global().async {
                while (self.autoRefresh){
                    if let rl = requestLink.0{
                        AF.request(rl).response { (response) in
                            switch response.result{
                            case.success(let jsonData):
                                let jsonString = String(decoding: jsonData!, as: UTF8.self)
                                if (!self.isScrolling){
                                    //withAnimation(customizedSpringAnimatation){
                                        serverList.updateList(jsonString: jsonString, apiType: requestLink.1)
                                        //print(jsonString)
                                    //}
                                }
                                withAnimation(){
                                    queryJSONFail = false
                                }
                                break
                            case.failure(_):
                                withAnimation(){
                                    queryJSONFail = true
                                }
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
