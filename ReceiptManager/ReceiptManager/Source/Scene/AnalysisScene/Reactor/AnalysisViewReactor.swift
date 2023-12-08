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
        var totalCount: String = ""
        var cardCount: String = ""
        var cashCount: String = ""
        var currency: Int
    }
    
    let initialState: State
    
    // Properties
    
    private let storage: CoreDataStorage
    private let userDefaultService: UserDefaultService
    private let dateService: DateManageService
    
    struct AnalysisResult {
        var totalAmount: String
        var totalCount: String
        var cardCount: String
        var cashCount: String
    }
    
    // Initializer
    
    init(storage: CoreDataStorage, userDefaultService: UserDefaultService, dateService: DateManageService) {
        self.storage = storage
        self.userDefaultService = userDefaultService
        self.dateService = dateService
        initialState = State(
            dateToShow: (try? dateService.currentDateEvent.value()) ?? Date(),
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
    private func loadData(by date: Date) -> Observable<[Receipt]> {
        return storage.fetch()
            .map { models in
                models.filter { model in
                    let expenseDate = DateFormatter.string(from: model.receiptDate)
                    
                    return expenseDate == DateFormatter.string(from: date)
                }
            }
    }
    
    private func analysisExpenses(datas: [Receipt]) -> AnalysisResult {
        var amount: Double = .zero
        var cardCount: Int = .zero
        var cashCount: Int = .zero
        
        for data in datas {
            amount += Double(data.priceText) ?? .zero
            
            switch PayType(rawValue: data.paymentType) ?? .cash {
            case .cash:
                cashCount += 1
            
            case .card:
                cardCount += 1
            }
        }
        
        let amountText = NumberFormatter.numberDecimal(from: amount.convertString()) == "" ?
                "0" : NumberFormatter.numberDecimal(from: amount.convertString())
        
        return AnalysisResult(
            totalAmount: amountText,
            totalCount: (cashCount + cardCount).description,
            cardCount: cardCount.description,
            cashCount: cashCount.description
        )
    }
}
