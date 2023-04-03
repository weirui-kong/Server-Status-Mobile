//
//  ActivityWidget.swift
//  ServerStatus
//
//  Created by 孔维锐 on 2023-04-03.
//

import SwiftUI
import WidgetKit
import ActivityKit


@available(iOS 16.2, *)
struct Widgets: WidgetBundle {
    var body: some Widget {
        ActivityWidget()
    }
}

@available(iOS 16.2, *)
struct ActivityWidget: Widget {
    var body: some WidgetConfiguration{
        ActivityConfiguration(for: ServerStatusActivityAttributes.self) {context in
            // For devices that don't support the Dynamic Island.
            Text("Test")
        } dynamicIsland: { context in
            DynamicIsland{
                DynamicIslandExpandedRegion(.leading) {
                    Text("test")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("test")
                }
                DynamicIslandExpandedRegion(.center) {
                    Text("test")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("test")
                }
            }compactLeading: {
                Text("test")
            }compactTrailing: {
                Text("test")
            }minimal: {
                Text("test")
            }.keylineTint(.accentColor)
        }
    }
}

// Preview available on iOS 16.2 or above
//@available(iOSApplicationExtension 16.2, *)
//struct ActivityWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityWidget()
//    }
//}
