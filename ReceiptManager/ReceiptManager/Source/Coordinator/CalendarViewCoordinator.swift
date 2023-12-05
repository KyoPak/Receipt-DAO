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
    
    var navigationController: UINavigationController?
    var storage: CoreDataStorage
    var userDefaultService: UserDefaultService
    var dateManageService: DateManageService
    
    var viewController: UIViewController?
    
    init(
        navigationController: UINavigationController?,
        storage: CoreDataStorage,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService
    ) {
        self.navigationController = navigationController
        self.storage = storage
        self.userDefaultService = userDefaultService
        self.dateManageService = dateManageService
    }
    
    func start() {
        let calendarViewReactor = CalendarViewReactor(
            storage: storage,
            userDefaultService: userDefaultService,
            dateManageService: dateManageService
        )
        let calendarViewContoller = CalendarViewController(reactor: calendarViewReactor)
        calendarViewContoller.coordinator = self
        viewController = calendarViewContoller
        
        guard let parentViewController = parentCoordinator?.navigationController?.viewControllers.last else {
            return
        }
        parentViewController.addChild(calendarViewContoller)
    }
    
    func presentCalendarList(day: String, index: Int) {
        let calendarListViewCoordinator = CalendarListViewCoordinator(
            navigationController: navigationController,
            storage: storage,
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
