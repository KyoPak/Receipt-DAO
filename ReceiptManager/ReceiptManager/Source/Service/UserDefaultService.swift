//
//  UserDefaultService.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/26/23.
//

import RxSwift

protocol UserDefaultService {
    func fetch(type: OptionKeyType) -> Int
    func update(type: OptionKeyType, index: Int) -> Int
}

final class DefaultUserDefaultService: UserDefaultService {
    
    private let storage = UserDefaults.standard
    
    func fetch(type: OptionKeyType) -> Int {
        return storage.integer(forKey: type.key)
    }
    
    func update(type: OptionKeyType, index: Int) -> Int {
        storage.set(index, forKey: type.key)
        return fetch(type: type)
    }
}
