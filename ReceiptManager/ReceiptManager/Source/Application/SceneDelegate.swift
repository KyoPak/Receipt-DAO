//
//  SceneDelegate.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.makeKeyAndVisible()
        
        // Launch Screen
        window.rootViewController = UIStoryboard(name: ConstantText.launchScreen, bundle: nil)
            .instantiateInitialViewController()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
            let storageService = DefaultStorageService(modelName: ConstantText.receiptManager)
            let userDefaultService = DefaultUserDefaultService()
            let dateManageService = DefaultDateManageService()
            
            let expenseRepository = DefaultExpenseRepository(service: storageService)
            let currencyRepository = DefaultCurrencyRepository(service: userDefaultService)
            let dateRepository = DefaultDateRepository(service: dateManageService)
            
            storageService.sync()
            
            let mainTabBarCoordinator = MainTabBarCoordinator(
                window: window,
                mainNavigationController: UINavigationController(),
                expenseRepository: expenseRepository,
                currencyRepository: currencyRepository,
                dateRepository: dateRepository
            )
            mainTabBarCoordinator.start()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }

    func sceneDidEnterBackground(_ scene: UIScene) {

    }
}
