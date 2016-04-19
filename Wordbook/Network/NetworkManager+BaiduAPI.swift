//
//  NetworkManager+BaiduAPI.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import Foundation

extension NetworkManager {
    
    func requestWordTranslation(word: String, completionHandler: (AnyObject?, NSError?) -> Void) {
        let stringToBeSigned = NetworkAPIConst.bAppId + word + NetworkAPIConst.bSalt + NetworkAPIConst.bKey
        let md5SignedString = stringToBeSigned.md5String
        
        let urlString = NetworkAPIConst.bURL + "?q=" + word + "&from=auto&to=zh&appid=" + NetworkAPIConst.bAppId + "&salt=" + NetworkAPIConst.bSalt + "&sign=" + md5SignedString
        let escapedUrlString = urlString.urlEncodeString!
        
        let request = NSMutableURLRequest(URL: NSURL(string: escapedUrlString)!)
        self.httpRequest(request) { (item: AnyObject?, error :NSError?) in
            completionHandler(item, error)
        }
    }
}