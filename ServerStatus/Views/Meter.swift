import SwiftUI
struct Meter: View {
    enum DisplayMode{
        case arc
        case line
    }
    let minTrimOffset = 0.6
    let maxTrimOffset = 0.9
    let meterMaxWidth: CGFloat = 80
    let meterBaseColor: Color = Color.white.opacity(0.4)
    let defaultMeterOverlapColor: [Color] = [Color.green.opacity(0.8), Color.orange.opacity(0.8), Color.red.opacity(0.8)]
    let undefinedCaseColor = Color.black.opacity(0.8)
    @Binding var percentage: Double?
    let lable: String
    let icon: String
    let displayMode: DisplayMode
    var optionalValue: String? = ""
    var body: some View {
        if displayMode == DisplayMode.arc{
            ZStack{
                //meter
                ZStack{
                    Circle()
                        .trim(from: minTrimOffset, to: maxTrimOffset)
                        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    //.foregroundColor(meterBaseColor)
                    Circle()
                        .trim(from: minTrimOffset, to: minTrimOffset + calcTrimFromPercentage() )
                        .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                        .foregroundColor(vivifiedMeterColor())
                    //.animation(customizedSpringAnimatation)
                    
                }.frame(maxWidth: meterMaxWidth)
                
                //label
                VStack{
                    Image(systemName: icon)
                        .frame(width: 28, height: 25, alignment: .center)
                        .offset(y:5)
                    Text(lable)
                }
                
                
            }
        }else if displayMode == DisplayMode.line{
            HStack{
                HStack{
                    Image(systemName: icon)
                    Text(lable)
                }.frame(width: 80, height: 30, alignment: .center)
                GeometryReader{reader in
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(meterBaseColor)
                        HStack{
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(vivifiedMeterColor())
                                .frame(width: calcWidthFromPercentage(width: reader.size.width))
                                
                            //p = 0, w = 0
                            //0 < p < 0.05, w = 20
                            //p >= 0.05 w = RW * p
                            Spacer(minLength: 0)
                        }
                        Text(optionalValue ?? "NaN")
                    }
                    //Text("\(calcWidthFromPercentage(width: reader.size.width, percentage: percentage)),\(percentage ?? -1),\(reader.size.width)")
                }
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
    func calcTrimFromPercentage() -> CGFloat{
        withAnimation(customizedSpringAnimatation){
            if let p = self.percentage{
                return p == 0 ? 0 : p < 0.05 ?  (maxTrimOffset - minTrimOffset) * 0.05 : (maxTrimOffset - minTrimOffset) * p
            }else{
                return maxTrimOffset - minTrimOffset
            }
           
        }
        
    }
    func vivifiedMeterColor() -> Color{
        if let p = percentage{
            if(p < 0.5){
                return defaultMeterOverlapColor[0]
            }else if(p < 0.8){
                return defaultMeterOverlapColor[1]
            }else if(p <= 1){
                return defaultMeterOverlapColor[2]
            }else{
                return undefinedCaseColor
            }
        }else{
            return undefinedCaseColor
        }
        
    }
}

//struct Meter_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        ContentView()
//    }
//}
