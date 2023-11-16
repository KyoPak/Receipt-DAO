//
//  ListViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/16.
//

import ReactorKit
import RxSwift
import RxCocoa

final class ListViewReactor: Reactor {
    enum Action {
        case viewWillAppear
        case nextMonthButtonTapped
        case previoutMonthButtonTapped
        case currentMonthButtonTapped
        
//        case cellSelect(IndexPath)
//        case cellDelete(IndexPath)
//        case cellBookMark(IndexPath)
    }
    
    enum Mutation {
        case loadData([ReceiptSectionModel])
        case nextMonth
        case previousMonth
        case currentMonth
        
//        case detailExpense(IndexPath)
//        case deleteExpense(IndexPath)
//        case bookMarkExpense(IndexPath)
    }
    
    struct State {
        var date: Date
        var expenseList: [ReceiptSectionModel]
    }
    
    let initialState = State(date: Date(), expenseList: [])
    
    private let storage: CoreDataStorage
    
    // Initializer
    
    init(storage: CoreDataStorage) {
        self.storage = storage
    }

    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return loadData().map { sectionModels in
                return Mutation.loadData(sectionModels)
            }
        case .nextMonthButtonTapped:
            return Observable.just(Mutation.nextMonth)
        case .previoutMonthButtonTapped:
            return Observable.just(Mutation.previousMonth)
        case .currentMonthButtonTapped:
            return Observable.just(Mutation.currentMonth)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        let calendar = Calendar.current
        switch mutation {
        case .loadData(let models):
            let newModels = filterData(by: newState.date, for: models)
            newState.expenseList = newModels
        case .nextMonth:
            let newDate = calendar.date(byAdding: DateComponents(month: 1), to: newState.date)
            newState.date = newDate ?? Date()
        case .previousMonth:
            let newDate = calendar.date(byAdding: DateComponents(month: -1), to: newState.date)
            newState.date = newDate ?? Date()
        case .currentMonth:
            let nowDate = Date()
            newState.date = nowDate
        }
        
        return newState
    }
}

extension ListViewReactor {
    private func loadData() -> Observable<[ReceiptSectionModel]> {
        return storage.fetch(type: .day)
    }
    
    private func filterData(by date: Date, for data: [ReceiptSectionModel]) -> [ReceiptSectionModel] {
        let currentDate = DateFormatter.string(from: date)
        
        return data.filter { sectionModel in
            return sectionModel.items.contains { expense in
                let expenseDate = DateFormatter.string(from: expense.receiptDate)
                return expenseDate == currentDate
            }
        }
    }
}
