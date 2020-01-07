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
    
    enum NoteFilter {
        
        case word(_ string: String)
        
        case category(code: Int16)
        
        var predicate: (String, Any) {
            switch self {
            case .word(let mWord):
                return ("title = %@", mWord)
            case .category(let code):
                return ("category_code = %@", code)
            }
        }
        
    }
    
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
        noteModel.categoryCode = self.category_code
        
        return noteModel
    }
    
    class func getNotes(_ filters: [NoteFilter]? = nil, offset: Int = 0) -> [NoteModel]? {
        let context = CoreDataManager.shared.managedObjectContext
        let request = NSFetchRequest<NoteEntity>()
        request.entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
        request.sortDescriptors = [NSSortDescriptor(key: "time", ascending: false)]
        request.fetchLimit = 20
        request.fetchOffset = offset
        
        if let filters = filters, filters.count > 0 {
            let fmts = filters.map { $0.predicate.0 }.joined(separator: "&&")
            let vals = filters.map { $0.predicate.1 }
            request.predicate = NSPredicate(format: fmts, argumentArray: vals)
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
    
    class func update(note aNote: NoteModel, config: (NoteEntity) -> ()) {
        guard let objId = aNote.mObjectId else {
            return
        }
        let context = CoreDataManager.shared.managedObjectContext
        let entity = context.object(with: objId) as! NoteEntity
        config(entity)
        CoreDataManager.shared.saveContext()
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
