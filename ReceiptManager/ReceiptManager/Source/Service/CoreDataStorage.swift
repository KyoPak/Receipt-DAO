//
//  CoreDataStorage.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import CoreData
import RxSwift
import RxCoreData

enum FetchType {
    case day
    case month
}

final class CoreDataStorage: ReceiptStorage {
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private let modelName: String
    private let disposeBag = DisposeBag()
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    func sync() {
        return mainContext.rx.entities(
            Receipt.self, sortDescriptors: [NSSortDescriptor(key: "receiptDate", ascending: false)]
        )
        .take(1)
        .subscribe(onNext: { result in
            for data in result {
                if data.price == -1 { continue }
                
                var syncReceipt = data
                syncReceipt.priceText = String(syncReceipt.price)
                syncReceipt.price = -1
                self.upsert(receipt: syncReceipt)
            }
        })
        .disposed(by: disposeBag)
    }
    
    @discardableResult
    func upsert(receipt: Receipt) -> Observable<Receipt> {
        do {
            try mainContext.rx.update(receipt)
            return Observable.just(receipt)
        } catch {
            return Observable.error(error)
        }
    }
    
    func fetch(type: FetchType) -> Observable<[ReceiptSectionModel]> {
        return mainContext.rx.entities(
            Receipt.self,
            sortDescriptors: [NSSortDescriptor(key: "receiptDate", ascending: false)]
        )
        .map { result in
            var dayFormat = ConstantText.dateFormatDay.localize()
            if type == .month { dayFormat = ConstantText.dateFormatMonth.localize() }
            
            let dictionary = Dictionary(
                grouping: result,
                by: { DateFormatter.string(from: $0.receiptDate, dayFormat) }
            )
            
            let section = dictionary.sorted { return $0.key > $1.key }
                .map { (key, value) in
                    return ReceiptSectionModel(model: key, items: value)
                }
            
            return section
        }
    }

    @discardableResult
    func delete(receipt: Receipt) -> Observable<Receipt> {
        do {
            try mainContext.rx.delete(receipt)
            return Observable.just(receipt)
        } catch {
            return Observable.error(error)
        }
    }
}
