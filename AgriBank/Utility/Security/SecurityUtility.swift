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
    // MARK: - AES加密
    func AES256Encrypt(_ nsEncrypt:String, _ key:String) -> String {
        let encrypt = (nsEncrypt as NSString).aes256Encrypt(withKey: key)
        return encrypt ?? ""
    }
    
    func AES256Decrypt(_ nsDecrypt:String, _ key:String) -> String {
        let decrypt = (nsDecrypt as NSString).aes256Decrypt(withKey: key)
        return decrypt ?? ""
    }
    
    // MARK: - MD5
    func MD5(string: String) -> String {
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes {digestBytes in
            messageData.withUnsafeBytes {messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        
        let md5Hex = digestData.map { String(format: "%02hhx", $0) }.joined()
        return md5Hex.uppercased()
    }

    // MARK: - 模擬器判斷
    func isSimulator() -> Bool {
        var isSimulator = false
        #if TARGET_OS_SIMULATOR && !DEBUG
            isSimulator = true
        #endif
        #if targetEnvironment(simulator) && !DEBUG//for swift
            isSimulator = true
        #else
        
        #endif
        return isSimulator
    }
    
    // MARK: - APP JB判斷
    func isJailBroken() -> Bool {
        // 註解: Cydia 和 App Store 一樣是家線上 App 軟體商店，不過 iPhone / iPad 要 JB 越獄後才能安裝和進入 Cydia 商店，Cydia 很多人稱為第三方商店
//        return FileManager.default.fileExists(atPath: JailBroken_AppName)
    return VaktenManager.sharedInstance().isJailbroken()
       // return false
    }
    
    // MARK: - 連線暫存檔清除(ex: cache.db... )
    func removeConnectCatche() {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
    }
    
    // MARK: - 讀檔案 / 寫檔案
    func readFileByKey(SetKey key:String, setDecryptKey deKey:String? = nil) -> Any? {
        if deKey != nil {
            if let data = UserDefaults.standard.object(forKey: key) {
                return AES256Decrypt(data as! String, deKey!)
            }
            return nil
        }
        else {
            return UserDefaults.standard.object(forKey: key)
        }
    }
    
    func writeFileByKey(_ value:Any?, SetKey key:String, setEncryptKey enKey:String? = nil) {
        if enKey != nil {
            UserDefaults.standard.set(AES256Encrypt(value as! String, enKey!), forKey: key)
        }
        else {
            UserDefaults.standard.set(value, forKey: key)
        }
    }  
    
    
    //Caculet Mac Data by sweney 108-10-31
    
    func getMacData( iLogInTime:Date,iUID:String) -> String{
          
        var wkUIDnumber = 0
        var wkUIDstring = ""
        var wkUIDLeft9 = ""
        var wkUIDRight9 = ""
        var wkUIDLAR = 0
        var wkUIDLARstring = ""
        
        //set UID Number
        switch iUID.count {
        case 8:
            wkUIDnumber = Int(iUID) ?? 0
            wkUIDnumber = wkUIDnumber * 10000
        case 10:
            //檢查第二位字元是數字則為自然人else統一證號
            if (DetermineUtility.utility.isAllNumber(String(iUID[iUID.index(after: iUID.startIndex)]))){
                wkUIDnumber = Int(iUID.suffix(9)) ?? 0  * 1000
            }
            else{
                wkUIDnumber = Int(iUID.suffix(8)) ?? 0  * 10000
            }
        default:
            wkUIDnumber = 0
        }
        wkUIDstring = String(wkUIDnumber).padding(toLength: 12, withPad: "0", startingAt: 0)
        wkUIDLeft9 = String(wkUIDstring.prefix(9))
        wkUIDRight9 = String(wkUIDstring.suffix(9))
        
        wkUIDLAR = Int(wkUIDLeft9)! + Int(wkUIDRight9)!
        wkUIDLARstring = String(wkUIDLAR)
        // wkUIDLARstring = wkUIDLARstring.leftPadding(toLength: 12, withPad: "0" )
       wkUIDLARstring =  String(repeatElement("0", count: 12 - wkUIDLARstring.count)) + wkUIDLARstring
        var wkUIDEdcbic = ""
        wkUIDEdcbic = ASCIItoEBCDIC(istr: wkUIDLARstring)
        
        
        // 獲取當前時間
        let now:Date = iLogInTime // Date()
        // 建立時間格式
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.timeZone = NSTimeZone.init(abbreviation:"UTC")! as TimeZone
        dateFormat.dateFormat = "yyyyMMddHHmm"  //chiu 20210911 "yyyyMMddhhmm" 改 "yyyyMMddHHmm"
        // 將當下時間轉換成設定的時間格式
        var dateString = dateFormat.string(from: now)
        let interval = Int(now.timeIntervalSince1970)
        let days = Int(interval/86400) // 24*60*60
        let weekday = getWeek( WeekCode: ((days + 4)%7+7)%7)
        dateString = weekday + dateString.suffix(9)
        dateString = dateString.padding(toLength: 12, withPad: "0", startingAt: 0)
        var wkDateEdcbic = ""
        wkDateEdcbic = ASCIItoEBCDIC(istr: dateString)
        
        var wkDateBitMap = ""
        wkDateBitMap = SetBitString(iStr: wkDateEdcbic)
        var wkIDBitMap = ""
        wkIDBitMap = SetBitString(iStr: wkUIDEdcbic)
        var MacKey = ShiftBitString(iDateBit: wkDateBitMap, iIDBit: wkIDBitMap)
        return MacKey
    }
    
    func ShiftBitString (iDateBit:String,iIDBit:String) -> String
    {
        var wkDateBitstr = ""
        var wkIDBitStr = ""
        var wkHex = ""
        
        var Datei  = 0
        var IDi = 0
        var XorValue = 0
        var XorString = ""
        var XR = ""
        var j = 0
        for i in stride(from: 0, to: iDateBit.count , by: 8){
            j = j + 1
            wkDateBitstr = iDateBit.substring(from: i , length: 8)
            wkDateBitstr = wkDateBitstr.substring(from: 1) + "0"
            wkIDBitStr = iIDBit.substring(from: i, length: 8)
            Datei = Int(wkDateBitstr.substring(from: 0, length: 4),radix:2)!
            IDi = Int( wkIDBitStr.substring(from: 0, length: 4),radix:2)!
            XorValue = Datei ^ IDi
            XorString = String(XorValue, radix:16)

            XR = XR + XorString
            Datei = Int(wkDateBitstr.substring(from: 4, length: 4),radix:2)!
            IDi = Int(wkIDBitStr.substring(from: 4, length: 4),radix:2)!
            XorValue = Datei ^ IDi
            
            XorString = String(XorValue, radix:16)
            XR = XR + XorString
            
            
        }
        return XR
    }
    
    
    //Hex To Byte()
    func HexToBytes(_ string: String) -> Any? {
        let length = string.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for i in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
    
    
    func SetBitString(iStr:String) -> String
    {
        var wkByte = [UInt8]()
        
        var wkStr = ""
        wkByte = HexToBytes(iStr) as! [UInt8]
        for  i in 0..<(wkByte.count){
           
            wkStr = wkStr + bits(fromByte: wkByte[i])
        }
        return wkStr
    }
    enum Bit: UInt8, CustomStringConvertible {
        case zero, one
        
        var description: String {
            switch self {
            case .one:
                return "1"
            case .zero:
                return "0"
            }
        }
    }
 
    func bits(fromByte byte: UInt8) -> String {
        var byte = byte
        var bits = [Bit](repeating: .zero, count: 8)
        var bitString = ""
        for i in 0..<8 {
            let currentBit = byte & 0x01
            if currentBit != 0 {
              //  bits[i] = .one
                bitString =  "1" + bitString
            }else{
                bitString = "0" + bitString
            }
            
            byte >>= 1
        }
        
        return bitString
    }
    func  getWeek(WeekCode:Int) ->String {
        var wkStr = ""
        switch WeekCode {
        case 0:
            wkStr = "SUN"
            break
        case 1:
            wkStr = "MON"
            break
        case 2:
            wkStr = "TUE"
            break
        case 3:
            wkStr = "WED"
            break
        case 4:
            wkStr = "THU"
            break
        case 5:
            wkStr = "FRI"
            break
        case 6:
            wkStr = "SAT"
            break
        default:
            wkStr="   "
            break
        }
        return wkStr
    }
    
    
    func ASCIItoEBCDIC(istr:String ) -> String
    {
        var wkStr = ""
        var wkoStr = ""
        for i  in 0...(istr.count - 1){
            wkStr = istr.substring(from: i, length: 1)
            wkoStr =  wkoStr + Asc2Edcbic(iStr: wkStr)
        }
        return wkoStr
    }
    func Asc2Edcbic(iStr:String) -> String {
        var wkStr = ""
        switch iStr {
        case " ","$" :
            wkStr = "E0"
            break
        case "0" :
            wkStr = "F0"
            break
        case "1" :
            wkStr = "F1"
            break
        case "2" :
            wkStr = "F2"
            break
        case "3" :
            wkStr = "F3"
            break
        case "4" :
            wkStr = "F4"
            break
        case "5" :
            wkStr = "F5"
            break
        case "6" :
            wkStr = "F6"
            break
        case "7" :
            wkStr = "F7"
            break
        case "8" :
            wkStr = "F8"
            break
        case "9" :
            wkStr = "F9"
            break
        case "a" ,"A" :
            wkStr = "C1"
            break
        case "b" ,"B" :
            wkStr = "C2"
            break
        case "c" ,"C" :
            wkStr = "C3"
            break
        case "d" ,"D" :
            wkStr = "C4"
            break
        case "e" ,"E" :
            wkStr = "C5"
            break
        case "f" ,"F" :
            wkStr = "C6"
            break
        case "g" ,"G" :
            wkStr = "C7"
            break
        case "h" ,"H" :
            wkStr = "C8"
            break
        case "i" ,"I" :
            wkStr = "C9"
            break
        case "j" ,"J" :
            wkStr = "D1"
            break
        case "k" ,"K" :
            wkStr = "D2"
            break
        case "l" ,"L" :
            wkStr = "D3"
            break
        case "m" ,"M" :
            wkStr = "D4"
            break
        case "n" ,"N" :
            wkStr = "D5"
            break
        case "o" ,"O" :
            wkStr = "D6"
            break
        case "p" ,"P" :
            wkStr = "D7"
            break
        case "q" ,"Q" :
            wkStr = "D8"
            break
        case "r" ,"R" :
            wkStr = "D9"
            break
        case "s" ,"S" :
            wkStr = "E2"
            break
        case "t" ,"T" :
            wkStr = "E3"
            break
        case "u" ,"U" :
            wkStr = "E4"
            break
        case "v" ,"V" :
            wkStr = "E5"
            break
        case "w" ,"W" :
            wkStr = "E6"
            break
        case "x" ,"X" :
            wkStr = "E7"
            break
        case "y" ,"Y" :
            wkStr = "E8"
            break
        case "z" ,"Z" :
            wkStr = "E9"
            break
        default:
            wkStr = ""
            break
        }
        return wkStr
    }

}
