//
//  ServerSelection.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023-02-09.
//

import SwiftUI

struct ServerSelection: View {
    init(onSet: Binding<Bool>){
        //self._requestLink = requestLink
        self._onSettings = onSet
        self.apis = loadServersStoredPlist()
    }
    //@Binding var requestLink: (String?, APITypes?, String?)
    @Binding var onSettings: Bool
    @State var apis: [API]
    //selecttion function needed
    var body: some View {
        ZStack{
            //blur bg
            Rectangle()
                .foregroundColor(.gray.opacity(0.1))
                .ignoresSafeArea()
                .onTapGesture {
                    onSettings = false
                }
                //.transition(.opacity)
            //list layer
            List(){
                ForEach(apis) { api in
                    VStack(alignment: .leading){
                        Section(header: Text("\(api.code) - \(api.type.rawValue)").font(.title3)){
                            ScrollView(.horizontal){
                                Text(api.api)
                            }
                        }
                    }.onTapGesture {
                        withAnimation(){
                            UserDefaults.standard.set(api.code, forKey: "DefaultAPI")
                            onSettings.toggle()
                        }
                    }
                }
            }.scrollContentBackground(.hidden)
                .frame(maxWidth: 800)//in case unexpected width on ipad
                .shadow(radius: 2)
                //.transition(.slide)
                
#if DEBUG
            HStack{
                Button("print"){
                    print(apis)
                }
                Button("close"){
                    withAnimation(){
                        onSettings = false
                    }
                }
            } 
#endif
        }
        
    }
}

//struct ServerSelection_Previews: PreviewProvider {
//    @State static var requestLink:String? = "https://server.onespirit.fyi/json/stats.json"
//    @State static var onSet:Bool = true
//    static var previews: some View {
//        ServerSelection(requestLink: $requestLink, onSet: $onSet)
//    }
//}
