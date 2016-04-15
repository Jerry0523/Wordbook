//
//  Note.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import Foundation
import CoreData


class Note: NSManagedObject {
    
    class func getNotes(word :String?) -> [Note]? {
        let context = CoreDataManager.sharedInstance.managedObjectContext
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Note", inManagedObjectContext: context)
        
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
        
        if word?.characters.count > 0 {
            request.predicate = NSPredicate(format: "title = %@", word!)
        }
        
        var objs :[Note]?
        do {
            objs = try context.executeFetchRequest(request) as? [Note]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        return objs
    }

    class func addNote(word :String, definition :String) -> Bool {
        let context = CoreDataManager.sharedInstance.managedObjectContext
        let note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: context) as! Note
        
        note.type = 0
        note.title = word
        note.definition = definition
        note.time = NSDate()
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            return false
        }
        return true
    }
    
    

}
