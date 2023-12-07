//
//  ExpenseViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import ReactorKit

enum ShowMode {
    case list
    case calendar
}

final class ExpenseViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case showModeButtonTapped
        case nextMonthButtonTapped
        case previoutMonthButtonTapped
        case todayButtonTapped
    }
    
    enum Mutation {
        case changeShowMode(ShowMode)
        case updateDate(Date)
    }
    
    struct State {
        var title: String
        var showMode: ShowMode
        var dateToShow: Date
    }
    
    let initialState: State
    
    // Properties
    
    private let storage: CoreDataStorage
    private let dateService: DateManageService
    
    // Initializer
    
    init(storage: CoreDataStorage, dateService: DateManageService) {
        self.storage = storage
        self.dateService = dateService
        initialState = State(
            title: ConstantText.list.localize(),
            showMode: .list,
            dateToShow: (try? dateService.currentDateEvent.value()) ?? Date()
        )
    }

    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .showModeButtonTapped:
            let newMode = currentState.showMode == .list ? ShowMode.calendar : ShowMode.list
            return .just(.changeShowMode(newMode))
        
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
        case .changeShowMode(let newMode):
            newState.showMode = newMode
            
        case .updateDate(let updatedDate):
            newState.dateToShow = updatedDate
        }

        return newState
    }
}
