//
//  RecordDataSource.swift
//  VoiceSnap
//
//  Created by Eric Hodgins on 2016-10-13.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import CoreData

class RecordDataSource: NSObject {
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

// MARK - UICollectionViewDataSource

extension RecordDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        
        return section.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecordCell.reuseIdentifier, for: indexPath) as! RecordCell
        
        let record = fetchedResultsController.object(at: indexPath)
        cell.recordingName.text = record.name
        
        return cell
    }
}
