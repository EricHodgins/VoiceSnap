//
//  Record.swift
//  VoiceSnap
//
//  Created by Eric Hodgins on 2016-10-12.
//  Copyright © 2016 Eric Hodgins. All rights reserved.
//

import UIKit
import CoreData

class Record: NSManagedObject {
    static let entityName = "\(Record.self)"
    
    class func record(withName name: String) -> Record {
        let record = NSEntityDescription.insertNewObject(forEntityName: Record.entityName, into: CoreDataController.sharedInstance.managedObjectContext) as! Record
        record.name = name
        
        return record
    }
    
    class func allRecordsFetchRequest() -> NSFetchRequest<Record> {
        let fetchRequest = NSFetchRequest<Record>(entityName: Record.entityName)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return fetchRequest
    }
}

// MARK: - Helper
extension Record {
    func URLToDocumentsDirectory(withFileName name: String) -> URL {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recordURL = documentsDirectoryURL.appendingPathComponent("\(name).m4a")
        
        return recordURL
    }
}

extension Record {
    @NSManaged var name: String
}
