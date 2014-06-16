//////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HTTPTask.swift
//
//  Created by Dalton Cherry on 6/3/14.
//  Copyright (c) 2014 Vluxe. All rights reserved.
//
//////////////////////////////////////////////////////////////////////////////////////////////////

import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case HEAD = "HEAD"
    case DELETE = "DELETE"
}

class HTTPTask: NSObject {
    
    var method: HTTPMethod = HTTPMethod.GET
    var url: String?
    var requestSerializer: HTTPRequestSerializer!
    var responseSerializer: HTTPResponseSerializer?
    /**Create a newly initalized object */
    init() {
        super.init()
    }
    init(url: String) {
        self.url = url
    }
    /**run/start the HTTP task */
    func run(parameters: Dictionary<String,AnyObject>!, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) {
        if self.url {
            
            if !self.requestSerializer {
                self.requestSerializer = HTTPRequestSerializer()
            }
            let serialReq = self.requestSerializer.createRequest(NSURL.URLWithString(self.url),
                method: self.method, parameters: parameters)
            if serialReq.error {
                failure(serialReq.error!)
                return
            }
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(serialReq.request,
                completionHandler: {(data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
                if error {
                    failure(error)
                    return
                }
                if data {
                    var responseObject: AnyObject = data
                    if self.responseSerializer {
                        let resObj = self.responseSerializer!.responseObjectFromResponse(response, data: data)
                        if resObj.error {
                            failure(resObj.error!)
                            return
                        }
                        if resObj.object {
                            responseObject = resObj.object!
                        }
                    }
                    success(responseObject)
                } else {
                    failure(error)
                }
                })
            task.resume()
        }
    }
    
    /**One line class method */
    class func GET(url: String, parameters: Dictionary<String,AnyObject>?, success:((AnyObject?) -> Void)!, failure:((NSError) -> Void)!) -> HTTPTask {
        var task = HTTPTask(url: url)
        task.run(parameters,success,failure)
        return task
    }
   
}
