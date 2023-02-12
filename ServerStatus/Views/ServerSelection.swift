//
//  ServerSelection.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023-02-09.
//

import SwiftUI
struct ServerItem: Identifiable{
    let api: String
    let code: String
    let tag: String
    var id: String
}

struct ServerSelection: View {
    init(requestLink: Binding<String?>, onSet: Binding<Bool>){
        self._requestLink = requestLink
        self._onSettings = onSet
        let dict = loadServersStoredPlist()
        var serverItems: [ServerItem] = []
        if let loaded_dict = dict{
            for server in loaded_dict{
                let sd = server as! Dictionary<String, String>
                serverItems.append(ServerItem(api: sd["API"]!, code: sd["CODE"]!, tag: sd["TAG"]!, id: sd["CODE"]!))
                
            }
        }
        self.serverItems = serverItems
    }
    @Binding var requestLink: String?
    @Binding var onSettings: Bool
    @State var serverItems: [ServerItem]
    
    var body: some View {
        ZStack{
            
            //list layer
            
            List(){
                ForEach(serverItems) { item in
                    VStack(alignment: .leading){
                        Section(header: Text(item.code).font(.title3)){
                            ScrollView(.horizontal){
                                Text(item.api)
                            }
                            
                        }
                        
                    }//.background(Color.white.opacity(0.5))
                }
            }.scrollContentBackground(.hidden)
                
            
            
#if DEBUG
            HStack{
                Button("print"){
                    print(serverItems)
                }
                Button("close"){
                    withAnimation(customizedSpringAnimatation){
                        onSettings = false
                    }
                }
            }
            
#endif
        }
        
    }
}

struct ServerSelection_Previews: PreviewProvider {
    @State static var requestLink:String? = "https://server.onespirit.fyi/json/stats.json"
    @State static var onSet:Bool = true
    static var previews: some View {
        ServerSelection(requestLink: $requestLink, onSet: $onSet)
    }
}
