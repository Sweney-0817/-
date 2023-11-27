//
//  TaipowerInfo.swift
//  AgriBank
//
//  Created by ABOT on 2021/12/17.
//  Copyright © 2021 Systex. All rights reserved.
//

import Foundation
// QRCode規格如下：http://www.taipower.com.tw/tc/page.aspx?mid=128&cid=1621&cchk=6d6ca56b-26fe-4b92-bde8-8f58fbcbd59c?6BD8C306BA3657EE777036CA8B0741D9D737F61750F11B7890F37DF0A7C7212C
//power64No=6BD8C306BA3657EE777036CA8B0741D9D737F61750F11B7890F37DF0A7C7212C
//取右邊長度64個字元，之前五倍券有查詢USIF0101，須把手機門號儲存，因為若有帳單有接電費，會使用到手機門號。

 
let Taipower_URL_host : String = "www.taipower.com.tw"
let Taipower_URL_scheme : String = "http"


