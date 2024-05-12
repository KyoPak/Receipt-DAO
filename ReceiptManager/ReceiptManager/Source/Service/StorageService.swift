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

enum SyncStatus: Int {
    case notStarted
    case complete
}

protocol StorageService {
    func dataSync() -> Observable<Void>
    func fetch() -> Observable<[Receipt]>
    func delete(receipt: Receipt) -> Observable<Receipt>
    
    @discardableResult
    func upsert(receipt: Receipt) -> Observable<Receipt>
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
    
    private lazy var context: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        return context
    }()
    
    // Properties
    
    private let modelName: String
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    func dataSync() -> Observable<Void> {
        return context.rx.entities(
            Receipt.self, sortDescriptors: [NSSortDescriptor(key: "receiptDate", ascending: false)]
        )
        .take(1)
        .map { [weak self] datas in
            for data in datas {
                if data.price == -1 { continue }
                
                var syncReceipt = data
                syncReceipt.priceText = String(syncReceipt.price)
                syncReceipt.price = -1
                self?.upsert(receipt: syncReceipt)
            }
        }
    }
    
    func fetch() -> Observable<[Receipt]> {
        return context.rx.entities(
            Receipt.self,
            sortDescriptors: [NSSortDescriptor(key: "receiptDate", ascending: false)]
        )
    }
    
    @discardableResult
    func upsert(receipt: Receipt) -> Observable<Receipt> {
        return Observable.create { [weak self] observer in
            self?.context.perform {
                do {
                    try self?.context.rx.update(receipt)
                    observer.onNext(receipt)
                    observer.onCompleted()
                } catch {
                    Crashlytics.crashlytics().record(error: error)
                    observer.onError(StorageServiceError.entityUpdateError)
                }
            }
            return Disposables.create()
        }
    }
    
    func delete(receipt: Receipt) -> Observable<Receipt> {
        return Observable.create { [weak self] observer in
            self?.context.perform {
                do {
                    try self?.context.rx.delete(receipt)
                    observer.onNext(receipt)
                    observer.onCompleted()
                } catch {
                    Crashlytics.crashlytics().record(error: error)
                    observer.onError(StorageServiceError.entityDeleteError)
                }
            }
            return Disposables.create()
        }
    }
}
