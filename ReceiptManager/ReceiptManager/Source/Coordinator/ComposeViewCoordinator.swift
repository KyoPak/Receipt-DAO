//
//  ComposeViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/21.
//

import UIKit

enum TransitionType {
    case modal
    case push
}

final class ComposeViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var navigationController: UINavigationController?
    var innerNavigationController: UINavigationController
    var storage: CoreDataStorage
    var expense: Receipt?
    var transitionType: TransitionType
    
    init(
        transitionType: TransitionType,
        navigationController: UINavigationController?,
        storage: CoreDataStorage,
        expense: Receipt?
    ) {
        self.transitionType = transitionType
        self.navigationController = navigationController
        self.storage = storage
        self.expense = expense
        self.innerNavigationController = UINavigationController()
    }
    
    func start() {
        let composeViewReactor = ComposeViewReactor(
            storage: storage,
            expense: expense,
            transisionType: transitionType
        )
        let composeViewController = ComposeViewController(reactor: composeViewReactor)
        composeViewController.coordinator = self
        
        switch transitionType {
        case .modal:
            innerNavigationController.setViewControllers([composeViewController], animated: true)
            innerNavigationController.modalPresentationStyle = .fullScreen
            navigationController?.present(innerNavigationController, animated: true)
            
        case .push:
            navigationController?.pushViewController(composeViewController, animated: true)
        }
    }
    
    func close(_ controller: UIViewController) {
        removeChild(self)
        
        switch transitionType {
        case .modal:
            controller.navigationController?.dismiss(animated: true)
        
        case .push:
            navigationController?.popViewController(animated: true)
        }
    }
    
    func presentLimitAlbumView(delegate: SelectPickerImageDelegate) {
        let limitAlbumViewCoordinator: LimitAlbumViewCoordinator
        
        switch transitionType {
        case .modal:
            limitAlbumViewCoordinator = LimitAlbumViewCoordinator(
                navigationController: innerNavigationController,
                storage: storage,
                delegate: delegate
            )
        case .push:
            limitAlbumViewCoordinator = LimitAlbumViewCoordinator(
                navigationController: navigationController,
                storage: storage,
                delegate: delegate
            )
        }
        
        limitAlbumViewCoordinator.parentCoordinator = self
        childCoordinators.append(limitAlbumViewCoordinator)
        
        limitAlbumViewCoordinator.start()
    }
}
