//
//  NetworkManager.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit

class NetworkManager {
    
    class var sharedInstance: NetworkManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: NetworkManager? = nil
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
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(jsonObj, error)
            })
        }
        task.resume()
    }
    
    func httpDownLoad(url: String, completionHandler: (NSData?, NSError?) -> Void) {
        let session = NSURLSession.sharedSession()
        let task = session.downloadTaskWithURL(NSURL(string: url)!) { (url: NSURL?, response: NSURLResponse?, error: NSError?) in
            var data: NSData?
            if error == nil && url != nil {
                data = NSData(contentsOfURL: url!)
            }
            dispatch_async(dispatch_get_main_queue(), {
                completionHandler(data, error)
            })
        }
        task.resume()
    }
}

extension String {
    var md5String: String {
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
    
    var urlEncodeString: String? {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    }
}
