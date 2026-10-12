import SwiftUI

struct Tab2View: View {
    var body: some View {
        VStack {
            Button("Track") {
                analytics?.track(name: "Track")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    Tab2View()
}
