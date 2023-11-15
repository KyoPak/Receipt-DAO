//
//  CustomTabItem.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/14.
//

import UIKit

enum CustomTabItem: String, CaseIterable {
    case list
    case bookmark
    case setting
}
 
extension CustomTabItem {
    var name: String {
        switch self {
        case .list:
            return ConstantText.list.localize()
        case .bookmark:
            return ConstantText.bookMark.localize()
        case .setting:
            return ConstantText.setting.localize()
        }
    }
    
    func viewController(storage: CoreDataStorage, coordinator: SceneCoordinator) -> UIViewController {
        switch self {
        case .list:
            let mainViewModel = MainViewModel(
                title: ConstantText.appName.localize(),
                sceneCoordinator: coordinator,
                storage: storage
            )
            
            return Scene.main(mainViewModel).instantiate()
        case .bookmark:
            let favoriteViewModel = FavoriteListViewModel(
                title: ConstantText.bookMark.localize(),
                sceneCoordinator: coordinator,
                storage: storage
            )
            
            return Scene.favorite(favoriteViewModel).instantiate()
        case .setting:
            let settingViewModel = SettingViewModel(
                title: ConstantText.setting.localize(),
                sceneCoordinator: coordinator,
                storage: storage
            )
            
            return Scene.setting(settingViewModel).instantiate()
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .list:
            return UIImage(systemName: ConstantImage.listCircle)?
                .withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        case .bookmark:
            return UIImage(systemName: ConstantImage.bookMark)?
                .withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        case .setting:
            return UIImage(systemName: ConstantImage.gear)?
                .withTintColor(.white.withAlphaComponent(0.4), renderingMode: .alwaysOriginal)
        }
    }
    
    var selectedIcon: UIImage? {
        switch self {
        case .list:
            return UIImage(systemName: ConstantImage.listCircleFill)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
        case .bookmark:
            return UIImage(systemName: ConstantImage.bookMarkFill)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
        case .setting:
            return UIImage(systemName: ConstantImage.gearFill)?
                .withTintColor(.white, renderingMode: .alwaysOriginal)
        }
    }
}
