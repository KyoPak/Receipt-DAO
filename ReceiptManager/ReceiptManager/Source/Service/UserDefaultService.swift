//
//  UserDefaultService.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/26/23.
//

import RxSwift

protocol UserDefaultService {
    var event: BehaviorSubject<Int> { get }
    
    func updateCurrency(index: Int)
}

final class DefaultUserDefault: UserDefaultService {
    
    private let storage = UserDefaults.standard
    
    let event: BehaviorSubject<Int>
    
    init() {
        event = BehaviorSubject(value: storage.integer(forKey: ConstantText.currencyKey))
    }
    
    func updateCurrency(index: Int) {
        storage.set(index, forKey: ConstantText.currencyKey)
        event.onNext(index)
    }
}
