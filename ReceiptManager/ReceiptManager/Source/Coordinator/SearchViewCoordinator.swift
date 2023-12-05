//
//  SearchViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/5/23.
//

import UIKit

final class SearchViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController?
    var storage: CoreDataStorage
    var userDefaultService: UserDefaultService
    
    init(
        navigationController: UINavigationController?,
        storage: CoreDataStorage,
        userDefaultService: UserDefaultService
    ) {
        self.navigationController = navigationController
        self.storage = storage
        self.userDefaultService = userDefaultService
    }
    
    func start() {
        let searchViewReactor = SearchViewReactor(
            storage: storage,
            userDefaultService: userDefaultService
            
        )
        let searchViewController = SearchViewController(reactor: searchViewReactor)
        searchViewController.coordinator = self
            
        searchViewController.modalPresentationStyle = .fullScreen
        navigationController?.present(searchViewController, animated: true)
    }
    
    func close(_ controller: UIViewController) {
        removeChild(self)
        controller.dismiss(animated: true)
    }
}
