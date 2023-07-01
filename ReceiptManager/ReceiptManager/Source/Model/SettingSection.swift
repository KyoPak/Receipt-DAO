//
//  SettingSection.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/07/01.
//

import Foundation
import RxDataSources

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

struct SettingOption {
    let title: String
}

extension SettingSection {
    static func configureSettings() -> [SettingSection] {
        return [
            SettingSection(
                title: ConstantText.currencySettingSection.localize(),
                items: [
                    SettingOption(title: ConstantText.currencySettingText.localize())
                ]
            ),
            SettingSection(
                title: ConstantText.customerServiceSection.localize(),
                items: [
                    SettingOption(title: ConstantText.opinion.localize()),
                    SettingOption(title: ConstantText.rating.localize())
                ]
            ),
            SettingSection(
                title: ConstantText.dataManageSection.localize(),
                items: [
                    SettingOption(title: ConstantText.dataClear.localize())
                ]
            )
        ]
    }
}
