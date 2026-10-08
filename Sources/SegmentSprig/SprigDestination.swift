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
    private let kSignOutEvent = "Signed Out"
    
    public init() {}
        
    public func update(settings: Settings, type: UpdateType) {
        // Grab the settings from segment
        guard let sprigSettings: SprigSettings = settings.integrationSettings(forPlugin: self) else { return }
        guard sprigSettings.envId != "" else { return }

        var configuration: [String: Any] = [
            "x-ul-installation-method": "ios-segment",
            "x-ul-package-version": SprigDestination.version()
        ]

        Sprig.shared.configure(withEnvironment: sprigSettings.envId, configuration: configuration)
    }
    
    public func identify(event: IdentifyEvent) -> IdentifyEvent? {
        let attributes: [String: Any?] = event.traits?.dictionaryValue as? [String: Any?] ?? [:]
        Sprig.shared.setVisitorAttributes(getTopLevel(attributes: attributes), userId: event.userId, partnerAnonymousId: event.anonymousId)

        return event
    }
    
    public func track(event: TrackEvent) -> TrackEvent? {
        guard event.event != kSignOutEvent else {
            Sprig.shared.logout()
            return event
        }
        let properties: [String: Any?] = event.properties?.dictionaryValue as? [String: Any?] ?? [:]
        Sprig.shared.track(eventName: event.event,
                           userId: event.userId,
                           partnerAnonymousId: event.anonymousId,
                           properties: properties) { surveyState in
            print(surveyState.rawValue)
            guard surveyState == .ready else { return }
            SprigDestination.presentSurveyFromTopViewController()
        }
        return event
    }
    
    public func screen(event: ScreenEvent) -> ScreenEvent? {
        guard let eventName = event.name else {return event}
        let properties: [String: Any?] = event.properties?.dictionaryValue as? [String: Any?] ?? [:]
        Sprig.shared.track(eventName: eventName,
                           userId: event.userId,
                           partnerAnonymousId: event.anonymousId,
                           properties: properties) { surveyState in
            guard surveyState == .ready else { return }
            SprigDestination.presentSurveyFromTopViewController()
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
    
    /// Presents the survey from the top view controller.
    /// If the top view controller's presented view controller is being dismissed (e.g. a sheet animating away), waits for the
    /// dismissal to finish and looks up the top view controller again. Looking up again handles both a completed dismissal (present from
    /// the presenter) and a cancelled interactive dismissal (the sheet stays, so present from the sheet).
    private static func presentSurveyFromTopViewController() {
        guard let vc = UIApplication.shared.topViewController() else {
            Sprig.shared.dismissActiveSurvey()
            return
        }
        // Without a transition coordinator (e.g. a non-animated dismissal) fall through and present from the top view controller.
        if let dismissingVC = vc.presentedViewController,
           dismissingVC.isBeingDismissed,
           let transitionCoordinator = dismissingVC.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: nil) { _ in
                presentSurveyFromTopViewController()
            }
            return
        }
        Sprig.shared.presentSurvey(from: vc)
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
            // stop before a view controller that is being dismissed, as presenting on it would fail or be torn down with it
            if let presented = topViewController?.presentedViewController, !presented.isBeingDismissed {
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
