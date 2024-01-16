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
    
    private let expenseRepository: ExpenseRepository
    private let currencyRepository: CurrencyRepository
    private let dateRepository: DateRepository
    
    init(
        navigationController: UINavigationController?,
        expenseRepository: ExpenseRepository,
        currencyRepository: CurrencyRepository,
        dateRepository: DateRepository
    ) {
        self.mainNavigationController = navigationController
        self.expenseRepository = expenseRepository
        self.currencyRepository = currencyRepository
        self.dateRepository = dateRepository
    }
    
    func start() {
        let calendarViewReactor = CalendarViewReactor(
            expenseRepository: expenseRepository,
            currencyRepository: currencyRepository,
            dateRepository: dateRepository
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
            expenseRepository: expenseRepository,
            currencyRepository: currencyRepository,
            dateRepository: dateRepository,
            day: day,
            index: index
        )
        
        calendarListViewCoordinator.parentCoordinator = self
        childCoordinators.append(calendarListViewCoordinator)
        
        calendarListViewCoordinator.start()
    }
}
