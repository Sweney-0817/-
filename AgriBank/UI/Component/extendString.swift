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
}
