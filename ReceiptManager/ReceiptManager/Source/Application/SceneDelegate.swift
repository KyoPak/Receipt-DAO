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
        
        // Root View 이동
        let storage = CoreDataStorage(modelName: "ReceiptManager")
        let coordinator = DefaultSceneCoordinator(window: window)
        let mainViewModel = MainViewModel(title: "Receipt Manager", sceneCoordinator: coordinator, storage: storage)
        
        let mainScene = Scene.main(mainViewModel)
        
        coordinator.transition(to: mainScene, using: .root, animated: false)
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
