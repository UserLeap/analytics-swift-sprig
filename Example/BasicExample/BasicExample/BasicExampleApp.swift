//
//  BasicExampleApp.swift
//  BasicExample
//
//  Created by Brandon Sneed on 2/23/22.
//

import SwiftUI
import Segment

var analytics: Analytics? = nil

@main
struct BasicExampleApp: App {
    
    init() {
        setupSegment()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

private extension BasicExampleApp {
    func setupSegment() {
        let configuration = Configuration(writeKey: "EZqQCxT9TJd4GGdNwL5x9cKIBMBsLe3S")
            .flushInterval(10)

        analytics = Analytics.init(configuration: configuration)
        analytics?.add(plugin: SprigDestination())
    }
}
