//
//  CoreDataStorage.swift
//  ReceiptManager
//
//  Created by parkhyo on 2023/04/28.
//

import Foundation
import CoreData
import RxSwift
import RxCoreData

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
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    func upsert(receipt: Receipt) -> Observable<Receipt> {
        
        do {
            try mainContext.rx.update(receipt)
            return Observable.just(receipt)
        } catch {
            return Observable.error(error)
        }
    }
    
    func fetch() -> Observable<[ReceiptSectionModel]> {
        return mainContext.rx.entities(
            Receipt.self,
            sortDescriptors: [NSSortDescriptor(key: "receiptDate", ascending: false)]
        )
        .map { result in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy년 MM월 dd일"
            
            let dictionary = Dictionary(grouping: result, by: {
                dateFormatter.string(from: $0.receiptDate)
            })
            
            let section = dictionary.sorted { return $0.key > $1.key }
                .map { (key, value) in
                    return ReceiptSectionModel(model: key, items: value)
                }
            
            return section
        }
    }
    
    func delete(receipt: Receipt) -> Observable<Receipt> {
        do {
            try mainContext.rx.delete(receipt)
            return Observable.just(receipt)
        } catch {
            return Observable.error(error)
        }
    }
}
