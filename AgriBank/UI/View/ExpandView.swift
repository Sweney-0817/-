//
//  ExpandView.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/19.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class ExpandView: UIView {
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var titleLabel2: UILabel!
    
    // MARK - Public
    func SetStatus(_ status1: Bool, _ status2: Bool) {
        if !status1 {
            button1.backgroundColor = Disable_Color
        }
        else {
            button1.backgroundColor = .clear
        }
        if !status2 {
            button2.backgroundColor = Disable_Color
        }
        else {
            button2.backgroundColor = .clear
        }
    }
    
    func SetLabelTitle(_ title1:String, _ title2:String) {
        titleLabel1.text = title1
        titleLabel2.text = title2
    }
}
