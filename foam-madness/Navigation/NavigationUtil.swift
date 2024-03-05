//
//  NavigationUtil.swift
//  foam-madness
//
//  Created by Michael Virgo on 3/1/24.
//  Copyright © 2024 mvirgo. All rights reserved.
//

import SwiftUI
import UIKit

struct IdentifiableNavigationView<Content: View>: View {
    let tag: AnyHashable
    let content: Content
    
    var body: some View {
        content
            .navigationBarTitle("", displayMode: .inline)
            .tag(tag)
    }
}

// Based on: https://stackoverflow.com/a/67495147
struct NavigationUtil {
    static func popToRootView(animated: Bool = true) {
        findNavigationController(viewController: UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }?.rootViewController)?.popToRootViewController(animated: animated)
    }
    
    static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        
        if let navigationController = viewController as? UITabBarController {
            return findNavigationController(viewController: navigationController.selectedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }
        
        return nil
    }
    
    static func popToTournamentGames(tournamentName: String, animated: Bool = true) {
        guard let navigationController = findNavigationController(viewController: UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }?.rootViewController) else {
            return
        }

        for viewController in navigationController.viewControllers {
            if let title = viewController.navigationItem.title {
                if title == tournamentName {
                    navigationController.popToViewController(viewController, animated: animated)
                }
            }
        }
    }
}
