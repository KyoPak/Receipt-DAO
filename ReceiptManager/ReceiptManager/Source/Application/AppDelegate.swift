//
//  AppDelegate.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import AppTrackingTransparency
import UIKit
import CoreData

import FirebaseAnalytics
import FirebaseCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.requestTrakingAuthorization()
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {
        
    }
}

// MARK: - Tracking Authroization
extension AppDelegate {
    private func requestTrakingAuthorization() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .notDetermined, .restricted, .denied:
                    Analytics.setAnalyticsCollectionEnabled(false)
                    
                case .authorized:
                    Analytics.setAnalyticsCollectionEnabled(true)
                    
                @unknown default:
                    Analytics.setAnalyticsCollectionEnabled(false)
                }
            }
        }
    }
}
