//
//  SettingSection.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/07/01.
//

import Foundation
import RxDataSources

// MARK: - SettingSection
struct SettingSection {
    var title: String
    var items: [SettingOption]
}

extension SettingSection: SectionModelType {
    typealias Item = SettingOption
    
    init(original: SettingSection, items: [SettingOption]) {
        self = original
        self.items = items
    }
}

// MARK: - SettingOption
enum SettingType {
    case currency
    case payment
    case mail
    case appStore
}

struct SettingOption {
    let title: String
    let type: SettingType
}

extension SettingSection {
    static func configureSettings() -> [SettingSection] {
        return [
            SettingSection(
                title: ConstantText.customerPrivateSection.localize(),
                items: [
                    SettingOption(title: ConstantText.currencySettingText.localize(), type: .currency),
                    SettingOption(title: ConstantText.payTypeSettingText.localize(), type: .payment)
                ]
            ),
            SettingSection(
                title: ConstantText.customerServiceSection.localize(),
                items: [
                    SettingOption(title: ConstantText.opinion.localize(), type: .mail),
                    SettingOption(title: ConstantText.rating.localize(), type: .appStore)
                ]
            )
        ]
    }
}
