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
        if input.isEmpty {
            return false
        }

        let RegEx = "^[a-zA-Z\\u4E00-\\u9FA5\\d\\s]*$"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: input) ? false : true
    }
    
    // MARK: - 檢核輸入為英數字
    func isEnglishAndNumber(_ input:String) -> Bool {
        let RegEx = "[a-zA-Z0-9]*"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        return Test.evaluate(with: input)
    }
    
    // MARK: - 檢核輸入為全英文or全數字 
    func isAllEnglishOrNumber(_ input:String) -> Bool {
        var result = true
        var RegEx = "[a-zA-Z]*"
        var Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        if Test.evaluate(with: input) {
            result = false
        }
        RegEx = "[0-9]*"
        Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        if Test.evaluate(with: input) {
            result = false
        }
        return result
    }
    
    // MARK: - 檢核輸入為全數字
    func isAllNumber(_ input:String) -> Bool {
        let RegEx = "[0-9]*"
        let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
        if Test.evaluate(with: input) {
            return true
        }
        return false
    }
    //MARK: - 必須包含至少一位大寫英文、一位小寫英文、一位數字
    func checkInputEnglihandNumber(_ input:String) -> Bool {
        var result = true
        let RegExA = "[^A-Z]*"
        let RegExa = "[^a-z]*"
        let RegEx0 = "[^0-9]*"
        let TestA = NSPredicate(format:"SELF MATCHES %@", RegExA)
        let Testa = NSPredicate(format:"SELF MATCHES %@", RegExa)
        let Test0 = NSPredicate(format:"SELF MATCHES %@", RegEx0)
        if TestA.evaluate(with: input){
            result = false
        }
        if Testa.evaluate(with: input){
            result = false
        }
        if Test0.evaluate(with: input) {
            result = false
        }
        return result
    }
    // MARK: - 檢核不得有三個以上相同的英數字、連續英文字或連號數字，例如aaa、abc、cba、aba、111、123、321、121等，且宜包含大小寫英文字母。
    //2022/10 修改不檢核大小寫
    func checkInputNotContinuous(_ input:String) -> Bool {
        var result = true
        if isEnglishAndNumber(input) {
            for index in 0...input.asciiArray.count-3 {
                var number1 = Int(input.asciiArray[index+1]) - Int(input.asciiArray[index])
                var number2 = Int(input.asciiArray[index+2]) - Int(input.asciiArray[index])
                if number1 < 0 && number2 < 0 {
                    number1 = -(number1)
                    number2 = -(number2)
                }
                
                //3碼連續,EX.123,321
                if number1 == 0 && number2 == 0 {
                    result = false
                    break
                }
                //3碼連續,EX.123,321
                else if number1 == 1 && number2 == 2 {
                    result = false
                    break
                }
                /* 客戶需求修改 */
                //3碼連續,EX.121
//                else if number1 == 1 && number2 == 0 {
//                    result = false
//                    break
//                }
            }
        }
        else {
            result = false
        }
        return result
    }
}

//extension Character {
//    var asciiValue: UInt32? {
//        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
//    }
//}

extension String {
    var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
}

