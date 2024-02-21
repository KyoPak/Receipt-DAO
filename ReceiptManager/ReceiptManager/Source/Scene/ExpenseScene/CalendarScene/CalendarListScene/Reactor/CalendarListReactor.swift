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
        case onError(Error?)
    }
    
    struct State {
        var dateTitle: String
        var day: String
        var weekIndex: Int
        var expenseByDay: [Receipt]
        var amountByDay: String
        var dataError: Error?
    }
    
    let initialState: State
    
    // Properties
    
    private let expenseRepository: ExpenseRepository
    private let dateRepository: DateRepository
    let currentEvent: BehaviorSubject<Int>
    
    // Initializer
    
    init(
        expenseRepository: ExpenseRepository,
        dateRepository: DateRepository,
        userSettingRepository: UserSettingRepository,
        day: String,
        weekIndex: Int
    ) {
        self.expenseRepository = expenseRepository
        self.dateRepository = dateRepository
        self.currentEvent = userSettingRepository.currencyChangeEvent
        
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
            return updateDate()
                .withUnretained(self)
                .flatMap { (owner, date) in
                    owner.loadData(date: date)
                        .flatMap { expenses in
                            Observable.merge([
                                Observable.just(Mutation.updateDateTitle(date)),
                                Observable.just(Mutation.updateExpenseList(expenses))
                            ])
                        }
                }
            
        case .cellBookMark(let indexPath):
            var expense = currentState.expenseByDay[indexPath.row]
            expense.isFavorite.toggle()
            
            return expenseRepository.save(expense: expense)
                .withUnretained(self)
                .flatMap { (owner, _) in
                    owner.loadData(date: owner.currentState.dateTitle).map { models in
                        Mutation.updateExpenseList(models)}
                }
                .catch { error in
                    return Observable.concat([
                        Observable.just(Mutation.onError(error)),
                        Observable.just(Mutation.onError(nil))
                    ])
                }
            
        case .cellDelete(let indexPath):
            let expense = currentState.expenseByDay[indexPath.row]
            return expenseRepository.delete(expense: expense)
                .withUnretained(self)
                .flatMap { (owner, _) in
                    owner.loadData(date: owner.currentState.dateTitle).map { models in
                        Mutation.updateExpenseList(models)}
                }
                .catch { error in
                    return Observable.concat([
                        Observable.just(Mutation.onError(error)),
                        Observable.just(Mutation.onError(nil))
                    ])
                }
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
            
        case .onError(let error):
            newState.dataError = error
        }
        
        return newState
    }
}

extension CalendarListReactor {
    private func loadData(date: String) -> Observable<[Receipt]> {
        let dayFormat = ConstantText.dateFormatFull.localize()
        
        return expenseRepository.fetchExpenses()
            .map { datas in
                return datas.filter { expense in
                    let expenseDate = DateFormatter.string(from: expense.receiptDate, dayFormat)
                    return expenseDate == date
                }
            }
    }
}

extension CalendarListReactor {
    private func updateDate() -> Observable<String> {
        return dateRepository.fetchActiveDate()
            .map { [weak self] date in
                guard let self = self else { return "" }
                
                let day = self.currentState.day
                let month = DateFormatter.month(from: date)
                let year = DateFormatter.year(from: date)
                let newDate = self.createDateFromComponents(year: year, month: month, day: Int(day))
                
                return DateFormatter.string(from: newDate ?? Date(), ConstantText.dateFormatFull.localize())
            }
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
