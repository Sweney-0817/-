//
//  PayTaxInfo.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/9.
//  Copyright © 2018年 Systex. All rights reserved.
//

import Foundation
// QRCode規格如下:
// 1.查(核)定類稅款：https://paytax.nat.gov.tw/QRCODE.aspx?par= + (5位繳款類別) + (16位銷帳編號)+ (10位繳款金額) + (6繳納截止日)+ (5位期別代號)+ (6位識別碼)，共48字元。
let PayTax_Type11_Length : Int = 48
let PayTax_Type11_Type : String = "PayTax11"
// 2.綜所稅：https://paytax.nat.gov.tw/QRCODE.aspx?par= + (5位繳款類別，固定值:15001) 共5字元
let PayTax_Type15_Length : Int = 5
let PayTax_Type15_Type : String = "PayTax15"

let PayTax_SubType_Length : Int = 3

let PayTax_URL_host : String = "paytax.nat.gov.tw"
let PayTax_URL_scheme : String = "https"

let PayTax_Type11_ShowTitle : [String] = ["繳稅類別","銷帳編號","繳款金額","繳納截止日","期別代號"]
let PayTax_Type15_ShowTitle : [String] = ["繳稅類別","所屬年度"]
let PayTax_Type15_NoShowTitle : [String] = ["所屬年月"]

let PayTax_Type11_Confirm_AddShowTitle : [String] = ["Email"]
let PayTax_Type15_Confirm_AddShowTitle : [String] = ["納稅義務人身分證字號","已繳金額","本次繳款金額","Email"]

struct PayTax {
    /// 繳款類別代碼
    var taxType : String?
    /// 銷帳編號
    var number : String?
    /// 繳款金額
    var amount : String?
    /// 繳納截止日
    var deadLine : String?
    /// 期別代號
    var periodCode : String?
    /// 年
    var m_strPayTaxYear : String?
    /// 月
    var m_strPayTaxMonth : String?
    
    init() {
        taxType = nil
        number = nil
        amount = nil
        deadLine = nil
        periodCode = nil
        m_strPayTaxYear = nil
        m_strPayTaxMonth = nil
    }
    static func getTypeName(_ isUp : Bool) -> [String:String] {
        return ["15001":"綜合所得稅結算申報繳稅", "11221":"牌照稅-大型自用客車", "11222":"牌照稅-大型自用貨車", "11223":"牌照稅-小型自用客車", "11224":"牌照稅-小型自用貨車", "11226":"牌照稅-大型營業貨車(普)", "11227":"牌照稅-小型營業客車", "11228":"牌照稅-小型營業貨車", "11229":"牌照稅-大型營業客車(特)", "11230":"牌照稅-大型營業貨車(特)", "11232":"牌照稅-重型機車", "11235":"牌照稅-大自貨牽引車", "11236":"牌照稅-大營貨牽引車", "11201":"房屋稅-定期開徵稅款", "11331":"地價稅-定期開徵稅款", "11002":"綜所稅申報核定補徵稅款", "11003":"綜所稅未申報核定補徵稅款"]
    }
}
