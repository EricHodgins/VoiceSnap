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
    
    class func allRecordsFetchRequest() {
        
    }
}

extension Record {
    @NSManaged var name: String
}
