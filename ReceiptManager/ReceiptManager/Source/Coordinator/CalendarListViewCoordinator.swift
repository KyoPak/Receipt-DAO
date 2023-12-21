//
//  CalendarListViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/5/23.
//

import UIKit

final class CalendarListViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    private let storageService: StorageService
    private let userDefaultService: UserDefaultService
    private let dateManageService: DateManageService
    
    private let day: String
    private let weekIndex: Int
    
    init(
        mainNavigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService,
        day: String,
        index: Int
    ) {
        self.mainNavigationController = mainNavigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
        self.dateManageService = dateManageService
        
        self.day = day
        weekIndex = index
        subNavigationController = UINavigationController()
    }
    
    func start() {
        let calendarListViewReactor = CalendarListReactor(
            storageService: storageService,
            userDefaultService: userDefaultService,
            dateManageService: dateManageService,
            day: day,
            weekIndex: weekIndex
        )
        
        let calendarListViewController = CalendarListViewController(reactor: calendarListViewReactor)
        calendarListViewController.coordinator = self
        
        let bottomSheetViewController = BottomSheetViewController(
            controller: calendarListViewController,
            bottomHeightRatio: 0.7,
            delegate: calendarListViewController
        )
        
        subNavigationController?.setViewControllers([bottomSheetViewController], animated: true)
        subNavigationController?.modalPresentationStyle = .overFullScreen
        
        mainNavigationController?.present(subNavigationController ?? UINavigationController(), animated: true)
    }
}

extension CalendarListViewCoordinator {
    func presentDetailView(expense: Receipt) {
        let detailViewCoordinator = DetailViewCoordinator(
            mainNavigationController: subNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            expense: expense
        )
        
        detailViewCoordinator.parentCoordinator = self
        childCoordinators.append(detailViewCoordinator)
        
        detailViewCoordinator.start()
    }
    
    func presentAlert(error: Error) {
        let alertCoordinator = AlertViewCoordinator(
            mainNavigationController: subNavigationController,
            error: error
        )
        
        alertCoordinator.parentCoordinator = self
        childCoordinators.append(alertCoordinator)
        alertCoordinator.start()
    }
}
