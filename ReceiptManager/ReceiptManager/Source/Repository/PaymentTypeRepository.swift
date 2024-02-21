//
//  PaymentTypeRepository.swift
//  ReceiptManager
//
//  Created by parkhyo on 2/17/24.
//

import Foundation

protocol PaymentTypeRepository {
    func fetchPaymentTypeIndex() -> Int
    func updatePaymentType(index: Int) -> Int
}

final class DefaultPaymentTypeRepository: PaymentTypeRepository {
    private let service: UserDefaultService
    
    init(service: UserDefaultService) {
        self.service = service
    }
    
    func fetchPaymentTypeIndex() -> Int {
        return service.fetch(type: .payment)
    }
    
    func updatePaymentType(index: Int) -> Int {
        return service.update(type: .payment, index: index)
    }
}
