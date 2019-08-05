//
//  NetworkManager+ShanbeiAPI.swift
//  Wordbook
//
//  Created by Jerry on 16/4/20.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import Foundation

extension NetworkManager {
    
    func requestShanbeiTranslate(_ word: String, completionHandler: @escaping (NoteModel?, Error?) -> Void) {
        let urlString = NetworkAPIConst.shanbeiURL + "?word=" + word
        let escapedUrlString = urlString.urlEncodeString!
        
        var request = URLRequest(url: URL(string: escapedUrlString)!)
        request.httpMethod = "GET"
        
        self.httpRequest(request) { [weak self] (item: Any?, error :Error?) in
            var anError = error
            var note :NoteModel?
            
            if let itemDict = item as? [String: Any] {
                let errorCode = itemDict["status_code"] as? String
                anError = self?.translateShanbeiErrorCode(errorCode)
                if anError == nil {
                    if let dataDict = itemDict["data"] as? Dictionary<String, AnyObject>, !dataDict.isEmpty {
                        note = NoteModel()
                        note?.title = word
                        note?.definition = (dataDict["definition"] as? String)?.trimmingCharacters(in: .whitespaces)
                        note?.enDefinition = dataDict["en_definitions"] as? Dictionary<String, [String]>
                        note?.pronunciation = dataDict["pronunciation"] as? String
                        note?.audioURL = dataDict["audio"] as? String
                    }
                }
            }
            
            if note == nil && anError == nil {
                anError = NSError(domain: NetworkAPIConst.bAPIErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey:"Unexpected Error"])
            }
            
            completionHandler(note, anError)
        }
    }
        
    func translateShanbeiErrorCode(_ errorCode: String?) -> Error? {
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
