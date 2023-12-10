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
        case updateAnalysis(AnalysisResult)
        case updateCurrency(Int)
    }
    
    struct State {
        var dateToShow: Date
        var totalAmount: String = ""
        var totalCount: Int = .zero
        var cardCount: Int = .zero
        var cashCount: Int = .zero
        var rate: RateOfAmount
        var currency: Int
    }
    
    let initialState: State
    
    // Properties
    
    private let storage: CoreDataStorage
    private let userDefaultService: UserDefaultService
    private let dateService: DateManageService
    
    struct AnalysisResult {
        var totalAmount: String
        var totalCount: Int
        var cardCount: Int
        var cashCount: Int
        var rate: RateOfAmount
    }
    
    // Initializer
    
    init(storage: CoreDataStorage, userDefaultService: UserDefaultService, dateService: DateManageService) {
        self.storage = storage
        self.userDefaultService = userDefaultService
        self.dateService = dateService
        initialState = State(
            dateToShow: (try? dateService.currentDateEvent.value()) ?? Date(),
            rate: .noData,
            currency: (try? userDefaultService.event.value()) ?? .zero
        )
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
            
        case .updateAnalysis(let result):
            newState.totalAmount = result.totalAmount
            newState.totalCount = result.totalCount
            newState.cardCount = result.cardCount
            newState.cashCount = result.cashCount
            newState.rate = result.rate
            
        case .updateCurrency(let index):
            newState.currency = index
        }

        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let userDefaultEvent = userDefaultService.event
            .flatMap {
                return Observable.just(Mutation.updateCurrency($0))
            }
        
        let dateEvent = dateService.currentDateEvent
            .flatMap { date in
                return self.loadData(by: date).flatMap { models in
                    return Observable.just(Mutation.updateAnalysis(self.analysisExpenses(datas: models)))
                }
            }
        
        return Observable.merge(mutation, userDefaultEvent, dateEvent)
    }
}

extension AnalysisViewReactor {
    private func loadData(by date: Date) -> Observable<(current: [Receipt], previous: [Receipt])> {
        let previousDate = Calendar.current.date(byAdding: DateComponents(month: -1), to: date)
        
        return storage.fetch()
            .map { models in
                let groupedModels = Dictionary(grouping: models) { model in
                    DateFormatter.string(from: model.receiptDate)
                }
                
                let currentMonthKey = DateFormatter.string(from: date)
                let previousMonthKey = DateFormatter.string(from: previousDate ?? Date())
                
                let currentMonthModels = groupedModels[currentMonthKey] ?? []
                let previousMonthModels = groupedModels[previousMonthKey] ?? []
                
                return (currentMonthModels, previousMonthModels)
            }
    }
}

// MARK: - About Analysis
extension AnalysisViewReactor {
    enum RateOfAmount {
        case increase(String)
        case decrease(String)
        case equal
        case noData
        
        var rateText: String {
            switch self {
            case .increase(let rating):
                ConstantText.ratingUp.localized(with: rating + "%")
                
            case .decrease(let rating):
                ConstantText.ratingDown.localized(with: rating + "%")
            
            case .equal:
                ConstantText.ratingEqual
            
            case .noData:
                ""
            }
        }
    }
    
    private func analysisExpenses(datas: (current: [Receipt], previous: [Receipt])) -> AnalysisResult {

        // Amount, Count Analysis
        
        let currentAmount = datas.current.reduce(0.0) { $0 + (Double($1.priceText) ?? 0.0) }
        let previousAmount = datas.previous.reduce(0.0) { $0 + (Double($1.priceText) ?? 0.0) }
            
        let cardCount = datas.current.filter { $0.paymentType == PayType.card.rawValue }.count
        let cashCount = datas.current.filter { $0.paymentType == PayType.cash.rawValue }.count
        
        // Rate Analysis
        
        let rate = analysisRate(currentAmount: currentAmount, previousAmount: previousAmount)
        let amountText = NumberFormatter.numberDecimal(from: currentAmount.convertString()) == "" ?
                "0" : NumberFormatter.numberDecimal(from: currentAmount.convertString())
        
        return AnalysisResult(
            totalAmount: amountText,
            totalCount: cashCount + cardCount,
            cardCount: cardCount,
            cashCount: cashCount,
            rate: rate
        )
    }
    
    private func analysisRate(currentAmount: Double, previousAmount: Double) -> RateOfAmount {
        if currentAmount == .zero || previousAmount == .zero { return .noData }
        
        if currentAmount > previousAmount {
            return .increase(calculateIncreaseRate(bigger: currentAmount, smaller: previousAmount))
        }
        
        if currentAmount < previousAmount {
            return .decrease(calculateDecreaseRate(bigger: previousAmount, smaller: currentAmount))
        }
        
        return .equal
    }
    
    private func calculateIncreaseRate(bigger: Double, smaller: Double) -> String {
        let result = (((bigger - smaller) / smaller) * 100)
        return (Double(String(format: "%.2f", result)) ?? .zero).convertString()
    }
    
    private func calculateDecreaseRate(bigger: Double, smaller: Double) -> String {
        let result = (((bigger - smaller) / bigger) * 100)
        return (Double(String(format: "%.2f", result)) ?? .zero).convertString()
    }
}
