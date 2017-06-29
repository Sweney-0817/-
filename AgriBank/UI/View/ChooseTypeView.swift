//
//  ChooseTypeView.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

protocol ChooseTypeDelegate{
    func clickChooseTypeBtn(_ name:String)
}

let ChooseType_Width = CGFloat(100)
let ChooseType_Font_Size = UIFont.systemFont(ofSize: 18)

class ChooseTypeView: UIView {
    private var scrollView:UIScrollView? = nil
    private var delegate:ChooseTypeDelegate? = nil
    private var currentIndex:Int = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollView = UIScrollView(frame: CGRect(origin: .zero, size: frame.size))
        scrollView?.backgroundColor = .white
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.bounces = false
        scrollView?.autoresizesSubviews = false
        addSubview(scrollView!)
    }
    
    func setTypeList(_ list:[String]?, setDelegate delegate:ChooseTypeDelegate?) {
        scrollView?.subviews.forEach{ view in view.removeFromSuperview() }
        self.delegate = delegate
        if list != nil {
            let width = CGFloat((list?.count)!)*ChooseType_Width
            scrollView?.contentSize = CGSize(width: (frame.width > width ? frame.width : width), height: 0)
            for index in 1...(list?.count)! {
                let button = UIButton(frame: CGRect(x: CGFloat(index-1)*ChooseType_Width, y: 0, width: ChooseType_Width, height: (scrollView?.frame.size.height)!))
                button.tag = index
                button.addTarget(self, action: #selector(clickTypeBtn(_:)), for: .touchUpInside)
                button.setTitle(list?[index-1], for: .normal)
                button.titleLabel?.font = ChooseType_Font_Size
                if index == currentIndex {
                    button.setTitleColor(.white, for: .normal)
                    button.backgroundColor = Orange_Color
                }
                else {
                    button.setTitleColor(.black, for: .normal)
                    button.backgroundColor = .white
                }

                scrollView?.addSubview(button)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView?.frame = CGRect(origin: .zero, size: frame.size)
        scrollView?.contentInset = .zero
    }
  
    // MARK: - selecotr
    func clickTypeBtn(_ sender:Any) {
        let currentBtn = scrollView?.viewWithTag(currentIndex) as! UIButton
        currentBtn.setTitleColor(.black, for: .normal)
        currentBtn.backgroundColor = .white
        
        let button = sender as! UIButton
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Orange_Color
        currentIndex = button.tag
        
        delegate?.clickChooseTypeBtn((button.titleLabel?.text)!)
    }
}
