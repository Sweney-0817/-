//
//  MemoView.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/6/22.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class MemoView: UIView {
    @IBOutlet weak var m_lbMemo: UILabel!
    func set(_ memo:String) {
        m_lbMemo.text = memo
    }
    
    static func GetStringHeightByWidthAndFontSize(_ content:String, _ width:CGFloat) -> CGFloat {
        //.xib拉的
        let dataWidth = width-(8*2)
        let plusHeight:CGFloat = 20+8+5
        
        //        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: dataWidth, height: CGFloat.greatestFiniteMagnitude))
        //        label.numberOfLines = 0
        //        label.lineBreakMode = NSLineBreakMode.byWordWrapping//        label.font = UIFont.systemFont(ofSize: 18.0)
        //        label.text = content
        //        label.sizeToFit()
        //        return label.frame.height+plusHeight
        
        let boundingBox = content.boundingRect(with: CGSize(width: dataWidth, height: .greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: Default_Font], context: nil)
        return boundingBox.height+plusHeight
    }
}
