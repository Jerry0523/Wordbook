//
//  NetworkManager+BaiduTranslate.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import Foundation

extension NetworkManager {
    
    func requestWordTranslation(word: String, completionHandler: (AnyObject?, NSError?) -> Void) {
        let stringToBeSigned = bAppId + word + bSalt + bKey
        let md5SignedString = stringToBeSigned.md5String
        
        let urlString = bURL + "?q=" + word + "&from=auto&to=zh&appid=" + bAppId + "&salt=" + bSalt + "&sign=" + md5SignedString
        let escapedUrlString = urlString.urlEncodeString!
        
        let request = NSMutableURLRequest(URL: NSURL(string: escapedUrlString)!)
        self.httpRequest(request) { (item: AnyObject?, error :NSError?) in
            completionHandler(item, error)
        }
    }
}