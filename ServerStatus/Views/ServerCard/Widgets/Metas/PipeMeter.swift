//
//  PipeMeter.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023-02-27.
//

import SwiftUI

struct PipeMeter: View {
    @Binding var percentage: Double?
    let lable: String
    let icon: String
    @Binding var optionalOverlayText: String?
    @State var showPipeOnly: Bool = false
    var body: some View {
        HStack{
            if !showPipeOnly{
                HStack{
                    Image(systemName: icon)
                    Text(lable)
                }.frame(width: 80, height: 30, alignment: .center)
            }
            
            GeometryReader{reader in
                ZStack{
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(meterBaseColor)
                    HStack{
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(castResponsiveMeterColor(percent: percentage))
                            .frame(width: calcWidthFromPercentage(width: reader.size.width))
                        
                        //p = 0, w = 0
                        //0 < p < 0.05, w = 20
                        //p >= 0.05 w = RW * p
                        Spacer(minLength: 0)
                    }
                    Text(optionalOverlayText ?? "NaN")
                }
                //Text("\(calcWidthFromPercentage(width: reader.size.width, percentage: percentage)),\(percentage ?? -1),\(reader.size.width)")
            }
        }
    }
    func calcWidthFromPercentage(width: CGFloat) -> CGFloat{
        withAnimation(customizedSpringAnimatation){
            if let p = self.percentage{
                return p == 0 ? 0 : p <= 0.05 ? 20 : p * width
            }else{
                return width
            }
        }
    }
}

struct PipeMeter_Previews: PreviewProvider {
    @State static var p: Double? = 0.3
    @State static var ot: String?  = "NaN"
    static var previews: some View {
        PipeMeter(percentage: $p, lable: "CPU", icon: "cpu", optionalOverlayText: $ot)
    }
}
