import SwiftUI
struct ArcMeter: View {
    @Binding var percentage: Double?
    @Binding var optionalOverlayText: String?
    @State private var showingDetails: Bool = false
    let minTrimOffset = 0.6
    let maxTrimOffset = 0.9
    let meterMaxWidth: CGFloat = 80
    let lable: String
    let icon: String
    var body: some View {
        Button{
            showingDetails = true
        } label: {
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
        }.popover(isPresented: $showingDetails, arrowEdge: .trailing, content: {
            VStack{
                ZStack{
                    Circle()
                        .frame(width: 150)
                        .foregroundColor(.gray)
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                        .foregroundColor(.white)
                    
                }.padding(20)
                PipeMeter(percentage: $percentage, lable: lable, icon: icon, optionalOverlayText: $optionalOverlayText, showPipeOnly: showingDetails)
                    .frame(width: 200, height: 50)
            }
        })
        
            
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
    @State static var optionalOverlayText: String? = "200MB/500MB"
    static var previews: some View {
        ArcMeter(percentage: $p, optionalOverlayText: $optionalOverlayText, lable: "CPU", icon: "cpu")
    }
}
