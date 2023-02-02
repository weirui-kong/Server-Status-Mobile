//
//  ServerStatusApp.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2022/11/18.
//

import SwiftUI

@main
struct ServerStatusApp:  App {

    @State var serversStoredDict: [String : AnyObject]?
    var body: some Scene {
        WindowGroup {
            ContentView(serversStoredDict: $serversStoredDict)
                .onAppear(perform: loadServersStoredPlist)
        }
    }
    func loadServersStoredPlist(){
        if let path = Bundle.main.path(forResource: "ServersStored", ofType: "plist") {
          if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
              self.serversStoredDict = dict
          }
        }
    }
    
}
