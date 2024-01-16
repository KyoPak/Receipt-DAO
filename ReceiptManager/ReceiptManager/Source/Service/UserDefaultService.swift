//
//  UserDefaultService.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/26/23.
//

import RxSwift

protocol UserDefaultService {
    func fetch() -> Int
    func update(index: Int) -> Observable<Int>
}

final class DefaultUserDefaultService: UserDefaultService {
    
    private let storage = UserDefaults.standard
    
    func fetch() -> Int {
        return storage.integer(forKey: ConstantText.currencyKey)
    }
    
    func update(index: Int) -> Observable<Int> {
        storage.set(index, forKey: ConstantText.currencyKey)
        return Observable.just(fetch())
    }
}
