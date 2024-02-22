//
//  DisplayMode.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/21/24.
//

import Foundation

enum DisplayMode: Int, CaseIterable {
    case system
    case light
    case dark
}

extension DisplayMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .system:
            return ConstantText.systemMode.localize()
        case .light:
            return ConstantText.lightMode.localize()
        case .dark:
            return ConstantText.darkMode.localize()
        }
    }
}
