//
//  SprigDestination.swift
//  SprigDestination
//
//  Created by Gong Chen on 7/18/2021.
//


import Foundation
import Segment
import UserLeapKit

/**
 An implementation of the Example Analytics device mode destination as a plugin.
 */

public class SprigDestination: DestinationPlugin {
    public let timeline = Timeline()
    public let type = PluginType.destination
    public let key = "Sprig (Actions)"
    public var analytics: Analytics? = nil
    
    private var sprigSettings: SprigSettings?
    private var isSprigConfigured: Bool = false
    
    public init() {}
        
    public func update(settings: Settings, type: UpdateType) {
        // Grab the settings from segment
        guard let sprigSettings: SprigSettings = settings.integrationSettings(forPlugin: self) else { return }
        guard sprigSettings.envId != "" else { return }
        Sprig.shared.configure(withEnvironment: sprigSettings.envId)
    }
    
    public func identify(event: IdentifyEvent) -> IdentifyEvent? {
        guard let userId = event.userId else { return event }
        guard let attributes = event.traits?.dictionaryValue as? [String: Any?] else {
            recordAnonymousId(from:event)
            Sprig.shared.setUserIdentifier(userId)
            return event
        }
        Sprig.shared.setVisitorAttributes(getTopLevel(attributes), userId, event.anonymousId)

        return event
    }
    
    public func track(event: TrackEvent) -> TrackEvent? {
        Sprig.shared.track(eventName: event.event,
                           userId: event.userId,
                           partnerAnonymousId: event.anonymousId) { surveyState in
            guard surveyState == .ready else { return }
            if let vc = UIApplication.shared.topViewController() {
                Sprig.shared.presentSurvey(from: vc)
            }
        }
        return event
    }
    
    // switch to a new user id
    public func alias(event: AliasEvent) -> AliasEvent? {
        guard let userId = event.userId else { return event }
        recordAnonymousId(from:event)
        Sprig.shared.setUserIdentifier(userId)
        return event
    }
    
    public func reset() {
        Sprig.shared.logout()
    }
    
    private func recordAnonymousId(from event: RawEvent) {
        if let anonymousId = event.anonymousId {
            Sprig.shared.setPartnerAnonymousId(anonymousId)
        }
    }
    
    private func getTopLevel(attributes: [String: Any?]) -> [String: String] {
        var stringAttributes:[String: String] = attributes.compactMapValues({ value in
            guard let value = value else { return nil }
            return String(describing: value)
        })
        if let email = stringAttributes["email"] {
            stringAttributes["!email"] = email
            stringAttributes.removeValue(forKey: "email")
        }
        return stringAttributes
    }
}

extension SprigDestination: VersionedPlugin {
    public static func version() -> String {
        return __destination_version
    }
}

extension UIApplication {
    // based on this implementation https://stackoverflow.com/a/66573132/3701208
    func topViewController() -> UIViewController? {
        var topViewController: UIViewController? = nil
        // find the root view controller
        if #available(iOS 13, *) {
            for scene in connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        if window.isKeyWindow {
                            topViewController = window.rootViewController
                        }
                    }
                }
            }
        } else {
            topViewController = keyWindow?.rootViewController
        }
        // traverse the root view controller's stack to find the top view controller
        var iteration = 0
        let ITERATION_MAX = 200
        while iteration != ITERATION_MAX {
            iteration += 1
            if let presented = topViewController?.presentedViewController {
                topViewController = presented
            } else if let navController = topViewController as? UINavigationController {
                topViewController = navController.topViewController
            } else if let tabBarController = topViewController as? UITabBarController {
                topViewController = tabBarController.selectedViewController
            } else {
                // we have a regular view controller
                break
            }
        }
        guard iteration != ITERATION_MAX else { return nil }
        return topViewController
    }
}
private struct SprigSettings: Codable {
    let envId: String
}
