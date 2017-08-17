//
//  DatePickerView.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/8/17.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

struct DatePickerStruct {
    var year = ""
    var month = ""
    var day = ""
}

let DatePicker_Specific_Date = ["1日","2日","3日","4日","5日","6日","7日","8日","9日","10日",
                               "11日","12日","13日","14日","15日","16日","17日","18日","19日","20日",
                               "21日","22日","23日","24日","25日","26日","27日","28日","29日","30日","31日"]

class DatePickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    private var getTwoDate:((DatePickerStruct,DatePickerStruct)->())? = nil
    private var getOneDate:((DatePickerStruct)->())? = nil
    
    // MARK: - Public
    func showTwoDatePickerView(getTwoDate: ((DatePickerStruct,DatePickerStruct)->())?) {
        self.getTwoDate = getTwoDate
        self.backgroundColor = Disable_Color
        
        let xStrart:CGFloat = 30
        let yStart:CGFloat = 100
        let pickerWidth = frame.size.width - 2*xStrart
        var pickerHeight:CGFloat = 200
        let titleHeight:CGFloat = 30
        let doneButtonHeight:CGFloat = 40
        let space:CGFloat = 10
        
        let maxY = yStart + titleHeight*2 + pickerHeight*2 + space*2
        if maxY > self.frame.maxY {
            pickerHeight = 150
        }
        
        let startLabel = UILabel(frame: CGRect(x: xStrart, y: yStart, width: pickerWidth, height: titleHeight))
        startLabel.text = "起始日"
        startLabel.font = Cell_Font_Size
        startLabel.backgroundColor = Green_Color
        startLabel.textAlignment = .center
        startLabel.textColor = .white
        addSubview(startLabel)
        
        let startDatePicker = UIDatePicker(frame: CGRect(x: xStrart, y: startLabel.frame.maxY, width: pickerWidth, height: pickerHeight))
        startDatePicker.datePickerMode = .date
        startDatePicker.locale = Locale(identifier: "zh_CN")
        startDatePicker.backgroundColor = .white
        startDatePicker.tag = ViewTag.View_StartDatePickerView.rawValue
        addSubview(startDatePicker)
        
        let endLabel = UILabel(frame: CGRect(x: xStrart, y: startDatePicker.frame.maxY+space, width: pickerWidth, height: titleHeight))
        endLabel.text = "截止日"
        endLabel.font = Cell_Font_Size
        endLabel.backgroundColor = Green_Color
        endLabel.textAlignment = .center
        endLabel.textColor = .white
        addSubview(endLabel)
        
        let endDatePicker = UIDatePicker(frame: CGRect(x: xStrart, y: endLabel.frame.maxY, width: pickerWidth, height: pickerHeight))
        endDatePicker.backgroundColor = .white
        endDatePicker.datePickerMode = .date
        endDatePicker.locale = Locale(identifier: "zh_CN")
        endDatePicker.tag = ViewTag.View_EndDatePickerView.rawValue
        addSubview(endDatePicker)
        
        let button = UIButton(frame: CGRect(x: xStrart, y: endDatePicker.frame.maxY+space, width: pickerWidth, height: doneButtonHeight))
        button.setBackgroundImage(UIImage(named: ImageName.ButtonLarge.rawValue), for: .normal)
        button.tintColor = .white
        button.setTitle("確定", for: .normal)
        button.addTarget(self, action: #selector(clickTwoDateDetermineBtn(_:)), for: .touchUpInside)
        addSubview(button)
    }
    
    func showOneDatePickerView(_ isSpecific:Bool, getOneDate: ((DatePickerStruct)->())?) {
        self.getOneDate = getOneDate
        self.backgroundColor = Disable_Color
        
        let xStrart:CGFloat = 30
        let yStart:CGFloat = frame.midY
        let pickerWidth = frame.size.width - 2*xStrart
        let pickerHeight:CGFloat = 200
        let titleHeight:CGFloat = 30
        let doneButtonHeight:CGFloat = 40
        let space:CGFloat = 10
        
        let startLabel = UILabel(frame: CGRect(x: xStrart, y: yStart, width: pickerWidth, height: titleHeight))
        startLabel.text = "特定日期"
        startLabel.font = Cell_Font_Size
        startLabel.backgroundColor = Green_Color
        startLabel.textAlignment = .center
        startLabel.textColor = .white
        addSubview(startLabel)
        
        let startDatePicker = isSpecific ? UIDatePicker(frame: CGRect(x: xStrart, y: startLabel.frame.maxY, width: pickerWidth, height: pickerHeight)) : UIPickerView(frame: CGRect(x: xStrart, y: startLabel.frame.maxY, width: pickerWidth, height: pickerHeight))
        if isSpecific {
            (startDatePicker as! UIDatePicker).datePickerMode = .date
            (startDatePicker as! UIDatePicker).locale = Locale(identifier: "zh_CN")
        }
        else {
            (startDatePicker as! UIPickerView).dataSource = self
            (startDatePicker as! UIPickerView).delegate = self
            (startDatePicker as! UIPickerView).selectRow(0, inComponent: 0, animated: false)
        }
        startDatePicker.backgroundColor = .white
        startDatePicker.tag = ViewTag.View_StartDatePickerView.rawValue
        addSubview(startDatePicker)
        
        let button = UIButton(frame: CGRect(x: xStrart, y: startDatePicker.frame.maxY+space, width: pickerWidth, height: doneButtonHeight))
        button.setBackgroundImage(UIImage(named: ImageName.ButtonLarge.rawValue), for: .normal)
        button.tintColor = .white
        button.setTitle("確定", for: .normal)
        button.addTarget(self, action: #selector(clickOneDeteDetermineBtn(_:)), for: .touchUpInside)
        addSubview(button)
    }

    // MARK: - Selector
    func clickTwoDateDetermineBtn(_ sender:Any) {
        var start = DatePickerStruct()
        var end = DatePickerStruct()
        var startDate:Date? = nil
        var endDate:Date? = nil
        if let startPicker = self.viewWithTag(ViewTag.View_StartDatePickerView.rawValue) as? UIDatePicker {
            let componenets = Calendar.current.dateComponents([.year, .month, .day], from: startPicker.date)
            if let day = componenets.day, let month = componenets.month, let year = componenets.year {
                startDate = startPicker.date
                start.day = String(format: "%02d", day)
                start.month = String(format: "%02d", month)
                start.year = String(year)
            }
        }
        
        if let endPicker = self.viewWithTag(ViewTag.View_EndDatePickerView.rawValue) as? UIDatePicker {
            let componenets = Calendar.current.dateComponents([.year, .month, .day], from: endPicker.date)
            if let day = componenets.day, let month = componenets.month, let year = componenets.year {
                endDate = endPicker.date
                end.day = String(format: "%02d", day)
                end.month = String(format: "%02d", month)
                end.year = String(year)
            }
        }
        
        if startDate != nil && endDate != nil && getTwoDate != nil {
            if startDate! <= endDate! {
                getTwoDate!(start, end)
                removeFromSuperview()
            }
            else {
                let alert = UIAlertView(title: "起始日不可大於截止日", message: nil, delegate: nil, cancelButtonTitle: "確定")
                alert.show()
            }
        }
        else {
            removeFromSuperview()
        }
    }
    
    func clickOneDeteDetermineBtn(_ sender:Any) {
        var start = DatePickerStruct()
        if let startPicker = self.viewWithTag(ViewTag.View_StartDatePickerView.rawValue) as? UIDatePicker {
            let componenets = Calendar.current.dateComponents([.year, .month, .day], from: startPicker.date)
            if let day = componenets.day, let month = componenets.month, let year = componenets.year {
                start.day = String(format: "%02d", day)
                start.month = String(format: "%02d", month)
                start.year = String(year)
            }
        }
        if let startPicker = self.viewWithTag(ViewTag.View_StartDatePickerView.rawValue) as? UIPickerView {
            start.day = DatePicker_Specific_Date[startPicker.selectedRow(inComponent: 0)]
        }
        
        if getOneDate != nil {
            getOneDate!(start)
        }
        removeFromSuperview()
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DatePicker_Specific_Date.count
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return DatePicker_Specific_Date[row]
    }
}
