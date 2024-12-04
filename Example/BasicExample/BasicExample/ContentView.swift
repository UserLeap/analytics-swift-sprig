//
//  ContentView.swift
//  BasicExample
//
//  Created by Brandon Sneed on 2/23/22.
//

import SwiftUI
import Segment

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        analytics!.track(name: "Track", properties: ["age": 3, "item": "cookies"])
                    }, label: {
                        Text("Track with Props")
                    }).padding(6)
                    Button(action: {
                        analytics?.track(name: "Track")
                    }, label: {
                        Text("Track")
                    }).padding(6)
                    Button(action: {
                        analytics?.screen(title: "iOS Segment Screen", properties: ["segmentActionsiOS": true, "deviceType": "iOS"])
                    }, label: {
                        Text("Screen with props")
                    }).padding(6)
                    Button(action: {
                        analytics?.screen(title: "iOS Segment Screen")
                    }, label: {
                        Text("Screen")
                    }).padding(6)
                    Button(action: {
                        analytics?.track(name: "Signed Out")
                    }, label: {
                        Text("Signed Out")
                    }).padding(6)
                }.padding(8)
                HStack {
                    Button(action: {
                        analytics?.identify(userId: "X-1234567890", traits: ["abc": 1])
                    }, label: {
                        Text("Identify")
                    }).padding(6)
                }.padding(8)
                HStack {
                    NavigationLink(destination: SecondView()) {
                        Text("Go To Second View")
                    }
                }
            }
        }.onAppear {
            analytics?.track(name: "random")
        }
    }
}

struct SecondView: View {
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Second View")
                }
            }
        }.onAppear {
            analytics?.track(name: "Track")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
