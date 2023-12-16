//
//  CalendarListReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/5/23.
//

import ReactorKit

final class CalendarListReactor: Reactor {
    
    // Reactor Properties
    
    enum Action { 
        case loadData
        case cellBookMark(IndexPath)
        case cellDelete(IndexPath)
    }
    
    enum Mutation {
        case updateDateTitle(String)
        case updateExpenseList([Receipt])
        case updateAmount(String)
    }
    
    struct State {
        var dateTitle: String
        var day: String
        var weekIndex: Int
        var expenseByDay: [Receipt]
        var amountByDay: String
    }
    
    let initialState: State
    
    // Properties
    
    private let storage: CoreDataStorage
    private let dateManageService: DateManageService
    let userDefaultEvent: BehaviorSubject<Int>
    
    // Initializer
    
    init(
        storage: CoreDataStorage,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService,
        day: String,
        weekIndex: Int
    ) {
        self.storage = storage
        self.userDefaultEvent = userDefaultService.event
        self.dateManageService = dateManageService
        
        initialState = State(
            dateTitle: "",
            day: day,
            weekIndex: weekIndex % 7,
            expenseByDay: [], 
            amountByDay: ""
        )
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> { 
        switch action {
        case .loadData:
            return Observable.concat([
                Observable.just(Mutation.updateDateTitle(updateDate())),
                loadData().flatMap({ models in
                    return Observable.concat([
                        Observable.just(Mutation.updateExpenseList(models)),
                        Observable.just(Mutation.updateAmount(self.updateAmount(models)))
                    ])
                })
            ])
            
        case .cellBookMark(let indexPath):
            var expense = currentState.expenseByDay[indexPath.row]
            expense.isFavorite.toggle()
            storage.upsert(receipt: expense)
            return Observable.empty()
            
        case .cellDelete(let indexPath):
            let expense = currentState.expenseByDay[indexPath.row]
            storage.delete(receipt: expense)
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .updateDateTitle(let title):
            newState.dateTitle = title
        
        case .updateExpenseList(let models):
            newState.expenseByDay = models
            
        case .updateAmount(let amount):
            newState.amountByDay = amount
        }
        
        return newState
    }
}

extension CalendarListReactor {
    private func loadData() -> Observable<[Receipt]> {
        let dayFormat = ConstantText.dateFormatFull.localize()
        let currentDate = updateDate()
        
        return storage.fetch()
            .distinctUntilChanged()
            .map { result in
                return result.filter { expense in
                    let expenseDate = DateFormatter.string(from: expense.receiptDate, dayFormat)
                    return expenseDate == currentDate
                }
            }
    }
}

extension CalendarListReactor {
    private func updateDate() -> String {
        let day = currentState.day
        let date = (try? dateManageService.currentDateEvent.value()) ?? Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = ConstantText.dateFormatMonth.localize()
            
        let yearMonthFormat = dateFormatter.string(from: date)
        dateFormatter.dateFormat = ConstantText.dateFormatDay.localize()
        let dayFormat = dateFormatter.string(from: dateFormatter.date(from: day) ?? Date())
            
        return "\(yearMonthFormat) \(dayFormat)"
    }
    
    private func updateAmount(_ expenses: [Receipt]) -> String {
        var totalAmount: Double = .zero
        
        for expense in expenses {
            totalAmount += Double(expense.priceText) ?? .zero
        }
        
        return NumberFormatter.numberDecimal(from: convertAmount(totalAmount))
    }
    
    private func convertAmount(_ amount: Double) -> String {
        if amount == .zero {
            return ""
        }
        
        if Double(Int(amount)) == amount {
            let newAmount = String(Int(amount))
            return newAmount
        } else {
            return String(amount)
        }
    }
}
