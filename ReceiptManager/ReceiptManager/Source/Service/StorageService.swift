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
    func sync()
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
    private let disposeBag = DisposeBag()
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    func sync() {
        return context.rx.entities(
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
