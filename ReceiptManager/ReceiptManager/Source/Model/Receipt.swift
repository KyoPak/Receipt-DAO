//
//  Receipt.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import CoreData
import RxDataSources
import RxSwift
import RxCoreData

struct Receipt: Hashable, IdentifiableType {
    var identity: String    // 구분자
    
    var store: String           // 상호명
    var price: Int              // 가격
    var priceText: String
    var product: String         // 구매 상품
    var receiptDate: Date       // 영수증 구매 날짜
    var paymentType: Int        // 구매 방법
    var receiptData: [Data]      // 영수증 이미지 데이터
    var memo: String            // 메모
    var isFavorite: Bool
    
    init(
        store: String = "",
        price: Int = -1,        // 미사용될 가격
        priceText: String = "",
        product: String = "",
        receiptDate: Date = Date(),
        paymentType: Int = .zero,
        receiptData: [Data] = [],
        memo: String = "",
        isFavorite: Bool = false
    ) {
        self.identity = UUID().description   // 구분자
        self.store = store
        self.price = price
        self.priceText = priceText
        self.product = product
        self.receiptDate = receiptDate
        self.paymentType = paymentType
        self.receiptData = receiptData
        self.memo = memo
        self.isFavorite = isFavorite
    }
}

extension Receipt: Persistable {
    static var entityName: String {
        return "Receipt"
    }
    
    static var primaryAttributeName: String {
        return "identity"
    }
    
    init(entity: NSManagedObject) {
        identity = entity.value(forKey: "identity") as? String ?? UUID().description
        store = entity.value(forKey: "store") as? String ?? ""
        price = entity.value(forKey: "price") as? Int ?? -1
        priceText = entity.value(forKey: "priceText") as? String ?? ""
        product = entity.value(forKey: "product") as? String ?? ""
        receiptDate = entity.value(forKey: "receiptDate") as? Date ?? Date()
        paymentType = entity.value(forKey: "paymentType") as? Int ?? .zero
        receiptData = entity.value(forKey: "receiptData") as? [Data] ?? []
        memo = entity.value(forKey: "memo") as? String ?? ""
        isFavorite = entity.value(forKey: "isFavorite") as? Bool ?? false
    }
    
    func update(_ entity: NSManagedObject) {
        entity.setValue(identity, forKey: "identity")
        entity.setValue(store, forKey: "store")
        entity.setValue(price, forKey: "price")
        entity.setValue(priceText, forKey: "priceText")
        entity.setValue(product, forKey: "product")
        entity.setValue(receiptDate, forKey: "receiptDate")
        entity.setValue(paymentType, forKey: "paymentType")
        entity.setValue(receiptData, forKey: "receiptData")
        entity.setValue(memo, forKey: "memo")
        entity.setValue(isFavorite, forKey: "isFavorite")
        
        do {
            try entity.managedObjectContext?.save()
        } catch {
            print(error)
        }
    }
}
