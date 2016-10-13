//
//  RecordDataSource.swift
//  VoiceSnap
//
//  Created by Eric Hodgins on 2016-10-13.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import CoreData

class RecordDataSource {
    let collectionView: UICollectionView
    let managedObjectContext = CoreDataController.sharedInstance.managedObjectContext
    let fetchedResultsController: NSFetchedResultsController<Record>
    
    init(fetchRequest: NSFetchRequest<Record>, collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    func executeFetch() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("Error fetching records.")
        }
    }
}
