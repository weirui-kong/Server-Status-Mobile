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
    let undefinedCaseColor = Color.black.opacity(0.9)
    @Binding var percentage: Double
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
                        .trim(from: minTrimOffset, to: minTrimOffset + calcOffsetFromPercentage() )
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
                            //.frame(width: reader.size.width * percentage != 0 ? reader.size.width * percentage : 20)
                                .frame(width: percentage == 0 ? 0 : max(reader.size.width * percentage, 20))
                            //.animation(customizedSpringAnimatation)
                            Spacer(minLength: 0)
                        }
                        Text(optionalValue ?? "")
                        //.shadow(color: .gray, radius: percentage > 0.3 ? 5 : 50, x: 2, y: 2)
                    }
                }
            }
        }
    }
    func calcOffsetFromPercentage() -> CGFloat{
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5, blendDuration: 0.5)){
            var res: CGFloat = 0
            res = (maxTrimOffset - minTrimOffset) * percentage
            return res >= 0 && res <= (maxTrimOffset - minTrimOffset) ? res : 0
        }
        
    }
    func vivifiedMeterColor() -> Color{
        if(percentage < 0.5){
            return defaultMeterOverlapColor[0]
        }else if(percentage < 0.8){
            return defaultMeterOverlapColor[1]
        }else if(percentage <= 1){
            return defaultMeterOverlapColor[2]
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
