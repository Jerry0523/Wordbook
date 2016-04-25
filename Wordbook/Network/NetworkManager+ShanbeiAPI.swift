//
//  NetworkManager+ShanbeiAPI.swift
//  Wordbook
//
//  Created by Jerry on 16/4/20.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import Foundation

extension NetworkManager {
    
    func requestShanbeiTranslate(word: String, completionHandler: (NoteModel?, NSError?) -> Void) {
        let urlString = NetworkAPIConst.shanbeiURL + "?word=" + word
        let escapedUrlString = urlString.urlEncodeString!
        
        let request = NSMutableURLRequest(URL: NSURL(string: escapedUrlString)!)
        request.HTTPMethod = "GET"
        
        self.httpRequest(request) { [weak self] (item: AnyObject?, error :NSError?) in
            var anError = error
            var note :NoteModel?
            
            if error == nil && item != nil {
                let itemDict = item as! Dictionary<String, AnyObject>
                
                let errorCode = itemDict["status_code"] as? String
                anError = self?.translateShanbeiErrorCode(errorCode)
                if anError == nil {
                    let dataDict = itemDict["data"] as? Dictionary<String, AnyObject>
                    if dataDict != nil && !dataDict!.isEmpty {
                        note = NoteModel()
                        note?.title = word
                        note?.definition = (dataDict!["definition"] as? String)?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                        note?.enDefinition = dataDict!["en_definitions"] as? Dictionary<String, [String]>
                        
                        note?.pronunciation = dataDict!["pronunciation"] as? String
                        note?.audioURL = dataDict!["audio"] as? String
                    }
                }
            }
            
            if note == nil && anError == nil {
                anError = NSError(domain: NetworkAPIConst.bAPIErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey:"Unexpected Error"])
            }
            
            completionHandler(note, anError)
        }
    }
        
    func translateShanbeiErrorCode(errorCode: String?) -> NSError? {
        var msg: String?
        if errorCode == "400" {
            msg = "Parameter error"
        } else if errorCode == "401" {
            msg = "Unauthorrzed user"
        } else if errorCode == "404" {
            msg = "Resource not found"
        } else if errorCode == "409" {
            msg = "Duplicated creation"
        } else if errorCode == "1" {
            msg = "Server error"
        }
        
        if msg == nil {
            return nil
        }
        
        return NSError(domain: NetworkAPIConst.shanbeiErrorDomain, code: Int(errorCode!)!, userInfo: [NSLocalizedDescriptionKey:msg!])
    }
    
}