//
//  CoreDataService.swift
//  CheckListApp
//
//  Created by Anton Kolesnikov on 23.11.2022.
//

import Foundation
import CoreData

final class CoreDataService {
    
    lazy private var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ChecklistModel")
        container.loadPersistentStores { _, error in
            //Handle error
        }
        
        return container
    }()
    
    private var context: NSManagedObjectContext { container.viewContext }
    
    private(set) static var shared: CoreDataService = .init()
    
    @discardableResult
    func create<T: NSManagedObject>(_ type: T.Type, _ handler: ((T) -> ())? = nil) -> T {
        let newObject = T(context: context)
        handler?(newObject)
        return newObject
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        
        try? context.save()
    }
    
    func write(_ handler: () -> ()) {
        handler()
        saveContext()
    }
    
    func fetch<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate?) -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: "Item")
        fetchRequest.predicate = predicate
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    
}
