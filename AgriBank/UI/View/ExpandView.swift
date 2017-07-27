//
//  ExpandView.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/19.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class ExpandView: UIView {
    @IBOutlet weak var transBtn: UIButton!
    @IBOutlet weak var detailBtn: UIButton!

    // MARK - Public
    func SetStatus(_ transStaus: Bool, _ detailStatus: Bool) {
        transBtn.isEnabled = transStaus
        if !transStaus {
            transBtn.backgroundColor = Gray_Color
        }
        else {
            transBtn.backgroundColor = .clear
        }
        detailBtn.isEnabled = detailStatus
        if !detailStatus {
            detailBtn.backgroundColor = Gray_Color
        }
        else {
            detailBtn.backgroundColor = .clear
        }
    }
}
