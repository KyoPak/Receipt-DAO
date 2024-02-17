//
//  UserDefaultService.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/26/23.
//

import RxSwift

protocol UserDefaultService {
    func fetch(key: OptionKeyType) -> Int
    func update(key: OptionKeyType, index: Int) -> Int
}

final class DefaultUserDefaultService: UserDefaultService {
    
    private let storage = UserDefaults.standard
    
    func fetch(key: OptionKeyType) -> Int {
        return storage.integer(forKey: key.description)
    }
    
    func update(key: OptionKeyType, index: Int) -> Int {
        storage.set(index, forKey: key.description)
        return fetch(key: key)
    }
}
