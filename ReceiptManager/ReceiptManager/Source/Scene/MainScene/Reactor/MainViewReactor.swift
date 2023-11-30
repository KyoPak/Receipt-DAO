//
//  MainViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/15.
//

import ReactorKit

final class MainViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case registerButtonTapped
        case searchButtonTapped
        case showModeButtomTapped
        case nextMonthButtonTapped
        case previoutMonthButtonTapped
        case todayButtonTapped
    }
    
    enum Mutation {
        case moveRegister
        case moveSearch
        case changeShowMode
        case updateDate(Date)
    }
    
    struct State {
        var title: String
        var isRegister: Bool = false
        var isSearch: Bool = false
        var showMode: ShowMode
        var dateToShow: Date
    }
    
    enum ShowMode {
        case calendar
        case list
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
        case .registerButtonTapped:
            return .just(.moveRegister)
        case .searchButtonTapped:
            return .just(.moveSearch)
        case .showModeButtomTapped:
            return .just(.changeShowMode)
        
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
        case .moveRegister:
            newState.isRegister = true
        
        case .moveSearch:
            newState.isSearch = true
        
        case .changeShowMode:
            newState.showMode = (newState.showMode == .calendar) ? .list : .calendar
            
        case .updateDate(let updatedDate):
            newState.dateToShow = updatedDate
        }

        return newState
    }
}
