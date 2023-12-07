//
//  AnalysisViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/7/23.
//

import ReactorKit

final class AnalysisViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case nextMonthButtonTapped
        case previoutMonthButtonTapped
        case todayButtonTapped
    }
    
    enum Mutation {
        case updateDate(Date)
    }
    
    struct State {
        var dateToShow: Date
        var expenses: [Receipt]
    }
    
    let initialState: State
    
    // Properties
    
    private let storage: CoreDataStorage
    private let userDefaultService: UserDefaultService
    private let dateService: DateManageService
    
    // Initializer
    
    init(storage: CoreDataStorage, userDefaultService: UserDefaultService, dateService: DateManageService) {
        self.storage = storage
        self.userDefaultService = userDefaultService
        self.dateService = dateService
        initialState = State(dateToShow: (try? dateService.currentDateEvent.value()) ?? Date(), expenses: [])
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .nextMonthButtonTapped:
            return dateService.updateDate(byAddingMonths: 1)
                .flatMap { Observable.just(Mutation.updateDate($0)) }
            
        case .previoutMonthButtonTapped:
            return dateService.updateDate(byAddingMonths: -1)
                .flatMap { Observable.just(Mutation.updateDate($0)) }
            
        case .todayButtonTapped:
            return dateService.updateToday()
                .flatMap { Observable.just(Mutation.updateDate($0)) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .updateDate(let updatedDate):
            newState.dateToShow = updatedDate
        }

        return newState
    }
}
