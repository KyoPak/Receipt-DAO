//
//  CurrencyRepository.swift
//  ReceiptManager
//
//  Created by parkhyo on 1/13/24.
//

import RxSwift

protocol CurrencyRepository {
    var saveEvent: BehaviorSubject<Int> { get }
    
    func fetchCurrencyIndex() -> Int
    func updateCurrency(index: Int) -> Observable<Int>
}

final class DefaultCurrencyRepository: CurrencyRepository {
    private let service: UserDefaultService
    let saveEvent: BehaviorSubject<Int>
    
    init(service: UserDefaultService) {
        self.service = service
        saveEvent = BehaviorSubject(value: service.fetch(key: .currency))
    }
    
    func fetchCurrencyIndex() -> Int {
        return service.fetch(key: .currency)
    }
    
    func updateCurrency(index: Int) -> Observable<Int> {
        saveEvent.onNext(index)
        return service.update(key: .currency, index: index)
    }
}
