//
//  ConnectionUtility.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/4/6.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import Foundation

let REQUEST_TIME_OUT:TimeInterval = 30  // Time out
let CERTIFICATE_NAME = ""               // 憑證名稱
let CERTIFICATE_TYPE = "cer"            // 憑證副檔名

protocol ConnectionUtilityDelegate {
    func didRecvdResponse(_ description:String, _ response: [String:Any]) -> Void
    func didFailedWithError(_ error: Error) -> Void
}

class ConnectionUtility: NSObject, URLSessionDelegate {
    private var delegate:ConnectionUtilityDelegate? = nil
    private var needCertificate:Bool = false
    var downloadType:DownloadType = .Json
    var responseData = NSMutableData()
    
    init(_ type:DownloadType = .Json) {
        downloadType = type
    }
    
    func postRequest(_ delegate:ConnectionUtilityDelegate?, _ strURL:String, _ strTag:String, _ dicHttpHead:[AnyHashable:Any]? = nil, _ needCertificate:Bool = false ) -> Void {
        self.delegate = delegate
        self.needCertificate = needCertificate
        var request = URLRequest(url:URL(string:strURL)!, cachePolicy:.reloadIgnoringLocalCacheData, timeoutInterval:REQUEST_TIME_OUT)
        request.httpMethod = "Post"
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.httpAdditionalHeaders = dicHttpHead
        
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue())
        session.sessionDescription = strTag
        
        let task = session.dataTask(with: request)
        task.resume()
    }
    
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
                self.delegate?.didFailedWithError(error!)
            }
            else {
                switch self.downloadType {
                case .Json:
                    do {
                        let json = try JSONSerialization.jsonObject(with:self.responseData as Data, options:.mutableContainers) as! [String:Any]
                        self.delegate?.didRecvdResponse(session.sessionDescription!, json)
                    }
                    catch {
                        self.delegate?.didFailedWithError(error)
                    }
                case .Image:
                    if let image = UIImage(data:self.responseData as Data) {
                        self.delegate?.didRecvdResponse(session.sessionDescription!, [RESPONSE_IMAGE_KEY:image])
                    }
                }
            }
        }
    }
    
    // MARK: - URLSessionDelegate
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if needCertificate {
                if let serverTrust = challenge.protectionSpace.serverTrust {
                    let cerPath = Bundle.main.path(forResource: CERTIFICATE_NAME, ofType: CERTIFICATE_TYPE)!
                    let localCertificateData = try! Data(contentsOf: URL(fileURLWithPath:cerPath)) as CFData
                    let localCertificate = SecCertificateCreateWithData(nil, localCertificateData)
                    let trustedCertList = [localCertificate] as CFArray
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
