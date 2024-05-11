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
        var config: [String: Any]?
        if let infoPlistPath = Bundle.main.url(forResource: "Config", withExtension: "plist") {
            do {
                let infoPlistData = try Data(contentsOf: infoPlistPath)
                if let dict = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: nil) as? [String: Any] {
                    config = dict
                }
            } catch {
                print(error)
            }
        }
        let segmentKey: String = config?["SEGMENT_WRITE_KEY"] as! String
        let configuration = Configuration(writeKey: segmentKey)
            configuration.flushAt(3)

        analytics = Analytics.init(configuration: configuration)
        analytics?.add(plugin: SprigDestination())
    }
}
