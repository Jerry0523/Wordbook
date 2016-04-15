//
//  NetworkManager.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit

class NetworkManager {
    
    let bAppId = "20160413000018680"
    let bSalt = "1562390194"
    let bKey = "NUizRIY94ihYqYX70hy1"
    let bURL = "http://api.fanyi.baidu.com/api/trans/vip/translate"
    
    class var sharedInstance : NetworkManager {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : NetworkManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = NetworkManager()
        }
        return Static.instance!
    }
    
    func httpRequest(request: NSURLRequest, completionHandler: (AnyObject?, NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) in
            var jsonObj: AnyObject?
            if data != nil && error == nil {
                do {
                    try jsonObj = NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves)
                } catch {
                    
                }
            }
            completionHandler(jsonObj, error)
        }
        task.resume()
    }
}

extension String {
    var md5String :String {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.dealloc(digestLen)
        
        return String(format: hash as String)
    }
    
    var urlEncodeString :String? {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    }
}
