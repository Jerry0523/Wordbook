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
    var audioData: Data?
    
    var enDefinition: Dictionary<String, [String]>?
    
    var mTag :NSNumber?
    
    var mEnDefinitionString: String?
    
    var mObjectId: NSManagedObjectID?
    
    var categoryCode: Int16?
    
    func getEnDefinitionString() -> String? {
        if mEnDefinitionString != nil {
            return mEnDefinitionString
        }
        
        if enDefinition == nil {
            return nil
        }
        
        var result = ""
        
        
        for (key,value) in enDefinition! {
            if result.count > 0 {
                result += "\n"
            }
            result += "\(key). "
            for line in value {
                result += line
            }
        }
        
        if result.count == 0 {
            return nil
        }
        
        mEnDefinitionString = result
        
        return mEnDefinitionString
    }
    
    func checkAndDownloadSoundFile(completionHandler: @escaping () -> Void) {
        if self.audioData != nil {
            completionHandler()
        } else if self.audioURL != nil && self.audioData == nil {
            NetworkManager.shared.httpDownLoad(url: self.audioURL!, completionHandler: {[weak self] (data: Data?, error: Error?) in
                if data != nil {
                    self?.audioData = data!
                    completionHandler()
                }
            })
        }
    }
}
