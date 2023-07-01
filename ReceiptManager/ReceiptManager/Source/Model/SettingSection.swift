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
                title: "화폐 단위 설정",
                items: [
                    SettingOption(title: "화폐 단위 변경")
                ]
            ),
            SettingSection(
                title: "고객 센터",
                items: [
                    SettingOption(title: "의견 보내기"),
                    SettingOption(title: "평점 매기기"),
                ]
            ),
            SettingSection(
                title: "데이터 관리",
                items: [
                    SettingOption(title: "모든 데이터 삭제하기")
                ]
            )
        ]
    }
}
