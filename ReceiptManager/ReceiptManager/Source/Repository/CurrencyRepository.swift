//
//  CurrencyRepository.swift
//  ReceiptManager
//
//  Created by parkhyo on 1/13/24.
//

import RxSwift

protocol CurrencyRepository {
    var saveEvent: BehaviorSubject<Int> { get }
    
    func fetch() -> Int
    func save(index: Int) -> Observable<Int>
}

final class DefaultCurrencyRepository: CurrencyRepository {
    private let service: UserDefaultService
    let saveEvent: BehaviorSubject<Int>
    
    init(service: UserDefaultService) {
        self.service = service
        saveEvent = BehaviorSubject(value: service.fetchCurrencyIndex())
    }
    
    func fetch() -> Int {
        return service.fetchCurrencyIndex()
    }
    
    func save(index: Int) -> Observable<Int> {
        return service.updateCurrency(index: index)
    }
}
