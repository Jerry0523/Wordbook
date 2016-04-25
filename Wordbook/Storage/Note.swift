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
    
    func toNoteModel() ->NoteModel {
        let noteModel = NoteModel()
        
        noteModel.title = self.title
        noteModel.definition = self.definition
        noteModel.pronunciation = self.pronunciation
        noteModel.audioURL = self.audioUrl
        noteModel.audioData = self.audio
        
        noteModel.mEnDefinitionString = self.enDefinition
        noteModel.mObjectId = self.objectID
        noteModel.mTag = self.tag
        
        return noteModel
    }
    
    class func getNotes(word: String?) -> [NoteModel]? {
        let context = CoreDataManager.sharedInstance().managedObjectContext
        let request = NSFetchRequest()
        request.entity = NSEntityDescription.entityForName("Note", inManagedObjectContext: context)
        
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
        
        if word?.characters.count > 0 {
            request.predicate = NSPredicate(format: "title = %@", word!)
        }
        
        var objs: [Note]?
        do {
            objs = try context.executeFetchRequest(request) as? [Note]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        var result: [NoteModel] = []
        if objs != nil {
            for note in objs! {
                result.append(note.toNoteModel())
            }
        }
        
        return result
    }

    class func insertNote(aNote: NoteModel) {
        let context = CoreDataManager.sharedInstance().managedObjectContext
        let note = NSEntityDescription.insertNewObjectForEntityForName("Note", inManagedObjectContext: context) as! Note
        
        note.type = 0
        note.time = NSDate()
        
        note.title = aNote.title
        note.definition = aNote.definition
        note.pronunciation = aNote.pronunciation
        
        note.enDefinition = aNote.getEnDefinitionString()
        note.audioUrl = aNote.audioURL
        note.audio = aNote.audioData
        note.tag = aNote.mTag
        
        note.checkAndDownloadSoundFile()
        
        CoreDataManager.sharedInstance().saveContext()
    }
    
    class func deleteNote(noteModel: NoteModel) {
        let context = CoreDataManager.sharedInstance().managedObjectContext
        if noteModel.mObjectId != nil {
            let note = context.objectWithID(noteModel.mObjectId!)
            context.deleteObject(note)
            CoreDataManager.sharedInstance().saveContext()
        }
    }
    
    private func checkAndDownloadSoundFile() {
        if self.audioUrl != nil && self.audio == nil {
            NetworkManager.sharedInstance.httpDownLoad(self.audioUrl!, completionHandler: {[weak self] (data: NSData?, error: NSError?) in
                if data != nil {
                    self?.audio = data
                    CoreDataManager.sharedInstance().saveContext()
                }
                })
        }
    }
}
