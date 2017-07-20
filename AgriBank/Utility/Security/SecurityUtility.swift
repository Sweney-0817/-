//
//  ShareUtility.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/4/13.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import UIKit

let JailBroken_AppName = "/Applications/Cydia.app"

class SecurityUtility {
    static let utility = SecurityUtility()
    // MARK: AES加密
    func AES256Encrypt(_ nsEncrypt:String, _ key:String) -> String {
        let encrypt = (nsEncrypt as NSString).aes256Encrypt(withKey: key)
        return encrypt ?? ""
    }
    
    func AES256Decrypt(_ nsDecrypt:String, _ key:String) -> String {
        let decrypt = (nsDecrypt as NSString).aes256Decrypt(withKey: key)
        return decrypt ?? ""
    }

    // MARK: - 模擬器判斷
    func isSimulator() -> Bool {
        var isSimulator = false
        #if TARGET_OS_SIMULATOR && !DEBUG
            isSimulator = true
        #endif
        return isSimulator
    }
    
    // MARK: - APP JB判斷
    func isJailBroken() -> Bool {
        // 註解: Cydia 和 App Store 一樣是家線上 App 軟體商店，不過 iPhone / iPad 要 JB 越獄後才能安裝和進入 Cydia 商店，Cydia 很多人稱為第三方商店
        return FileManager.default.fileExists(atPath: JailBroken_AppName)
    }
    
    // MARK: - 連線暫存檔清除(ex: cache.db... )
    func removeConnectCatche() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    
    // MARK: - 讀檔案 / 寫檔案
    func readFileByKey( SetKey key:String, setDecryptKey enKey:String? = nil ) -> Any? {
        if enKey != nil {
            if let data = UserDefaults.standard.object(forKey: key) {
                return AES256Decrypt(data as! String, enKey!)
            }
            return nil
        }
        else {
            return UserDefaults.standard.object(forKey: key)
        }
    }
    
    func writeFileByKey(_ value:Any?, SetKey key:String, setEncryptKey enKey:String? = nil ) {
        if enKey != nil {
            UserDefaults.standard.set(AES256Encrypt(value as! String, enKey!), forKey: key)
        }
        else {
            UserDefaults.standard.set(value, forKey: key)
        }
    }
}

