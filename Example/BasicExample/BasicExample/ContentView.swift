import SwiftUI
import Segment

struct ContentView: View {
    
    var body: some View {
        TabView {
            Tab ("Tab 1", systemImage: "house") {
                Tab1View()
            }
            Tab ("Tab 2", systemImage: "pencil") {
                Tab2View()
            }
        }
    }
}

#Preview {
    ContentView()
}
