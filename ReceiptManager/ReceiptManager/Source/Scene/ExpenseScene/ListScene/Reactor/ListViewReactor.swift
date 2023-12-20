//
//  ListViewReactor.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/11/16.
//

import ReactorKit

final class ListViewReactor: Reactor {
    
    // Reactor Properties
    
    enum Action {
        case loadData
        case cellBookMark(IndexPath)
        case cellDelete(IndexPath)
    }
    
    enum Mutation {
        case updateExpenseList([ReceiptSectionModel])
        case changeMonth(Date)
        case onError(StorageServiceError?)
    }
    
    struct State {
        var expenseByMonth: [ReceiptSectionModel]
        var date: Date
        var dataError: StorageServiceError?
    }
    
    let initialState: State
    
    // Properties
    
    private let storageService: StorageService
    let userDefaultEvent: BehaviorSubject<Int>
    let dateManageEvent: BehaviorSubject<Date>
    
    // Initializer
    
    init(
        storageService: StorageService,
        userDefaultService: UserDefaultService,
        dateManageService: DateManageService
    ) {
        self.storageService = storageService
        userDefaultEvent = userDefaultService.event
        dateManageEvent = dateManageService.currentDateEvent
        initialState = State(expenseByMonth: [], date: Date())
    }
    
    // Reactor Method
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadData:
            return loadData().map { models in
                Mutation.updateExpenseList(self.filterData(by: self.currentState.date, for: models))
            }
            
        case .cellBookMark(let indexPath):
            var expense = currentState.expenseByMonth[indexPath.section].items[indexPath.row]
            expense.isFavorite.toggle()
            return storageService.upsert(receipt: expense)
                .flatMap { _ in
                    self.loadData().map { models in
                        Mutation.updateExpenseList(self.filterData(by: self.currentState.date, for: models))
                    }
                }
                .catch { error in
                    return Observable.concat([
                        Observable.just(Mutation.onError(error as? StorageServiceError)),
                        Observable.just(Mutation.onError(nil))
                    ])
                }

        case .cellDelete(let indexPath):
            let expense = currentState.expenseByMonth[indexPath.section].items[indexPath.row]
            return storageService.delete(receipt: expense)
                .flatMap { _ in
                    self.loadData().map { models in
                        Mutation.updateExpenseList(self.filterData(by: self.currentState.date, for: models))
                    }
                }
                .catch { error in
                    return Observable.concat([
                        Observable.just(Mutation.onError(error as? StorageServiceError)),
                        Observable.just(Mutation.onError(nil))
                    ])
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .updateExpenseList(let models):
            newState.expenseByMonth = models
            
        case .changeMonth(let date):
            newState.date = date
            
        case .onError(let error):
            newState.dataError = error
        }
        
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let dateEvent = dateManageEvent
            .flatMap { date in
                return Observable.concat(
                    Observable.just(Mutation.changeMonth(date)),
                    self.loadData().map { models in
                        Mutation.updateExpenseList(self.filterData(by: self.currentState.date, for: models))
                    }
                )
            }
        
        return Observable.merge(mutation, dateEvent)
    }
}

extension ListViewReactor {
    private func loadData() -> Observable<[ReceiptSectionModel]> {
        let dayFormat = ConstantText.dateFormatFull.localize()
        
        return storageService.fetch()
            .distinctUntilChanged()
            .map { result in
                let dictionary = Dictionary(
                    grouping: result,
                    by: { DateFormatter.string(from: $0.receiptDate, dayFormat) }
                )
                
                let section = dictionary.sorted { return $0.key > $1.key }
                    .map { (key, value) in
                        return ReceiptSectionModel(model: key, items: value)
                    }
                
                return section
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
