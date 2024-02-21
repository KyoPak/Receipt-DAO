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
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let expenseRepository: ExpenseRepository
    private let userSettingRepository: UserSettingRepository
    
    private let expense: Receipt?
    private let transitionType: TransitionType
    
    init(
        transitionType: TransitionType,
        mainNavigationController: UINavigationController?,
        expenseRepository: ExpenseRepository,
        userSettingRepository: UserSettingRepository,
        expense: Receipt?
    ) {
        self.transitionType = transitionType
        self.mainNavigationController = mainNavigationController
        self.expenseRepository = expenseRepository
        self.userSettingRepository = userSettingRepository
        self.expense = expense
        self.subNavigationController = UINavigationController()
    }
    
    func start() {
        let ocrExtractor = DefaultOCRExtractorService(currencyIndex: userSettingRepository.fetchIndex(type: .currency))
        let ocrRepository = DefaultOCRRepository(service: ocrExtractor)
        
        let composeViewReactor = ComposeViewReactor(
            expenseRepository: expenseRepository,
            ocrRepository: ocrRepository,
            userSettingRepository: userSettingRepository,
            expense: expense,
            transisionType: transitionType)
        
        let composeViewController = ComposeViewController(reactor: composeViewReactor)
        composeViewController.coordinator = self
        
        switch transitionType {
        case .modal:
            subNavigationController?.setViewControllers([composeViewController], animated: true)
            subNavigationController?.modalPresentationStyle = .fullScreen
            mainNavigationController?.present(
                subNavigationController ?? UINavigationController(),
                animated: true
            )
            
        case .push:
            mainNavigationController?.pushViewController(composeViewController, animated: true)
        }
    }
    
    func close(_ controller: UIViewController) {
        removeChild(self)
        
        switch transitionType {
        case .modal:
            controller.navigationController?.dismiss(animated: true)
        
        case .push:
            mainNavigationController?.popViewController(animated: true)
        }
    }
}

extension ComposeViewCoordinator {
    func presentLimitAlbumView(delegate: SelectPickerImageDelegate, imageCount: Int) {
        let limitAlbumViewCoordinator: LimitAlbumViewCoordinator
        
        switch transitionType {
        case .modal:
            limitAlbumViewCoordinator = LimitAlbumViewCoordinator(
                navigationController: subNavigationController,
                delegate: delegate,
                imageCount: imageCount
            )
        case .push:
            limitAlbumViewCoordinator = LimitAlbumViewCoordinator(
                navigationController: mainNavigationController,
                delegate: delegate,
                imageCount: imageCount
            )
        }
        
        limitAlbumViewCoordinator.parentCoordinator = self
        childCoordinators.append(limitAlbumViewCoordinator)
        
        limitAlbumViewCoordinator.start()
    }
    
    func presentAlert(error: Error, delegate: Retriable? = nil) {
        
        let alertCoordinator: AlertViewCoordinator
        switch transitionType {
        case .modal:
            alertCoordinator = AlertViewCoordinator(
                mainNavigationController: subNavigationController,
                error: error,
                retryDelegate: delegate
            )
            
        case .push:
            alertCoordinator = AlertViewCoordinator(
                mainNavigationController: mainNavigationController,
                error: error,
                retryDelegate: delegate
            )
        }

        alertCoordinator.parentCoordinator = self
        childCoordinators.append(alertCoordinator)
        alertCoordinator.start()
    }
}
