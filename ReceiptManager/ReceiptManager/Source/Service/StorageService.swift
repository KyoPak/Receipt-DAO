//
//  StorageService.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import CoreData

import FirebaseCrashlytics
import RxSwift
import RxCoreData

protocol StorageService {
    var updateEvent: PublishSubject<Receipt> { get }
    
    func sync()
    
    @discardableResult
    func upsert(receipt: Receipt) -> Observable<Receipt>
    
    @discardableResult
    func fetch() -> Observable<[Receipt]>
    
    @discardableResult
    func delete(receipt: Receipt) -> Observable<Receipt>
}

final class DefaultStorageService: StorageService {
    
    // Core Data Stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
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
    
    // Properties
    
    private let modelName: String
    private let disposeBag = DisposeBag()
    let updateEvent: PublishSubject<Receipt>
    
    init(modelName: String) {
        self.modelName = modelName
        updateEvent = PublishSubject()
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
    
    func fetch() -> Observable<[Receipt]> {
        return mainContext.rx.entities(
            Receipt.self,
            sortDescriptors: [NSSortDescriptor(key: "receiptDate", ascending: false)]
        )
    }
    
    @discardableResult
    func upsert(receipt: Receipt) -> Observable<Receipt> {
        updateEvent.onNext(receipt)
        do {
            try mainContext.rx.update(receipt)
            return Observable.just(receipt)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return Observable.error(StorageServiceError.entityUpdateError)
        }
    }
    
    @discardableResult
    func delete(receipt: Receipt) -> Observable<Receipt> {
        do {
            try mainContext.rx.delete(receipt)
            return Observable.just(receipt)
        } catch {
            Crashlytics.crashlytics().record(error: error)
            return Observable.error(StorageServiceError.entityDeleteError)
        }
    }
}
