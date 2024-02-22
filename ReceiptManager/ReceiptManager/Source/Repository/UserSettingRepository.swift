//
//  CurrencyRepository.swift
//  ReceiptManager
//
//  Created by parkhyo on 1/13/24.
//

import RxSwift

protocol UserSettingRepository {
    var currencyChangeEvent: BehaviorSubject<Int> { get }
    
    func fetchIndex(type: OptionKeyType) -> Int
    func updateIndex(type: OptionKeyType, index: Int) -> Int
}

final class DefaultUserSettingRepository: UserSettingRepository {
    private let service: UserDefaultService
    let currencyChangeEvent: BehaviorSubject<Int>
    
    init(service: UserDefaultService) {
        self.service = service
        currencyChangeEvent = BehaviorSubject(value: service.fetch(type: .currency))
    }
    
    func fetchIndex(type: OptionKeyType) -> Int {
        return service.fetch(type: type)
    }
    
    func updateIndex(type: OptionKeyType, index: Int) -> Int {
        if type == .currency {
            currencyChangeEvent.onNext(index)
        }
        
        return service.update(type: type, index: index)
    }
}
