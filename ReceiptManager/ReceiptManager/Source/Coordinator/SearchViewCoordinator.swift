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
    var innerNavigationController: UINavigationController
    var storageService: StorageService
    var userDefaultService: UserDefaultService
    
    init(
        navigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService
    ) {
        self.navigationController = navigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
        self.innerNavigationController = UINavigationController()
    }
    
    func start() {
        let searchViewReactor = SearchViewReactor(
            storageService: storageService,
            userDefaultService: userDefaultService
        )
        let searchViewController = SearchViewController(reactor: searchViewReactor)
        innerNavigationController.setViewControllers([searchViewController], animated: true)
        searchViewController.coordinator = self
            
        innerNavigationController.modalPresentationStyle = .fullScreen
        navigationController?.present(innerNavigationController, animated: true)
    }
    
    func presentDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            navigationController: innerNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
    
    func close(_ controller: UIViewController) {
        removeChild(self)
        controller.dismiss(animated: true)
    }
}
