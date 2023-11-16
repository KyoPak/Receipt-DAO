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
    
    // Reactor Properties
    
    enum Action {
        case viewWillAppear
        case nextMonthButtonTapped
        case previoutMonthButtonTapped
        case currentMonthButtonTapped
        case cellBookMark(IndexPath)
        case cellDelete(IndexPath)
    }
    
    enum Mutation {
        case loadData([ReceiptSectionModel])
        case updateDate(Date, [ReceiptSectionModel])
        case updateExpenseList([ReceiptSectionModel])
    }
    
    struct State {
        var date: Date
        var dateText: String
        var expenseByMonth: [ReceiptSectionModel]
    }
    
    let initialState = State(date: Date(), dateText: DateFormatter.string(from: Date()), expenseByMonth: [])
    
    // Properties
    
    private let storage: CoreDataStorage
    
    // Initializer
    
    init(storage: CoreDataStorage) {
        self.storage = storage
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return loadData().map { sectionModels in
                return Mutation.loadData(sectionModels)
            }
        case .nextMonthButtonTapped:
            return updateDate(byAddingMonths: 1)
            
        case .previoutMonthButtonTapped:
            return updateDate(byAddingMonths: -1)
            
        case .currentMonthButtonTapped:
            return updateDate(current: true)
            
        case .cellBookMark(let indexPath):
            var expense = currentState.expenseByMonth[indexPath.section].items[indexPath.row]
            expense.isFavorite.toggle()
            storage.upsert(receipt: expense)
            
            return loadData().map { models in
                Mutation.updateExpenseList(self.filterData(by: self.currentState.date, for: models))
            }
            
        case .cellDelete(let indexPath):
            var expense = currentState.expenseByMonth[indexPath.section].items[indexPath.row]
            storage.delete(receipt: expense)
            
            return loadData().map { models in
                Mutation.updateExpenseList(self.filterData(by: self.currentState.date, for: models))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .loadData(let models):
            newState.expenseByMonth = filterData(by: currentState.date, for: models)
            
        case .updateDate(let date, let models):
            newState.date = date
            newState.dateText = DateFormatter.string(from: date)
            newState.expenseByMonth = models
            
        case .updateExpenseList(let models):
            newState.expenseByMonth = models
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
    
    private func updateDate(byAddingMonths months: Int = 0, current: Bool = false) -> Observable<Mutation> {
        if current {
            return loadData().map { models in
                Mutation.updateDate(Date(), self.filterData(by: Date(), for: models))
            }
        }
        
        let calendar = Calendar.current
        let newDate = calendar.date(byAdding: DateComponents(month: months), to: currentState.date) ?? Date()
        
        return loadData().map { models in
            Mutation.updateDate(newDate, self.filterData(by: newDate, for: models))
        }
    }
}
