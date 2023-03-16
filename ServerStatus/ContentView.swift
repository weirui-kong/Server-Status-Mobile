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
enum QueryFailTypes: String{
    case networkIssue = "Network Issue"
    case noAvaliableJSON = "No Avaliable JSON Provided"
    case noActiveSevers = "No Server is Running"
    case apiTypeNotSupported = "API Type Not Supported"
}
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
    @State var queryJSONFail: QueryFailTypes?
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
                            withAnimation(){
                                onSettings = true
                            }
                        }
                        Button("print status"){
                            print(serverList.list)
                            print(queryJSONFail)
                            //print(readAPIInfoFromUserDefault())
                        }
                        Text("default:\(UserDefaults.standard.string(forKey: "DefaultAPILink") ?? String("nil"))")
                    }
#endif
                    if queryJSONFail == nil{
                        ScrollView{
#if os(macOS)
                            serverListView_mac
#else
                            serverListView
                                .padding(10)
#endif
                        }
                    }else{
                        VStack{
                            Spacer()
                            switch(queryJSONFail){
                            case .networkIssue:
                                Text("Network Unreachable")
                            case .noAvaliableJSON:
                                Text("No JSON Avaliable")
                            case .apiTypeNotSupported:
                                Text("API Not Suported")
                            case .noActiveSevers:
                                Text("No Server is Running")
                            default:
                                Text("Unknown Error")
                            }
                            Spacer()
                        }.foregroundColor(.gray)
                    }
                }.blur(radius: onSettings ? 15 : 0)
                    .onAppear(perform: {startUpdating()})
                //settings layer
                if onSettings{
                    ServerSelection(onSet: $onSettings.animation())
                    //.transition(.move(edge: .top))
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
    func readAPIInfoFromUserDefault() -> (String?, APITypes?, String?){
            //print("Called @State var requestLink")
            let defaults = UserDefaults.standard
            if let defaultAPILink_Code = defaults.string(forKey: "DefaultAPILink"){
                let dict = loadServersStoredPlist()
                if let loaded_dict = dict{
                    for server in loaded_dict{
                        if (server as! Dictionary<String, String>)["CODE"] == defaultAPILink_Code{
                            //amendments needed
                            if let _ = (server as! Dictionary<String, String>)["TAG"]{
                                withAnimation(.easeInOut){
                                    queryJSONFail = nil
                                }
                                return (
                                    (server as! Dictionary<String, String>)["API"],
                                    APITypes(rawValue: (server as! Dictionary<String, String>)["TAG"]!),
                                    (server as! Dictionary<String, String>)["CODE"]
                                )
                            }else{
                                withAnimation(.easeInOut){
                                    queryJSONFail = .apiTypeNotSupported
                                }
                                return(nil, nil, nil)
                            }
                        }
                    }
                    //If no returns have been made, it means there is no api address that confroms the given code
                    withAnimation(.easeInOut){
                        queryJSONFail = .noAvaliableJSON
                    }
                }
            }
            return (nil, nil, nil)
    }
    func startUpdating(){
        if !autoRefresh{
            autoRefresh = true
            DispatchQueue.global().async {
                while (self.autoRefresh){
                    let apiInfo = readAPIInfoFromUserDefault()
                    if let rl = apiInfo.0{
                        AF.request(rl).response { (response) in
                            switch response.result{
                            case.success(let jsonData):
                                let jsonString = String(decoding: jsonData!, as: UTF8.self)
                                if (!self.isScrolling){
                                    serverList.updateList(jsonString: jsonString, apiType: apiInfo.1, queryFail: &queryJSONFail)
                                }
                                withAnimation(.easeInOut){
                                    queryJSONFail = nil
                                }
                                
                                break
                            case.failure(_):
                                withAnimation(.easeInOut){
                                    queryJSONFail = .networkIssue
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
