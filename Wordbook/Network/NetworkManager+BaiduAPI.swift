//
//  NetworkManager+BaiduAPI.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import Foundation

extension NetworkManager {
    
    func requestBaiduTranslate(word: String, completionHandler: (NoteModel?, NSError?) -> Void) {
        let stringToBeSigned = NetworkAPIConst.bAppId + word + NetworkAPIConst.bSalt + NetworkAPIConst.bKey
        let md5SignedString = stringToBeSigned.md5String
        
        let urlString = NetworkAPIConst.bURL + "?q=" + word + "&from=auto&to=zh&appid=" + NetworkAPIConst.bAppId + "&salt=" + NetworkAPIConst.bSalt + "&sign=" + md5SignedString
        let escapedUrlString = urlString.urlEncodeString!
        
        let request = NSMutableURLRequest(URL: NSURL(string: escapedUrlString)!)
        self.httpRequest(request) { [weak self] (item: AnyObject?, error :NSError?) in
            var anError = error
            var note :NoteModel?
            
            if error == nil && item != nil {
                let itemDict = item as! Dictionary<String, AnyObject>
                
                let errorCode = itemDict["error_code"] as? String
                if errorCode != nil {
                    anError = self?.translateBaiduErrorCode(errorCode)
                } else {
                    let translationsArray = itemDict["trans_result"] as! Array<Dictionary<String, String>>
                    if translationsArray.count > 0 {
                        let translationDict = translationsArray[0]
                        let translatedValue = translationDict["dst"]
                        if translatedValue?.characters.count > 0 {
                            note = NoteModel()
                            note!.title = word
                            note!.definition = translatedValue
                        }
                    }
                }
            }
            
            if note == nil && anError == nil {
                anError = NSError(domain: NetworkAPIConst.bAPIErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey:"Unexpected Error"])
            }
            
            completionHandler(note, anError)
        }
    }
    
    func translateBaiduErrorCode(errorCode: String?) -> NSError? {
        var msg: String?
        if errorCode == "52001" {
            msg = "Request time out"
        } else if errorCode == "52002" {
            msg = "System error"
        } else if errorCode == "52003" {
            msg = "Unauthorrzed user"
        } else if errorCode == "54000" {
            msg = "Parameter error"
        } else if errorCode == "58000" {
            msg = "Illegal error"
        } else if errorCode == "54001" {
            msg = "Signature error"
        } else if errorCode == "54003" || errorCode == "54005"{
            msg = "Request too frequently"
        } else if errorCode == "58001" {
            msg = "Unsupported language"
        } else if errorCode == "54004" {
            msg = "Credit is running low"
        }
        
        if msg == nil {
            return nil
        }
        
        return NSError(domain: NetworkAPIConst.bAPIErrorDomain, code: Int(errorCode!)!, userInfo: [NSLocalizedDescriptionKey:msg!])
    }
}