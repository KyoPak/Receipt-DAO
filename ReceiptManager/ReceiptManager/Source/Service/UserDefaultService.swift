//
//  UserDefaultService.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/26/23.
//

import RxSwift

protocol UserDefaultService {
    func fetchCurrencyIndex() -> Int
    func updateCurrency(index: Int) -> Observable<Int>
}

final class DefaultUserDefaultService: UserDefaultService {
    
    private let storage = UserDefaults.standard
    
    func fetchCurrencyIndex() -> Int {
        return storage.integer(forKey: ConstantText.currencyKey)
    }
    
    func updateCurrency(index: Int) -> Observable<Int> {
        storage.set(index, forKey: ConstantText.currencyKey)
        return Observable.just(fetchCurrencyIndex())
    }
}
