//
//  CurrencyRepository.swift
//  ReceiptManager
//
//  Created by parkhyo on 1/13/24.
//

import RxSwift

protocol CurrencyRepository {
    var currencyChangeEvent: BehaviorSubject<Int> { get }
    
    func fetchCurrencyIndex() -> Int
    func updateCurrency(index: Int) -> Int
}

final class DefaultCurrencyRepository: CurrencyRepository {
    private let service: UserDefaultService
    let currencyChangeEvent: BehaviorSubject<Int>
    
    init(service: UserDefaultService) {
        self.service = service
        currencyChangeEvent = BehaviorSubject(value: service.fetch(key: .currency))
    }
    
    func fetchCurrencyIndex() -> Int {
        return service.fetch(key: .currency)
    }
    
    func updateCurrency(index: Int) -> Int {
        currencyChangeEvent.onNext(index)
        return service.update(key: .currency, index: index)
    }
}
