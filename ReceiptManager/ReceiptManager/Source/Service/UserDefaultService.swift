//
//  UserDefaultService.swift
//  ReceiptManager
//
//  Created by parkhyo on 11/26/23.
//

import RxSwift

protocol UserDefaultService {
    func fetch(type: OptionKeyType) -> Int
    
    @discardableResult
    func update(type: OptionKeyType, index: Int) -> Int
}

final class DefaultUserDefaultService: UserDefaultService {
    
    private let storage = UserDefaults.standard
    
    func fetch(type: OptionKeyType) -> Int {
        return storage.integer(forKey: type.key)
    }
    
    @discardableResult
    func update(type: OptionKeyType, index: Int) -> Int {
        postNotification(type: type, index: index)
        storage.set(index, forKey: type.key)
        return fetch(type: type)
    }
}

extension DefaultUserDefaultService {
    private func postNotification(type: OptionKeyType, index: Int) {
        guard type == .displayMode else { return }
        
        NotificationCenter.default.post(
            name: .displayModeNotification,
            object: nil,
            userInfo: [ConstantKey.displayModeKey: index]
        )
    }
}
