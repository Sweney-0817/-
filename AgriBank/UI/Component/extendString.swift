//
//  extendString.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/9/22.
//  Copyright © 2017年 Systex. All rights reserved.
//

import Foundation

extension String {
    func separatorThousand() -> String {
        var temp = self.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: "-", with: "")
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
//        formatter.decimalSeparator = "."
//        formatter.numberStyle = .decimal
//        formatter.maximumFractionDigits = 2
        if let number = formatter.number(from: temp) {
            temp = formatter.string(from: number) ?? temp
        }
        return temp
    }
    
    // 取除小數點
    func separatorDecimal() -> String {
        var temp = self.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: "-", with: "")
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        if let number = formatter.number(from: temp) {
            temp = formatter.string(from: number) ?? temp
        }
        return temp
    }
    
    // 日期格式轉換
    func dateFormatter(form: String?, to: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = form
        let dtDate = dateFormatter.date(from: self)
        
        dateFormatter.dateFormat = to
        let strDate: String = dateFormatter.string(from: dtDate!)
        
        return strDate
    }
    
    func toDate(_ form: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = form
        let dtDate = dateFormatter.date(from: self)
        return dtDate
    }
        
    // MARK: - SubString
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        
        if let end = to, end >= 0, end < self.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return String(self[startIndex ..< endIndex])
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
    
    func components(separatedBy iMaxLength: Int) -> [String] {
        let iCount: Int = self.count
        var aryComponents: [String] = []
        var strSub: String = ""
        var iFromIndex: Int = 0
        var iLength: Int = 0
        
        while iFromIndex < iCount {
            iLength = (iFromIndex + iMaxLength > iCount) ? (iCount - iFromIndex) : iMaxLength
            strSub = self.substring(from: iFromIndex, length: iLength)
            
            aryComponents.append(strSub)
            iFromIndex += iLength
        }
        
        return aryComponents
    }
}
