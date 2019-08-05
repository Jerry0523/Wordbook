//
//  NetworkManager.swift
//  Wordbook
//
//  Created by Jerry on 16/4/15.
//  Copyright © 2016年 Jerry Wong. All rights reserved.
//

import UIKit
import CommonCrypto

class NetworkManager {
    
    static let shared = { return NetworkManager() }()
    
    func httpRequest(_ request: URLRequest, completionHandler: @escaping (Any?, Error?) -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var jsonObj: Any?
            if data != nil && error == nil {
                do {
                    try jsonObj = JSONSerialization.jsonObject(with: data!, options: .mutableLeaves)
                } catch {
                    
                }
            }
            DispatchQueue.main.async {
                completionHandler(jsonObj, error)
            }
        }
        task.resume()
    }
    
    func httpDownLoad(url: String, completionHandler: @escaping (Data?, Error?) -> Void) {
        let session = URLSession.shared
        let task = session.downloadTask(with: URL(string: url)!) { url, response, error in
            var data: Data?
            if error == nil && url != nil {
                data = try? Data(contentsOf: url!)
            }
            DispatchQueue.main.async {
                completionHandler(data, error)
            }
        }
        task.resume()
    }
}

extension String {
    var md5String: String {
        let str = cString(using: .utf8)
        let strLen = CC_LONG(lengthOfBytes(using: .utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate()
        
        return String(format: hash as String)
    }
    
    var urlEncodeString: String? {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
