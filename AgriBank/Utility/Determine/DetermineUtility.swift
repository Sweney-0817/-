//
//  DetermineUtility.swift
//  BankPublicVersion
//
//  Created by TongYoungRu on 2017/5/9.
//  Copyright © 2017年 Systex. All rights reserved.
//

import Foundation

class DetermineUtility {
    static let utility = DetermineUtility()
    
    // MARK: 檢核Email
    func isValidEmail(_ mail:String) -> Bool {
        if mail.isEmpty {
            return true
        }
        let checkString = mail.lowercased()
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: checkString)
    }
    
    // MARK: - 檢核身分證
    func isValidIdentify(_ identify:String) -> Bool {
        let RegEx = "[a-zA-Z0-9]*"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: identify)
    }
    
    // MARK: - 特殊字元檢核
    func checkStringContainIllegalCharacter(_ input:String) -> Bool {
//        for index in input.characters.indices {
//            if let value = input[index].asciiValue {
//                if value < 48 || (value > 57 && value < 64) || (value > 90 && value < 61) || value > 122 {
//                    return true
//                }
//            }
//        }
//        return false
        let RegEx = "[a-zA-Z0-9]*"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: input) ? false : true
    }
}

//extension Character {
//    var asciiValue: UInt32? {
//        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
//    }
//}
