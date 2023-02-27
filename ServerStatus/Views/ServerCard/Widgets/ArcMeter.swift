import SwiftUI
struct ArcMeter: View {
    @Binding var percentage: Double?
    let minTrimOffset = 0.6
    let maxTrimOffset = 0.9
    let meterMaxWidth: CGFloat = 80
    let lable: String
    let icon: String
    var body: some View {
        ZStack{
            //meter
            ZStack{
                Circle()
                    .trim(from: minTrimOffset, to: maxTrimOffset)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .foregroundColor(meterBaseColor)
                Circle()
                    .trim(from: minTrimOffset, to: minTrimOffset + calcTrimFromPercentage() )
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    .foregroundColor(castResponsiveMeterColor(percent: percentage))
                
            }
            
            //label
            VStack{
                Image(systemName: icon)
                    .frame(width: 28, height: 25, alignment: .center)
                    .offset(y:5)
                Text(lable)
            }
        }.foregroundColor(.white)
            .frame(maxWidth: meterMaxWidth)
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
}

struct Meter_Previews: PreviewProvider {
    @State static var p: Double? = 0.3
    static var previews: some View {
        ArcMeter(percentage: $p, lable: "CPU", icon: "cpu")
    }
}
