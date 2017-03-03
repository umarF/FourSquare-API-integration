//
//  ServerRequest.swift
//  GrubHound
//
//  Created by Umar Farooque on 16/02/17.
//  Copyright © 2017 ufocorp. All rights reserved.
//

/*

 THIS CLASS IS USED FOR MAKING AND HANDLING SERVER CALLS

*/


import UIKit

//MARK: Server Call backs
protocol ServerRequestDelegate : class {
    func requestFinishedWithResultArray(_ responseArray :Array<Any>,apiCallType: Int,response:URLResponse)->Void
    func requestFinishedWithResult(_ responseDictionary :[String:Any],apiCallType: Int,response:URLResponse)->Void
    func requestFinishedWithResponse(_ response: URLResponse, message:String ,apiCallType:Int)-> Void
    func requestFailedWithError(_ error: Error ,apiCallType:Int,response:URLResponse?) ->Void
    
}

class ServerRequest: NSObject{
    
    // MARK: - API TYPES
    enum API_TYPES_NAME: Int {
        
        case get_FourSquareData
        case get_VenueDetails
        case get_ExploreData
    }
    
    //MARK:  Variables
    var apiType: API_TYPES_NAME?
    weak var delegate: ServerRequestDelegate?

    //MARK: Functions for server interactions
    func generateUrlRequestWithURLPartParameters(_ urlPartParam:[String:Any]?, postParam:[String:Any]?)-> Void {
        
        var serverRequestUrl = ""
        let request = NSMutableURLRequest()
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15.0
        
        if postParam != nil
        {
            do{
                let httpBodyData = try JSONSerialization.data(withJSONObject: postParam!, options: JSONSerialization.WritingOptions())
                request.httpBody = httpBodyData
            }
            catch let error as NSError {
                // SHOW ERROR
                DispatchQueue.main.async(execute: {
                    
                    self.delegate?.requestFailedWithError(error, apiCallType: self.apiType!.rawValue,response: nil)
                    
                })
                return
            }
        }
        
        if appDelegateObj.stringCoord.count < 2 {
            DispatchQueue.main.async(execute: {
                
                self.delegate?.requestFailedWithError(CustomError.locationNotFound, apiCallType: self.apiType!.rawValue,response: nil)
                
            })
            return
            
        }else{
            
            
            switch apiType! {
                
            case .get_ExploreData:
                request.httpMethod = "GET"
                if urlPartParam?["q"] as? String != nil {
                    
                    if urlPartParam?["q"] as! String == "All" {
                        
                        serverRequestUrl = "\(SERVER_URL)/v2/venues/explore?ll=\(appDelegateObj.stringCoord[0]),\(appDelegateObj.stringCoord[1])&client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&v=\(getCurrentDate())&limit=50&section=food&sortByDistance=1"
                        
                    }else{
                        
                        serverRequestUrl = "\(SERVER_URL)/v2/venues/explore?ll=\(appDelegateObj.stringCoord[0]),\(appDelegateObj.stringCoord[1])&client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&v=\(getCurrentDate())&limit=50&section=food&sortByDistance=1&query=\(urlPartParam?["q"] as! String)"
                    }
                    
                }else{
                    serverRequestUrl = "\(SERVER_URL)/v2/venues/explore?ll=\(appDelegateObj.stringCoord[0]),\(appDelegateObj.stringCoord[1])&client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&v=\(getCurrentDate())&limit=50&section=food&sortByDistance=1"
                }
                break
                
                
                
            case .get_FourSquareData:
                request.httpMethod = "GET"
                
                if urlPartParam?["q"] as? String != nil {
                    
                    serverRequestUrl = "\(SERVER_URL)/venues/search?ll=\(appDelegateObj.stringCoord[0]),\(appDelegateObj.stringCoord[1])&client_id= \(CLIENT_ID)&client_secret= \(CLIENT_SECRET)&v=\(getCurrentDate())&section=food&limit=50&query=\(urlPartParam?["q"] as! String)"
                    
                }else{
                    
                    serverRequestUrl = "\(SERVER_URL)/venues/search?ll=\(appDelegateObj.stringCoord[0]),\(appDelegateObj.stringCoord[1])&client_id= \(CLIENT_ID)&client_secret= \(CLIENT_SECRET)&v=\(getCurrentDate())&limit=50&section=food"
                }
                
                break
                
            case .get_VenueDetails:
                request.httpMethod = "GET"
                serverRequestUrl = "\(SERVER_URL)/v2/venues/\(urlPartParam?["v_id"] as! String)?v=\(getCurrentDate())&ll=\(appDelegateObj.stringCoord[0]),\(appDelegateObj.stringCoord[1])&limit=50&client_secret=\(CLIENT_SECRET)&client_id=\(CLIENT_ID)"
                break
            }
            
            serverRequestUrl = serverRequestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            request.url = URL(string:serverRequestUrl)
            self.performSessionDataTaskwithRequest(request as URLRequest)
            
            
        }
    }
    
    
    func performSessionDataTaskwithRequest(_ request:URLRequest)->Void{
        
        let callType :Int
        callType =  Int((self.apiType?.rawValue)!)
        var resultFromServer: Any?
        let responseResultData = [String:Any]()
        //configure session
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let session : URLSession
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        session.dataTask(with: request) { (data, response, error ) in
            
                if error != nil {
                    
                    DispatchQueue.main.async(execute: {
                        
                        self.delegate?.requestFailedWithError(error!, apiCallType: callType,response: nil)
                        session.invalidateAndCancel()
                    })
                    
                }else{
                    
                    let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
                    
                        do{
                                resultFromServer = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                                if httpResponse.statusCode == 200  || httpResponse.statusCode == 201 || httpResponse.statusCode == 202 || httpResponse.statusCode == 204 || httpResponse.statusCode == 203 {
                                    if (resultFromServer as? [Any]) != nil{
                                        
                                        //array result
                                        
                                        DispatchQueue.main.async(execute: {
                                            
                                            self.delegate?.requestFinishedWithResultArray((resultFromServer as? [Any])!, apiCallType: callType,response: httpResponse)
                                        })
                                        
                                        
                                    }else if (resultFromServer as? [String : Any]) != nil {
                                        
                                        //dictionary result
                                        DispatchQueue.main.async(execute: {
                                            
                                            self.delegate?.requestFinishedWithResult((resultFromServer as? [String : Any])!,apiCallType: callType,response: httpResponse)
                                            
                                        })
                                        
                                    }else{
                                        
                                        DispatchQueue.main.async(execute: {
                                            
                                            self.delegate?.requestFinishedWithResult(responseResultData,apiCallType: callType,response: httpResponse)
                                            
                                        })
                                    }
                                    
                                }
                                else {
                                    
                                    if (resultFromServer as? [String : Any]) != nil {
                                        
                                    }
                                    if httpResponse.statusCode == 401  || httpResponse.statusCode == 403
                                    
                                    {
                                        
                                    }
                                    else {
                                        
                                        if let respArray = responseResultData.values.first as? NSArray {
                                            
                                            if responseResultData.values.count > 0 && respArray.count > 0 {
                                                let msgStr = respArray.firstObject
                                                
                                                DispatchQueue.main.async(execute: {
                                                    
                                                    self.delegate?.requestFinishedWithResponse(httpResponse, message: msgStr as! String, apiCallType: callType)
                                                })
                                                
                                            }
                                            
                                        }else {
                                            
                                        }
                                    }
                                }
                            }
                            
                        catch let error as NSError {
                            
                            DispatchQueue.main.async(execute: {
                                
                                self.delegate?.requestFailedWithError(error, apiCallType: callType,response:httpResponse)
                                session.invalidateAndCancel()
                                
                            })
                        }
                }
            session.finishTasksAndInvalidate()
            }.resume()
        
    }

    
    
    func downloadImagefromURL(stringURL:String, imageObj: UIImage,completion: @escaping ((_ data: NSData?, _ response: URLResponse?, _ error: NSError? ) -> Void))
    {
        
        var request = URLRequest(url:URL(string: stringURL)!)
        request.timeoutInterval = 25.0
        request.httpMethod = "GET"
        var resultFromServer :Any?
        //configure session
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData
        let session : URLSession
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        session.dataTask(with: request) { (data, response, error) in
            
            
            if error != nil {
                    //error
            }else {
                
                if response != nil {
                    
                    let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
                    
                    if (httpResponse.statusCode == 200 || httpResponse.statusCode == 201 || httpResponse.statusCode == 204 || httpResponse.statusCode == 203)
                    {
                        //completion handler
                        completion(data as NSData?, response, error as NSError?)
                        
                    } else if httpResponse.statusCode == 400 || httpResponse.statusCode == 401  ||
                        httpResponse.statusCode == 402 || httpResponse.statusCode == 403 || httpResponse.statusCode == 404 || httpResponse.statusCode == 405 || httpResponse.statusCode == 406 {
                        //failure
                        
                        do {
                            
                            resultFromServer = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                            if let respArr = resultFromServer as? NSArray{
                                
                                //array resp
                                
                            }
                            
                            if let respDict = resultFromServer as? NSDictionary{
                                
                                //dict resp
                            }
                            
                        } catch let error as NSError {
                            
                        }
                        
                        
                    }
                    
                }
                
            }
            
            }.resume()
    }
    
    
}
