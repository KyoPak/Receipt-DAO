//
//  MockUserDefaultService.swift
//  ReactorTests
//
//  Created by parkhyo on 12/13/23.
//

import RxSwift
@testable import ReceiptManager

final class MockUserDefaultService: UserDefaultService {
    private var dict: [OptionKeyType: Int] = [.currency: .zero, .payment: .zero, .displayMode: .zero]
    
    func fetch(type: OptionKeyType) -> Int {
        return dict[type]!
    }
    
    func update(type: OptionKeyType, index: Int) -> Int {
        dict[type] = index
        return dict[type]!
    }
}
