//
//  NoteModel.swift
//  Wordbook
//
//  Created by Jerry on 16/4/20.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import Foundation
import CoreData

class NoteModel {
    
    var title: String?
    
    var definition: String?
    
    var pronunciation: String?
    var audioURL: String?
    var audioData: NSData?
    
    var enDefinition: Dictionary<String, [String]>?
    
    var mTag :NSNumber?
    
    var mEnDefinitionString: String?
    
    var mObjectId: NSManagedObjectID?
    
    func getEnDefinitionString() -> String? {
        if mEnDefinitionString != nil {
            return mEnDefinitionString
        }
        
        if enDefinition == nil {
            return nil
        }
        
        var result = ""
        
        
        for (key,value) in enDefinition! {
            if result.characters.count > 0 {
                result += "\n"
            }
            result += "\(key). "
            for line in value {
                result += line
            }
        }
        
        if result.characters.count == 0 {
            return nil
        }
        
        mEnDefinitionString = result
        
        return mEnDefinitionString
    }
    
    func checkAndDownloadSoundFile(completionHandler: () -> Void) {
        if self.audioURL != nil && self.audioData == nil {
            NetworkManager.sharedInstance.httpDownLoad(self.audioURL!, completionHandler: {[weak self] (data: NSData?, error: NSError?) in
                if data != nil {
                    self?.audioData = data
                    completionHandler()
                }
            })
        }
    }
}