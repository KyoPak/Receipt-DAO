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
            return "월별 지출"
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
            return UIImage(systemName: "chart.line.uptrend.xyaxis.circle")?
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
            return UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")?
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
        outerNavigationController: UINavigationController,
        navigationController: UINavigationController?,
        storage: CoreDataStorage,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService
    ) -> Coordinator {
        switch self {
        case .main:
            return ExpenseViewCoordinator(
                outerNavigationController: outerNavigationController,
                navigationController: navigationController,
                storage: storage,
                userDefaultService: userDefaultService,
                dateManageService: dateManageService
            )
            
        case .analysis:
            return AnalysisViewCoordinator(
                outerNavigationController: outerNavigationController,
                navigationController: navigationController,
                storage: storage,
                userDefaultService: userDefaultService
            )
        
        case .bookmark:
            return BookMarkViewCoordinator(
                outerNavigationController: outerNavigationController,
                navigationController: navigationController,
                storage: storage,
                userDefaultService: userDefaultService
            )
            
        case .setting:
            return SettingViewCoordinator(
                outerNavigationController: outerNavigationController,
                navigationController: navigationController,
                storage: storage,
                userDefaultService: userDefaultService
            )
        }
    }
}
