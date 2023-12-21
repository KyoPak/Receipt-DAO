//
//  CalendarViewCoordinator.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/5/23.
//

import UIKit

final class CalendarViewCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    var mainNavigationController: UINavigationController?
    var subNavigationController: UINavigationController?
    
    var viewController: UIViewController?
    
    private let storageService: StorageService
    private let userDefaultService: UserDefaultService
    private let dateManageService: DateManageService
    
    init(
        navigationController: UINavigationController?,
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService
    ) {
        self.mainNavigationController = navigationController
        self.storageService = storageService
        self.userDefaultService = userDefaultService
        self.dateManageService = dateManageService
    }
    
    func start() {
        let calendarViewReactor = CalendarViewReactor(
            storageService: storageService,
            userDefaultService: userDefaultService,
            dateManageService: dateManageService
        )
        let calendarViewContoller = CalendarViewController(reactor: calendarViewReactor)
        calendarViewContoller.coordinator = self
        viewController = calendarViewContoller
        
        guard let parentViewController = parentCoordinator?.mainNavigationController?.viewControllers.last 
        else {
            return
        }
        parentViewController.addChild(calendarViewContoller)
    }
}

extension CalendarViewCoordinator {
    func presentCalendarList(day: String, index: Int) {
        let calendarListViewCoordinator = CalendarListViewCoordinator(
            mainNavigationController: mainNavigationController,
            storageService: storageService,
            userDefaultService: userDefaultService,
            dateManageService: dateManageService,
            day: day,
            index: index
        )
        
        calendarListViewCoordinator.parentCoordinator = self
        childCoordinators.append(calendarListViewCoordinator)
        
        calendarListViewCoordinator.start()
    }
}
