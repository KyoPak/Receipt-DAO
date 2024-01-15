//
//  CalendarViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/1/23.
//

import ReactorKit

final class CalendarViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case loadData
    }
    
    enum Mutation {
        case updateExpenseDayInfos([ReceiptSectionModel], [DayInfo])
        case changeMonth(Date)
    }
    
    struct State {
        var expenseByMonth: [ReceiptSectionModel]
        var date: Date
        var dayInfos: [DayInfo]
    }
    
    let initialState: State
    
    // Properties
    
    struct DayInfo {
        var days: String
        var countOfExpense: String
        var amountOfExpense: String
        var isToday: Bool = false
    }
    
    private let calendar: Calendar
    private let expenseRepository: ExpenseRepository
    let currencyRepository: CurrencyRepository
    private let dateRepository: DateRepository
    
    // Initializer
    
    init(
        expenseRepository: ExpenseRepository,
        currencyRepository: CurrencyRepository,
        dateRepository: DateRepository
    ) {
        self.expenseRepository = expenseRepository
        self.currencyRepository = currencyRepository
        self.dateRepository = dateRepository
        
        calendar = Calendar.current
        initialState = State(expenseByMonth: [], date: Date(), dayInfos: [])
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            return loadData(by: currentState.date).map { models in
                return Mutation.updateExpenseDayInfos(models, self.updateDays(model: models))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .updateExpenseDayInfos(let models, let dayInfos):
            newState.expenseByMonth = models
            newState.dayInfos = dayInfos
            
        case .changeMonth(let date):
            newState.date = date
        }
        
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let dateEvent = dateRepository.fetchActiveDate()
            .flatMap { date in
                return Observable.concat(
                    Observable.just(Mutation.changeMonth(date)),
                    self.loadData(by: date).flatMap { models in
                        Observable.just(Mutation.updateExpenseDayInfos(
                            models,
                            self.updateDays(model: models))
                        )
                    }
                )
            }
        
        return Observable.merge(mutation, dateEvent)
    }
}

// MARK: - About Data
extension CalendarViewReactor {
    private func loadData(by date: Date?) -> Observable<[ReceiptSectionModel]> {
        let dayFormat = ConstantText.dateFormatFull.localize()
        
        return expenseRepository.fetch()
            .map { result in
                let dictionary = Dictionary(
                    grouping: result,
                    by: { DateFormatter.string(from: $0.receiptDate, dayFormat) }
                )
                
                let section = dictionary.sorted { return $0.key > $1.key }
                    .map { (key, value) in
                        return ReceiptSectionModel(model: key, items: value)
                    }
                
                return self.filterData(by: date, for: section)
            }
    }
    
    private func filterData(by date: Date?, for data: [ReceiptSectionModel]) -> [ReceiptSectionModel] {
        let currentDate = DateFormatter.string(from: date ?? Date())
        
        return data.filter { sectionModel in
            return sectionModel.items.contains { expense in
                let expenseDate = DateFormatter.string(from: expense.receiptDate)
                
                return expenseDate == currentDate
            }
        }
    }
}

// MARK: - Aboud Calendar
extension CalendarViewReactor {
    private func dateConvert(date: Date) -> Date {
        let component = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: component) ?? Date()
    }
    
    private func startDayOfTheWeek(date: Date) -> Int {
        return calendar.component(.weekday, from: date) - 1
    }
    
    private func endDate(date: Date) -> Int {
        return self.calendar.range(of: .day, in: .month, for: date)?.count ?? .zero
    }
    
    private func updateDays(model: [ReceiptSectionModel]) -> [DayInfo] {
        var newDays: [DayInfo] = []
        let convertedDate = dateConvert(date: currentState.date)
        
        let startDayOfTheWeek = startDayOfTheWeek(date: convertedDate)
        let totalDays = startDayOfTheWeek + endDate(date: convertedDate)
        
        for day in 0..<totalDays {
            if day < startDayOfTheWeek {
                newDays.append(DayInfo(days: "", countOfExpense: "", amountOfExpense: ""))
                continue
            }
            
            let realDay = day - startDayOfTheWeek + 1
            let mainInfo = String(realDay)
            let dayInfo = updateDaySubInfo(day: mainInfo, model: model)
            newDays.append(dayInfo)
        }
        
        return newDays
    }
    
    private func updateDaySubInfo(day: String, model: [ReceiptSectionModel]) -> DayInfo {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "d"
        
        var totalAmount: Double = .zero
        var totalCount = 0
        
        for expenseOfDay in model {
            for expense in expenseOfDay.items where dayFormatter.string(from: expense.receiptDate) == day {
                totalCount += 1
                totalAmount += Double(expense.priceText) ?? .zero
            }
        }
        
        return DayInfo(
            days: day,
            countOfExpense: convertCount(totalCount),
            amountOfExpense: totalAmount.convertString(),
            isToday: checkToday(day: day)
        )
    }
}

// MARK: - About DayInfo Data
extension CalendarViewReactor {
    private func convertCount(_ count: Int) -> String {
        return count == .zero ? "" : String(count)
    }
    
    private func checkToday(day: String) -> Bool {
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        let components = calendar.dateComponents([.year, .month, .day], from: currentState.date)
        
        return todayComponents.year == components.year &&
            todayComponents.month == components.month && 
            todayComponents.day == Int(day) ?? .zero
    }
}
