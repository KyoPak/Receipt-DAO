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
    
    private let storageService: StorageService
    private let dateManageService: DateManageService
    let userDefaultEvent: BehaviorSubject<Int>
    
    // Initializer
    
    init(
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService,
        day: String,
        weekIndex: Int
    ) {
        self.storageService = storageService
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
            storageService.upsert(receipt: expense)
            return Observable.empty()
            
        case .cellDelete(let indexPath):
            let expense = currentState.expenseByDay[indexPath.row]
            storageService.delete(receipt: expense)
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
        
        return storageService.fetch()
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
        let date = (try? dateManageService.currentDateEvent.value()) ?? Date()
        
        let day = currentState.day
        let month = DateFormatter.month(from: date)
        let year = DateFormatter.year(from: date)
        
        let newDate = createDateFromComponents(year: year, month: month, day: Int(day))
        return DateFormatter.string(from: newDate ?? Date(), ConstantText.dateFormatFull.localize())
    }
    
    private func createDateFromComponents(year: Int?, month: Int?, day: Int?) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        let calendar = Calendar.current
        return calendar.date(from: dateComponents)
    }
    
    private func updateAmount(_ expenses: [Receipt]) -> String {
        var totalAmount: Double = .zero
        
        for expense in expenses {
            totalAmount += Double(expense.priceText) ?? .zero
        }
        
        return NumberFormatter.numberDecimal(from: totalAmount.convertString())
    }
}
