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
    case currency(description: String, options: [String])
    case payment(description: String, options: [String])
    case displayMode(description: String, options: [String])
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
                    SettingOption(
                        title: ConstantText.currencySettingText.localize(),
                        type: .currency(
                            description: ConstantText.currencySettingDescription.localize(),
                            options: Currency.allCases.map { $0.description }
                        )
                    ),
                    SettingOption(
                        title: ConstantText.payTypeSettingText.localize(),
                        type: .payment(
                            description: ConstantText.paymentTypeSettingDescription.localize(),
                            options: PayType.allCases.map { $0.description }
                        )
                    ),
                    SettingOption(
                        title: ConstantText.displayModeSettingText.localize(),
                        type: .displayMode(
                            description: ConstantText.displayModeSettingDescription.localize(),
                            options: DisplayMode.allCases.map { $0.description }
                        )
                    )
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
