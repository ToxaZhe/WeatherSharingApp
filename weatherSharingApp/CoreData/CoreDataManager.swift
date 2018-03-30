//
//  CoreDataManager.swift
//  weatherSharingApp
//
//  Created by user on 3/7/18.
//  Copyright © 2018 Toxa. All rights reserved.
//

import Foundation
import CoreData

let coreDataManager: CoreDataManager = {
    return CoreDataManager.getSharedInstance()
}()

class CoreDataManager {
    
    class func getSharedInstance() -> CoreDataManager {
        return CoreDataManager()
    }

    lazy var fetchedResultsController: NSFetchedResultsController<User> = { [unowned self] in
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: User.sortedFetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsController
        
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "weatherSharingApp")
        container.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error as NSError? {
                print("Unable to Load Persistent Store")
                fatalError("\(error), \(error.localizedDescription)")
            }
        }
        return container
    }()

    
    func performFetch() throws {
        try fetchedResultsController.performFetch()
    }
    
    func saveMOC() throws {
        
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try persistentContainer.viewContext.save()
        }
        
    }
    
}
