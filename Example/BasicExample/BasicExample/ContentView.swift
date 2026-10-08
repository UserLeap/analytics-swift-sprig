import SwiftUI
import Segment

struct ContentView: View {
    @State private var showSheet = false
    var body: some View {
        NavigationStack {
            VStack {
                Button("Track with Props") {
                    analytics!.track(name: "Track", properties: ["age": 3, "item": "cookies"])
                }
                .buttonStyle(.borderedProminent)
                
                Button("Track") {
                    analytics?.track(name: "Track")
                }
                .buttonStyle(.borderedProminent)
                
                Button("Screen with props") {
                    analytics?.screen(title: "iOS Segment Screen", properties: ["segmentActionsiOS": true, "deviceType": "iOS"])
                }
                .buttonStyle(.borderedProminent)
                
                Button("Screen") {
                    analytics?.screen(title: "iOS Segment Screen")
                }
                .buttonStyle(.borderedProminent)
                
                Button("Signed Out") {
                    analytics?.track(name: "Signed Out")
                }
                .buttonStyle(.borderedProminent)
                
                Button("Identify") {
                    analytics?.identify(userId: "X-1234567890", traits: ["abc": 1])
                }
                .buttonStyle(.borderedProminent)
                
                NavigationLink(destination: SecondView()) {
                    Text("Push Second View and track")
                }
                .buttonStyle(.borderedProminent)
                
                Button("Show sheet") {
                    showSheet = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            analytics?.track(name: "random")
        }
        .sheet(isPresented: $showSheet) {
            SheetView()
        }
    }
}

struct SecondView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Second View")
            }
        }.onAppear {
            analytics?.track(name: "Track")
        }
    }
}

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button("Track"){
            analytics?.track(name: "Track")
        }
        .buttonStyle(.borderedProminent)
        Button("Track and dismiss") {
            analytics?.track(name: "Track")
            dismiss()
        }
        .buttonStyle(.borderedProminent)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
