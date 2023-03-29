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
enum QueryFailureType: String{
    case networkUnreachable = "Network Unreachable"
    case apiUnreacheable = "API Unreachable"
    case noAvaliableAPI = "No Avaliable API Provided"
    case noActiveSevers = "No Server is Running"
    case apiTypeNotSupported = "API Type Not Supported"
    case apiNotSelected = "No API Selected"
    case apiNotFound = "API Not Found"
    
}
enum QueryProcessType: String{
    case collectingData = "Collecting data from your server..."
}
struct ContentView: View {
    //@Binding var serversStoredDict: [String : AnyObject]?
    @StateObject var serverList = UnifiedServerInfomationList()
    @State var autoRefresh: Bool = true
    //@State private var requestLink = "https://server.onespirit.fyi/json/stats.json"
    @State var isScrolling: Bool = false
    //splash app icon
    @State var showSplashAppIcon: Bool = true
    @State var appIconOpacity: Double = 1.0
    @State var appIconScale: Double = 0.7
    @State var queryFailure: QueryFailureType?
    @State var onSettings = false {
        willSet{
            autoRefresh = false
        }
        didSet{
            reloadAPIs()
            startUpdating()
            
        }
    }
    @State var currentAPI: API?
    var body: some View {
        ZStack{
            //main layer and splash layer must be written in the same level of branch
            if !showSplashAppIcon{
                //main layer
                VStack{
#if DEBUG
                    mainViewDebugButtons
#endif
                    if queryFailure == nil{
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
                            Text(queryFailure?.rawValue ?? "Unknown Error")
                            Spacer()
                        }.foregroundColor(.gray)
                    }
                }.blur(radius: onSettings ? 15 : 0)
                //settings layer
                if onSettings{
                    ServerSelection(onSet: $onSettings.animation())
                        .onDisappear(){reloadAPIs()}
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
        }.onAppear(perform: {
            reloadAPIs()
            startUpdating()
        })
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
    func readDefaultAPI() -> (QueryFailureType?, API?){
        //print("Called @State var requestLink")
        let defaultAPICode = UserDefaults.standard.string(forKey: "DefaultAPI")
        let apisStored: [API] = loadServersStoredPlist()
        //check if defaultAPICode is set
        if defaultAPICode == nil{
            return (QueryFailureType.apiNotSelected, nil)
        }
        //check if serverStored is empty
        if apisStored.isEmpty{
            return (QueryFailureType.noAvaliableAPI, nil)
        }
        //check if defaultAPI(CODE) exists in serverStored
        if let api = apisStored.first(where: {$0.code == defaultAPICode}){
            //check if defaultAPI(TYPE) exists in SupportedAPI.plist
            if api.type != .undefined{
                //the defaultAPI(CODE) exists inSupportedAPI.plist
                //and the corresponding defaultAPI(TYPE) also exists in SupportedAPI.plist
                return (nil, api);
            }else{
                return (QueryFailureType.apiTypeNotSupported, nil);
            }
        }else{
            //the defaultAPICode does not exist in apisStored
            return (QueryFailureType.apiNotFound, nil);
        }
    }
    func reloadAPIs(){
        let defaultAPI = readDefaultAPI()
        print(defaultAPI)
        if let api = defaultAPI.1{
            //valid
            currentAPI = api
        }else{
            //ivalid
            queryFailure = defaultAPI.0
            autoRefresh = false
        }
    }
    func startUpdating(){
        //withAnimation(.easeInOut){
            DispatchQueue.global().async {
                autoRefresh = true
                while (self.autoRefresh){
                    print("Getting...")
                    if let api: API = currentAPI{
                        AF.request(api.api)
                        {$0.timeoutInterval = 5}
                            .response { (response) in
                                switch response.result{
                                case.success(let jsonData):
                                    //check if status code is 200
                                    if response.response?.statusCode == 200{
                                        let jsonString = String(decoding: jsonData!, as: UTF8.self)
                                        if (!self.isScrolling){
                                            serverList.updateList(jsonString: jsonString, apiType: api.type, queryFail: &queryFailure)
                                            queryFailure = nil
                                        }
                                    }else{
                                        //errors like 404
                                        queryFailure = .apiUnreacheable
                                    }
                                case.failure(_):
                                    //network failure
                                    queryFailure = .networkUnreachable
                                }
                            }
                    }else{
                        //currentAPI is nil
                        queryFailure = .apiNotSelected
                    }
                    sleep(2)
                }
            }
        //}
    }
#if DEBUG
    var mainViewDebugButtons: some View{
        HStack{
            Button("set osp"){
                let defaults = UserDefaults.standard
                defaults.set("OSP", forKey: "DefaultAPI")
                reloadAPIs()
            }
            Button("clear osp"){
                let defaults = UserDefaults.standard
                defaults.removeObject(forKey: "DefaultAPI")
                reloadAPIs()
                startUpdating()
            }
            Button("server selection"){
                withAnimation(){
                    onSettings = true
                }
            }
            Button("print status"){
                print(serverList.list)
                print(queryFailure?.rawValue ?? "")
                //print(readAPIInfoFromUserDefault())
            }
            Button("reloadAPI"){
                reloadAPIs()
                startUpdating()
            }
            Text("default:\(UserDefaults.standard.string(forKey: "DefaultAPI") ?? String("nil"))")
        }
    }
#endif
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
