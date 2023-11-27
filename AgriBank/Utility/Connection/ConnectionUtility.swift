//
//  ConnectionUtility.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/4/6.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import Foundation

let REQUEST_TIME_OUT:TimeInterval = 65  // Time out Default
let CERTIFICATE_NAME = "server2022"               // 憑證名稱
let CERTIFICATE_NAME2 = "server2023"               // 憑證名稱
let CERTIFICATE_TYPE = "cer"            // 憑證副檔名
let TIME_OUT_125:TimeInterval = 305     // TRAN0101、TRAN0102、PAY0103、PAY0105、PAY0107 這幾支呼叫API於時時間請大於120秒，因為是跨行，EAI那邊可以等待120
                                        // 20180320 要求修改為300

protocol ConnectionUtilityDelegate {
    func didRecvdResponse(_ description:String, _ response: NSDictionary) -> Void
    func didFailedWithError(_ error: Error, _ sessionDescription: String?) -> Void
}

class ConnectionUtility: NSObject, URLSessionDelegate, URLSessionDataDelegate, URLSessionDownloadDelegate {
    private var delegate:ConnectionUtilityDelegate? = nil
#if DEBUG
    private var needCertificate:Bool = false
#else
    private var needCertificate:Bool = true
#endif
    var downloadType:DownloadType = .Json
    var responseData = NSMutableData()
    var isPostMethod = true
    
    init(_ type:DownloadType = .Json, _ postMethod:Bool = true) {
        downloadType = type
        isPostMethod = postMethod
    }

#if DEBUG
    func requestData(_ delegate:ConnectionUtilityDelegate?, _ strURL:String, _ strTag:String, _ httpBody:Data? = nil, _ dicHttpHead:[String:String]? = nil, _ needCertificate:Bool = false, _ timeOut:TimeInterval = REQUEST_TIME_OUT) -> Void {
        self.delegate = delegate
        self.needCertificate = needCertificate
//        NSLog("========[%@]=======", strURL)

        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue())
        session.sessionDescription = strTag
        
        switch downloadType {
        case .Json, .ImageConfirm, .ImageConfirmResult, .Data:
            var request = URLRequest(url:URL(string:strURL)!, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:timeOut)
            request.httpMethod = isPostMethod ? Http_Post_Method : Http_Get_Method
            if httpBody != nil {
                request.httpBody = httpBody
            }
            
            if dicHttpHead != nil {
                for (key, value) in dicHttpHead! {
                    request.addValue(value , forHTTPHeaderField: key)
                }
            }
            let task = session.dataTask(with: request)
            task.resume()
            
        case .Image:
            let task = session.downloadTask(with: URL(string:strURL)!)
            task.resume()
        }
    }
#else
    func requestData(_ delegate:ConnectionUtilityDelegate?, _ strURL:String, _ strTag:String, _ httpBody:Data? = nil, _ dicHttpHead:[String:String]? = nil, _ needCertificate:Bool = true, _ timeOut:TimeInterval = REQUEST_TIME_OUT) -> Void {
        self.delegate = delegate
        self.needCertificate = needCertificate
        //        NSLog("========[%@]=======", strURL)
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue())
        session.sessionDescription = strTag
        
        switch downloadType {
        case .Json, .ImageConfirm, .ImageConfirmResult, .Data:
            var request = URLRequest(url:URL(string:strURL)!, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:timeOut)
            request.httpMethod = isPostMethod ? Http_Post_Method : Http_Get_Method
            if httpBody != nil {
                request.httpBody = httpBody
            }
            
            if dicHttpHead != nil {
                for (key, value) in dicHttpHead! {
                    request.addValue(value , forHTTPHeaderField: key)
                }
            }
            let task = session.dataTask(with: request)
            task.resume()
            
        case .Image:
            let task = session.downloadTask(with: URL(string:strURL)!)
            task.resume()
        }
    }
#endif
//        self.delegate = delegate
//        self.needCertificate = needCertificate
////        NSLog("========[%@]=======", strURL)
//
//        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue())
//        session.sessionDescription = strTag
//
//        switch downloadType {
//        case .Json, .ImageConfirm, .ImageConfirmResult, .Data:
//            var request = URLRequest(url:URL(string:strURL)!, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:timeOut)
//            request.httpMethod = isPostMethod ? Http_Post_Method : Http_Get_Method
//            if httpBody != nil {
//                request.httpBody = httpBody
//            }
//
//            if dicHttpHead != nil {
//                for (key, value) in dicHttpHead! {
//                    request.addValue(value , forHTTPHeaderField: key)
//                }
//            }
//            let task = session.dataTask(with: request)
//            task.resume()
//
//        case .Image:
//            let task = session.downloadTask(with: URL(string:strURL)!)
//            task.resume()
//        }
//    }
    
    // MARK: - URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        responseData.append(data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            if error != nil {
               self.delegate?.didFailedWithError(error!, session.sessionDescription)
            }
            else {
                if self.downloadType == .Json {
                    var jsonData = self.responseData as Data
                    if let value = (task.response as! HTTPURLResponse).allHeaderFields[AnyHashable(AuthorizationManage_HttpHead_CID)] {
                        let str = String(data: self.responseData as Data, encoding: .utf8)?.replacingOccurrences(of: "\"", with: "")
                        if let key = AuthorizationManage.manage.GetCIDKey(value as! String) {
                            let decryptStr = SecurityUtility.utility.AES256Decrypt(str!, key)
                            if let data = decryptStr.data(using: .utf8) {
                                jsonData = data
                            }
                        }
                    }
                    
                    do {
                        let jsonDic = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! NSDictionary
                        self.delegate?.didRecvdResponse(session.sessionDescription!, jsonDic)
                        #if DEBUG
                        print( String(data: jsonData, encoding: .utf8) ?? session.sessionDescription!)
                        #endif
                        
                    }
                    catch {
                        self.delegate?.didFailedWithError(error, session.sessionDescription)
                    }
                }
                else if self.downloadType == .ImageConfirm {
                    var resultList = [String:Any]()
                    if let image = UIImage(data: self.responseData as Data) {
                        resultList[RESPONSE_IMAGE_KEY] = image
                    }
                    if let value = (task.response as! HTTPURLResponse).allHeaderFields[AnyHashable(AuthorizationManage_HttpHead_VarifyId)] {
                        resultList[RESPONSE_VARIFYID_KEY] = value
                    }
                    resultList[ReturnCode_Key] = ReturnCode_Success
                    self.delegate?.didRecvdResponse(session.sessionDescription!, resultList as NSDictionary)
                }
                else if self.downloadType == .ImageConfirmResult {
                    var resultList = [String:Any]()
                    resultList[ReturnCode_Key] = ReturnCode_Success
                    if let flag = String(data: self.responseData as Data, encoding: .utf8) {
                        resultList[RESPONSE_IMAGE_CONFIRM_RESULT_KEY] = flag
                    }
                    self.delegate?.didRecvdResponse(session.sessionDescription!, resultList as NSDictionary)
                }
                else if self.downloadType == .Data {
                    var resultList = [String:Any]()
                    resultList[ReturnCode_Key] = ReturnCode_Success
                    resultList[RESPONSE_Data_KEY] = self.responseData as Data
                    self.delegate?.didRecvdResponse(session.sessionDescription!, resultList as NSDictionary)
                }
            }
        }
    }
    
    // MARK: - URLSessionDownloadTask
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            if let data = try? Data(contentsOf: location) {
                if self.downloadType == .Image {
                    var resultList = [String:Any]()
                    resultList[ReturnCode_Key] = ReturnCode_Success
                    if let image = UIImage(data: data) {
                        resultList[RESPONSE_IMAGE_KEY] = image
                    }
                    self.delegate?.didRecvdResponse(session.sessionDescription!, resultList as NSDictionary)
                }
            }
        }
    }
    
    // MARK: - URLSessionDelegate
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if needCertificate {
                if let serverTrust = challenge.protectionSpace.serverTrust {
                    //憑證1
                    let cerPath = Bundle.main.path(forResource: CERTIFICATE_NAME, ofType: CERTIFICATE_TYPE)!
                    let localCertificateData = try! Data(contentsOf: URL(fileURLWithPath:cerPath)) as CFData
                    let localCertificate = SecCertificateCreateWithData(nil, localCertificateData)
                    //憑證2
                    let cerPath2 = Bundle.main.path(forResource: CERTIFICATE_NAME2, ofType: CERTIFICATE_TYPE)!
                    let localCertificateData2 = try! Data(contentsOf: URL(fileURLWithPath:cerPath2)) as CFData
                    let localCertificate2 = SecCertificateCreateWithData(nil, localCertificateData2)
                    
                    let trustedCertList = [localCertificate, localCertificate2] as CFArray
                    var status = SecTrustSetAnchorCertificates(serverTrust, trustedCertList)
                    if status == noErr {
                        var trustResult: SecTrustResultType = .invalid
                        status = SecTrustEvaluate(serverTrust, &trustResult)
                        if status == errSecSuccess && (trustResult == .proceed || trustResult == .unspecified) {
                            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
                            return
                        }
                    }
                }
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
            else {
                completionHandler(.performDefaultHandling, nil)
            }
        }
        else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
