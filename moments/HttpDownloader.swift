import Foundation

class HttpDownloader {
    
    class func loadFileSync(url: NSURL, completion:(url:NSURL, error:NSError!) -> Void) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
            completion(url: destinationUrl, error:nil)
        } else if let dataFromURL = NSData(contentsOfURL: url){
            if dataFromURL.writeToURL(destinationUrl, atomically: true) {
                print("file saved [\(destinationUrl.path!)]")
                completion(url: destinationUrl, error:nil)
            } else {
                print("error saving file")
                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                completion(url: destinationUrl, error:error)
            }
        } else {
            let error = NSError(domain:"Error downloading file", code:1002, userInfo:nil)
            completion(url: destinationUrl, error:error)
        }
    }
    
    class func loadFileAsync(url: NSURL, completion:(url:NSURL, error:NSError!) -> Void) {
        let documentsUrl =  NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(url.lastPathComponent!)
        if NSFileManager().fileExistsAtPath(destinationUrl.path!) {
            print("file already exists [\(destinationUrl.path!)]")
            completion(url: destinationUrl, error:nil)
        } else {
            let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error == nil) {
                    if let response = response as? NSHTTPURLResponse {
                        print("response=\(response)")
                        if response.statusCode == 200 {
                            if data!.writeToURL(destinationUrl, atomically: true) {
                                print("file saved [\(destinationUrl.path!)]")
                                completion(url: destinationUrl, error:error)
                            } else {
                                print("error saving file")
                                let error = NSError(domain:"Error saving file", code:1001, userInfo:nil)
                                completion(url: destinationUrl, error:error)
                            }
                        }
                    }
                }
                else {
                    print("Failure: \(error!.localizedDescription)");
                    completion(url: destinationUrl, error:error)
                }
            })
            task.resume()
        }
    }
}