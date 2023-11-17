//
//  CustomTabItem.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/14.
//

import UIKit

enum CustomTabItem: String, CaseIterable {
    case main
//    case bookmark
//    case setting
}
 
extension CustomTabItem {
    var name: String {
        switch self {
        case .main:
            return ConstantText.list.localize()
//        case .bookmark:
//            return ConstantText.bookMark.localize()
//        case .setting:
//            return ConstantText.setting.localize()
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .main:
            return UIImage(systemName: ConstantImage.listCircle)?
                .withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
//        case .bookmark:
//            return UIImage(systemName: ConstantImage.bookMark)?
//                .withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
//        case .setting:
//            return UIImage(systemName: ConstantImage.gear)?
//                .withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        }
    }
    
    var selectedIcon: UIImage? {
        switch self {
        case .main:
            return UIImage(systemName: ConstantImage.listCircleFill)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
//        case .bookmark:
//            return UIImage(systemName: ConstantImage.bookMarkFill)?
//                .withTintColor(.white, renderingMode: .alwaysOriginal)
//        case .setting:
//            return UIImage(systemName: ConstantImage.gearFill)?
//                .withTintColor(.white, renderingMode: .alwaysOriginal)
        }
    }
    
    func initialCoordinator(
        outerNavigationController: UINavigationController,
        navigationController: UINavigationController?,
        storage: CoreDataStorage
    ) -> Coordinator {
        switch self {
        case .main:
            return MainViewCoordinator(
                outerNavigationController: outerNavigationController,
                navigationController: navigationController,
                storage: storage
            )
//        case .bookmark:
//            return BookMarkViewCoordinator(navigationController: navigationController, storage: storage)
//        case .setting:
//            return
        }
    }
}
