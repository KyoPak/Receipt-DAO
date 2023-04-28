//
//  Receipt.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import Foundation

struct Receipt {
    var store: String           // 상호명
    var price: Double           // 가격
    var product: String         // 구매 상품
    var receiptDate: Date       // 영수증 구매 날짜
    var paymentType: PayType    // 구매 방법
    var receiptData: Data?      // 영수증 이미지 데이터
    
    init(
        store: String = "",
        price: Double = .zero,
        product: String = "",
        receiptDate: Date = Date(),
        paymentType: PayType = .card,
        receiptData: Data? = nil
    ) {
        self.store = store
        self.price = price
        self.product = product
        self.receiptDate = receiptDate
        self.paymentType = paymentType
        self.receiptData = receiptData
    }
}
