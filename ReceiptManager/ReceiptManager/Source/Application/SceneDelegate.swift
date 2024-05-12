//
//  SceneDelegate.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import UIKit

import RxSwift

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let displayHandler: DisplayHandleService = DefaultDisplayHandleService()
    private let disposeBag = DisposeBag()
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.makeKeyAndVisible()
        
        sceneApplyDisplayMode()
        sceneBecomeInitialViewController()
    }

    private func sceneApplyDisplayMode() {
        let userDefaultService = DefaultUserDefaultService()
        let displayModeIndex = userDefaultService.fetch(type: .displayMode)
        displayHandler.applyDisplayMode(index: displayModeIndex)
    }
    
    private func sceneBecomeInitialViewController() {
        window?.rootViewController = UIStoryboard(
            name: ConstantText.launchScreen,
            bundle: nil
        )
        .instantiateInitialViewController()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            self.configureAppDependencies()
        }
    }
    
    private func configureAppDependencies() {
        // Dependency Setup
        let storageService = DefaultStorageService(modelName: ConstantText.receiptManager)
        let userDefaultService = DefaultUserDefaultService()
        let dateManageService = DefaultDateManageService()
        
        let expenseRepository = DefaultExpenseRepository(service: storageService)
        let userSettingRepository = DefaultUserSettingRepository(service: userDefaultService)
        let dateRepository = DefaultDateRepository(service: dateManageService)
        
        let mainTabBarCoordinator = MainTabBarCoordinator(
            window: self.window!,
            mainNavigationController: UINavigationController(),
            expenseRepository: expenseRepository,
            userSettingRepository: userSettingRepository,
            dateRepository: dateRepository
        )
        
        let status = userDefaultService.fetch(type: .sync)
        let syncStatus = SyncStatus(rawValue: status)
        
        switch syncStatus {
        case .notStarted:
            storageService.dataSync()
                .observe(on: MainScheduler.instance)
                .subscribe { _ in
                    userDefaultService.update(type: .sync, index: SyncStatus.complete.rawValue)
                    mainTabBarCoordinator.start()
                }
                .disposed(by: disposeBag)
        case .complete:
            mainTabBarCoordinator.start()
        default:
            return
        }
    }
}
