//
//  DisplayHandleService.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/22/24.
//

import UIKit

// Notificate Extension For DisplayMode

extension Notification.Name {
    static let displayModeNotification = Notification.Name("displayModeNotification")
}

protocol DisplayHandleService {
    func applyDisplayMode(index: Int)
}

final class DefaultDisplayHandleService: DisplayHandleService {
    
    init() {
        setupDisplayChangeObserver()
    }
    
    private func setupDisplayChangeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(displayModeDidChange),
            name: .displayModeNotification,
            object: nil
        )
    }
    
    @objc private func displayModeDidChange(_ notification: Notification) {
        guard let index = notification.userInfo?[ConstantKey.displayModeKey] as? Int else { return }
        
        applyDisplayMode(index: index)
    }
    
    func applyDisplayMode(index: Int) {
        let style: UIUserInterfaceStyle = {
            switch DisplayMode(rawValue: index) {
            case .light:    return .light
            case .dark:     return .dark
            default:        return .unspecified
            }
        }()
        
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = style
        }
    }
}
