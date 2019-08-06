//
//  NoteEntity.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import Foundation
import CoreData

extension NoteEntity {
    
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
    
    class func getNotes(_ word: String? = nil) -> [NoteModel]? {
        let context = CoreDataManager.shared.managedObjectContext
        let request = NSFetchRequest<NoteEntity>()
        request.entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
        
        if (word?.count ?? 0) > 0 {
            request.predicate = NSPredicate(format: "title = %@", word!)
        }
        
        var objs: [NoteEntity]?
        do {
            objs = try context.fetch(request)
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

    class func insert(note aNote: NoteModel) {
        let context = CoreDataManager.shared.managedObjectContext
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: context) as! NoteEntity
        
        note.type = 0
        note.time = Date()
        
        note.title = aNote.title
        note.definition = aNote.definition
        note.pronunciation = aNote.pronunciation
        
        note.enDefinition = aNote.getEnDefinitionString()
        note.audioUrl = aNote.audioURL
        note.audio = aNote.audioData
        note.tag = aNote.mTag
        
        note.checkAndDownloadSoundFile()
        
        CoreDataManager.shared.saveContext()
    }
    
    class func deleteNote(_ noteModel: NoteModel) {
        let context = CoreDataManager.shared.managedObjectContext
        if noteModel.mObjectId != nil {
            let note = context.object(with: noteModel.mObjectId!)
            context.delete(note)
            CoreDataManager.shared.saveContext()
        }
    }
    
    private func checkAndDownloadSoundFile() {
        if self.audioUrl != nil && self.audio == nil {
            NetworkManager.shared.httpDownLoad(url: self.audioUrl!, completionHandler: {[weak self] (data: Data?, error: Error?) in
                if data != nil {
                    self?.audio = data!
                    CoreDataManager.shared.saveContext()
                }
            })
        }
    }
}
