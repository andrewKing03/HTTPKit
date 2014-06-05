//////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HTTPRequestSerializer.swift
//
//  Created by Dalton Cherry on 6/3/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////////////////////////////

import Foundation

extension String {
    
    func escapeStr() -> String {
        var raw: NSString = self
        var str = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,raw,"[].",":/?&=;+!@#$()',*",CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding))
        return str
    }
}

class HTTPRequestSerializer: NSObject {
    
    var stringEncoding = NSUTF8StringEncoding
    var allowsCellularAccess = true
    var HTTPShouldHandleCookies = true
    var HTTPShouldUsePipelining = false
    var timeoutInterval: NSTimeInterval = 60
    var cachePolicy: NSURLRequestCachePolicy = NSURLRequestCachePolicy.UseProtocolCachePolicy
    var networkServiceType = NSURLRequestNetworkServiceType.NetworkServiceTypeDefault
    let contentTypeKey = "Content-Type"
    
    init() {
        super.init()
    }
    
    ///creates a request from the url, HTTPMethod, and parameters
    func createRequest(url: NSURL, method: HTTPMethod, parameters: Dictionary<String,AnyObject>?) -> NSURLRequest {
        var request = NSMutableURLRequest(URL: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.HTTPMethod = method.toRaw()
        request.allowsCellularAccess = self.allowsCellularAccess
        request.HTTPShouldHandleCookies = self.HTTPShouldHandleCookies
        request.HTTPShouldHandleCookies = self.HTTPShouldUsePipelining
        request.networkServiceType = self.networkServiceType
        //add headers
        
        var isMultiForm = false
        //do a check for upload objects to see if we are multi form
        if let params = parameters {
            for (name,object: AnyObject) in params {
                if object is HTTPUpload {
                    isMultiForm = true
                    break
                }
            }
        }
        if isMultiForm {
            if(method != HTTPMethod.POST || method != HTTPMethod.PUT) {
                request.HTTPMethod = HTTPMethod.POST.toRaw() // you probably wanted a post
            }
            //do multi form encoding..
            return request
        }
        var queryString = ""
        if parameters {
            queryString = self.stringFromParameters(parameters!)
        }
        if isURIParam(method) {
            var para = request.URL.query ? "&" : "?"
            var newUrl = "\(request.URL.absoluteString)\(para)\(queryString)"
            request.URL = NSURL.URLWithString(newUrl)
        } else {
            var charset = CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
            if !request.valueForHTTPHeaderField(contentTypeKey) {
                request.setValue("application/x-www-form-urlencoded; charset=\(charset)",
                    forHTTPHeaderField:contentTypeKey)
            }
            request.HTTPBody = queryString.dataUsingEncoding(self.stringEncoding, allowLossyConversion: false)
        }
        return request
    }
    
    ///convert the parameter dict to its HTTP string representation
    func stringFromParameters(parameters: Dictionary<String,AnyObject>) -> String {
        var pairs = serializeObject(parameters, key: nil)
        //join the pairs
        var str = ""
        var index = 0
        for pair in pairs {
            str += pair.stringValue()
            if index < pairs.count-1 {
                str += "&"
            }
            index++
        }
        return str
    }
    ///check if enum is a HTTPMethod that requires the params in the URL
    func isURIParam(method: HTTPMethod) -> Bool {
        if(method == HTTPMethod.GET || method == HTTPMethod.HEAD || method == HTTPMethod.DELETE) {
            return true
        }
        return false
    }
    ///the method to serialized all the objects
    func serializeObject(object: AnyObject,key: String?) -> Array<HTTPPair> {
        var collect = Array<HTTPPair>()
        if let array = object as? Array<AnyObject> {
            for nestedValue : AnyObject in array {
                collect.extend(self.serializeObject(nestedValue,key: "\(key)[]"))
            }
        } else if let dict = object as? Dictionary<String,AnyObject> {
            for (nestedKey, nestedObject: AnyObject) in dict {
                var newKey = key ? "\(key)[\(nestedKey)]" : nestedKey
                collect.extend(self.serializeObject(nestedObject,key: newKey))
            }
        } else {
            collect.append(HTTPPair.Pair(object, key: key))
        }
        return collect
    }
    //create a multi form data object of the parameters
    func dataFromParameters(parameters: Dictionary<String,AnyObject>) -> NSData {
        var mutData = NSMutableData()
        var files = Dictionary<String,HTTPUpload>()
        var notFiles = Dictionary<String,AnyObject>()
        for (key, object: AnyObject) in parameters {
            if let upload = object as? HTTPUpload {
                files[key] = upload
            } else {
                notFiles[key] = object
            }
        }
        //add inital boundary
        //add files
        //add parameters
        //add closing boundary
        //done!
        return mutData
    }
    ///Local class to create key/pair of the parameters
    class HTTPPair: NSObject {
        var value: AnyObject!
        var key: String!
        
        func stringValue() -> String {
            if !self.key {
                return value.description!.escapeStr()
            }
            return "\(self.key.escapeStr())=\(self.value.description!.escapeStr())"
        }
        
        class func Pair(value: AnyObject, key: String?) -> HTTPPair {
            var pair = HTTPPair()
            pair.value = value
            pair.key = key
            return pair
        }
    }
   
}
