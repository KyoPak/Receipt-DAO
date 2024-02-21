//
//  CustomTabItem.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/14.
//

import UIKit

enum CustomTabItem: String, CaseIterable {
    case main
    case analysis
    case bookmark
    case setting
}
 
extension CustomTabItem {
    var name: String {
        switch self {
        case .main:
            return ConstantText.list.localize()
        case .analysis:
            return ConstantText.analysisTitle.localize()
        case .bookmark:
            return ConstantText.bookMark.localize()
        case .setting:
            return ConstantText.setting.localize()
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .main:
            return UIImage(systemName: ConstantImage.listCircle)?
                .withTintColor(.label.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        case .analysis:
            return UIImage(systemName: ConstantImage.chartUp)?
                .withTintColor(.label.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
            
        case .bookmark:
            return UIImage(systemName: ConstantImage.bookMark)?
                .withTintColor(.label.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        case .setting:
            return UIImage(systemName: ConstantImage.gear)?
                .withTintColor(.label.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        }
    }
    
    var selectedIcon: UIImage? {
        switch self {
        case .main:
            return UIImage(systemName: ConstantImage.listCircleFill)?
                .withTintColor(.label, renderingMode: .alwaysOriginal)
            
        case .analysis:
            return UIImage(systemName: ConstantImage.chartUpFill)?
                .withTintColor(.label, renderingMode: .alwaysOriginal)
            
        case .bookmark:
            return UIImage(systemName: ConstantImage.bookMarkFill)?
                .withTintColor(.label, renderingMode: .alwaysOriginal)
        case .setting:
            return UIImage(systemName: ConstantImage.gearFill)?
                .withTintColor(.label, renderingMode: .alwaysOriginal)
        }
    }
    
    func initialCoordinator(
        mainNavigationController: UINavigationController?,
        subNavigationController: UINavigationController,
        expenseRepository: ExpenseRepository,
        userSettingRepository: UserSettingRepository,
        dateRepository: DateRepository
    ) -> Coordinator {
        switch self {
        case .main:
            return ExpenseViewCoordinator(
                mainNavigationController: mainNavigationController,
                subNavigationController: subNavigationController,
                expenseRepository: expenseRepository,
                userSettingRepository: userSettingRepository,
                dateRepository: dateRepository
            )
            
        case .analysis:
            return AnalysisViewCoordinator(
                mainNavigationController: mainNavigationController,
                subNavigationController: subNavigationController,
                expenseRepository: expenseRepository,
                userSettingRepository: userSettingRepository
            )
        
        case .bookmark:
            return BookMarkViewCoordinator(
                mainNavigationController: mainNavigationController,
                subNavigationController: subNavigationController,
                expenseRepository: expenseRepository,
                userSettingRepository: userSettingRepository
            )
            
        case .setting:
            return SettingViewCoordinator(
                mainNavigationController: mainNavigationController,
                subNavigationController: subNavigationController,
                userSettingRepository: userSettingRepository
            )
        }
    }
}
