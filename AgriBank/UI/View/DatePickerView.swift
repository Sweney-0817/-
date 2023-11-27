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

struct InputDatePickerStruct {
    var minDate:Date? = nil
    var maxDate:Date? = nil
    var curDate:Date? = nil
}

let DatePicker_Specific_Date = ["1日","2日","3日","4日","5日","6日","7日","8日","9日","10日",
                               "11日","12日","13日","14日","15日","16日","17日","18日","19日","20日",
                               "21日","22日","23日","24日","25日","26日","27日","28日","29日","30日","31日"]

class DatePickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    private var getTwoDate:((DatePickerStruct,DatePickerStruct,Date?,Date?)->())? = nil
    private var getOneDate:((DatePickerStruct)->())? = nil
    private var isSpecific = true
    
    // MARK: - Public
    func showTwoDatePickerView(_ isSpecific:Bool, _ inputDate1:InputDatePickerStruct?, _ inputDate2:InputDatePickerStruct?, getTwoDate: ((DatePickerStruct,DatePickerStruct,Date?,Date?)->())?) {
        self.getTwoDate = getTwoDate
        self.isSpecific = isSpecific
        self.backgroundColor = Disable_Color
        let scrollerview = UIScrollView(frame:  CGRect(origin: .zero, size: self.frame.size))
       
         
        
        
        let xStrart:CGFloat = 30
        let yStart:CGFloat = self.frame.size.height * 0.1//100
        let titleHeight:CGFloat = 30
        let space:CGFloat = 10
        let doneButtonHeight:CGFloat = 40
        let pickerWidth = frame.size.width - 2 * xStrart
        let pickerHeight:CGFloat = (self.frame.size.height * 0.7 - titleHeight * 2 - space * 2 - doneButtonHeight) / 2//200
        
       
 
        
//        let maxY = yStart + titleHeight*2 + pickerHeight*2 + space*2 + doneButtonHeight
//        if maxY > self.frame.maxY {
//            pickerHeight = 150
//        }
        
        let startLabel = UILabel(frame: CGRect(x: xStrart, y: yStart, width: pickerWidth, height: titleHeight))
        startLabel.text = "起始日"
         
        startLabel.font = Default_Font
        startLabel.backgroundColor = Green_Color
        startLabel.textAlignment = .center
        startLabel.textColor = .white
        scrollerview.addSubview(startLabel)
        
        let startDatePicker = isSpecific ? UIDatePicker(frame: CGRect(x: xStrart, y: startLabel.frame.maxY, width: pickerWidth, height: pickerHeight)) : UIPickerView(frame: CGRect(x: xStrart, y: startLabel.frame.maxY, width: pickerWidth, height: pickerHeight))
//        if #available(iOS 14.0, *) {
//            (startDatePicker as! UIDatePicker).preferredDatePickerStyle = .compact
//            (startDatePicker as! UIDatePicker).frame = CGRect(x: xStrart, y: startLabel.frame.maxY, width: pickerWidth, height: 40)
//            }
    
        
        if isSpecific {
            if #available(iOS 14.0, *) {
                if  let mymodelName:String? = UIDevice.modelName {
//                    if mymodelName == "iPhone 12 mini" || mymodelName ==  "Simulator iPhone 12 mini" {
//                        (startDatePicker as! UIDatePicker).preferredDatePickerStyle = .compact
//                        (startDatePicker as! UIDatePicker).frame =  CGRect(x: xStrart, y: startLabel.frame.maxY, width: pickerWidth, height: 40)
//                        startLabel.text = "起始日(請點選日期）"
//                    } else {
                        (startDatePicker as! UIDatePicker).preferredDatePickerStyle = .wheels
//                    }
                    
                }
               
            }
            (startDatePicker as! UIDatePicker).datePickerMode = .date
            (startDatePicker as! UIDatePicker).locale = Locale(identifier: "zh_CN")
            if inputDate1 != nil {
                (startDatePicker as! UIDatePicker).minimumDate = inputDate1!.minDate
                (startDatePicker as! UIDatePicker).maximumDate = inputDate1!.maxDate
                (startDatePicker as! UIDatePicker).date = inputDate1!.curDate ?? Date(timeIntervalSinceNow: TimeInterval(NSTimeZone.system.secondsFromGMT(for: Date())))
            }
        }
        else {
            (startDatePicker as! UIPickerView).dataSource = self
            (startDatePicker as! UIPickerView).delegate = self
            (startDatePicker as! UIPickerView).selectRow(0, inComponent: 0, animated: false)
        }
        startDatePicker.backgroundColor = .white
        startDatePicker.tag = ViewTag.View_StartDatePickerView.rawValue
       
        scrollerview.addSubview(startDatePicker)
        
        let endLabel = UILabel(frame: CGRect(x: xStrart, y: startDatePicker.frame.maxY+space, width: pickerWidth, height: titleHeight))
        endLabel.text = "截止日"
  
        endLabel.font = Default_Font
        endLabel.backgroundColor = Green_Color
        endLabel.textAlignment = .center
        endLabel.textColor = .white
        scrollerview.addSubview(endLabel)
        
        let endDatePicker = isSpecific ? UIDatePicker(frame: CGRect(x: xStrart, y: endLabel.frame.maxY, width: pickerWidth, height: pickerHeight)) : UIPickerView(frame: CGRect(x: xStrart, y: endLabel.frame.maxY, width: pickerWidth, height: pickerHeight))
      
        if isSpecific {
            if #available(iOS 14.0, *) {
                if  let mymodelName:String? = UIDevice.modelName {
//                    if mymodelName == "iPhone 12 mini" || mymodelName ==  "Simulator iPhone 12 mini"   {
//                (endDatePicker as! UIDatePicker).preferredDatePickerStyle = .compact
//                (endDatePicker as! UIDatePicker).frame =  CGRect(x: xStrart, y: endLabel.frame.maxY, width: pickerWidth, height: 40)
//                        endLabel.text = "截止日(請點選日期）"
//                    } else {
                        (endDatePicker as! UIDatePicker).preferredDatePickerStyle = .wheels
//                    }
                    
                }
               
            }
            (endDatePicker as! UIDatePicker).datePickerMode = .date
            (endDatePicker as! UIDatePicker).locale = Locale(identifier: "zh_CN")
            if inputDate2 != nil {
                (endDatePicker as! UIDatePicker).minimumDate = inputDate2!.minDate
                (endDatePicker as! UIDatePicker).maximumDate = inputDate2!.maxDate
                (endDatePicker as! UIDatePicker).date = inputDate2!.curDate ?? Date(timeIntervalSinceNow: TimeInterval(NSTimeZone.system.secondsFromGMT(for: Date())))
            }
        }
        else {
            (endDatePicker as! UIPickerView).dataSource = self
            (endDatePicker as! UIPickerView).delegate = self
            (endDatePicker as! UIPickerView).selectRow(0, inComponent: 0, animated: false)
        }

        endDatePicker.backgroundColor = .white
        endDatePicker.tag = ViewTag.View_EndDatePickerView.rawValue
        scrollerview.addSubview(endDatePicker)
        
        let button = UIButton(frame: CGRect(x: xStrart, y: endDatePicker.frame.maxY+space, width: pickerWidth, height: doneButtonHeight))
        button.setBackgroundImage(UIImage(named: ImageName.ButtonLarge.rawValue), for: .normal)
        button.tintColor = .white
        button.setTitle("確定", for: .normal)
        button.addTarget(self, action: #selector(clickTwoDateDetermineBtn(_:)), for: .touchUpInside)
        scrollerview.addSubview(button)
        addSubview(scrollerview)
        scrollerview.showsVerticalScrollIndicator = true
        scrollerview.isScrollEnabled = true
        //設定卷軸以防按鈕卡在下面
        scrollerview.contentSize = CGSize(
            width: self.frame.size.width  ,
            height: self.frame.size.height * 1.5)
        
    }
    
    func showOneDatePickerView(_ isSpecific:Bool, _ inputDate:InputDatePickerStruct?, getOneDate: ((DatePickerStruct)->())?) {
        self.getOneDate = getOneDate
        self.isSpecific = isSpecific
        self.backgroundColor = Disable_Color
        
        let xStrart:CGFloat = 30
        let yStart:CGFloat = frame.size.height / 3
        let pickerWidth = frame.size.width - 2*xStrart
        let pickerHeight:CGFloat = 200
        let titleHeight:CGFloat = 30
        let doneButtonHeight:CGFloat = 40
        let space:CGFloat = 10
        
        let startLabel = UILabel(frame: CGRect(x: xStrart, y: yStart, width: pickerWidth, height: titleHeight))
        startLabel.text = "特定日期"
        startLabel.font = Default_Font
        startLabel.backgroundColor = Green_Color
        startLabel.textAlignment = .center
        startLabel.textColor = .white
        addSubview(startLabel)
        
        let startDatePicker = isSpecific ? UIDatePicker(frame: CGRect(x: xStrart, y: startLabel.frame.maxY, width: pickerWidth, height: pickerHeight)) : UIPickerView(frame: CGRect(x: xStrart, y: startLabel.frame.maxY, width: pickerWidth, height: pickerHeight))
        if isSpecific {
            (startDatePicker as! UIDatePicker).datePickerMode = .date
            (startDatePicker as! UIDatePicker).locale = Locale(identifier: "zh_CN")
            if #available(iOS 14.0, *) {
             (startDatePicker as! UIDatePicker).preferredDatePickerStyle = .wheels
              }
            if inputDate != nil {
                (startDatePicker as! UIDatePicker).minimumDate = inputDate!.minDate
                (startDatePicker as! UIDatePicker).maximumDate = inputDate!.maxDate
                (startDatePicker as! UIDatePicker).date = inputDate!.curDate ?? Date(timeIntervalSinceNow: TimeInterval(NSTimeZone.system.secondsFromGMT(for: Date())))
            }
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
    @objc func clickTwoDateDetermineBtn(_ sender:Any) {
        var start = DatePickerStruct()
        var end = DatePickerStruct()
        if isSpecific {
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
                    getTwoDate!(start, end, startDate, endDate)
                    removeFromSuperview()
                }
                else {
                    let alert = UIAlertView(title: ErrorMsg_Choose_Date, message: nil, delegate: nil, cancelButtonTitle: "確定")
                    alert.show()
                }
            }
            else {
                removeFromSuperview()
            }
        }
        else {
            if let startPicker = self.viewWithTag(ViewTag.View_StartDatePickerView.rawValue) as? UIPickerView {
                start.day = DatePicker_Specific_Date[startPicker.selectedRow(inComponent: 0)]
            }
            if let endPicker = self.viewWithTag(ViewTag.View_EndDatePickerView.rawValue) as? UIPickerView {
                end.day = DatePicker_Specific_Date[endPicker.selectedRow(inComponent: 0)]
            }
            let startValue = Int(start.day.replacingOccurrences(of: "日", with: "")) ?? 0
            let endValue = Int(end.day.replacingOccurrences(of: "日", with: "")) ?? 0
            if startValue <= endValue {
                if getTwoDate != nil {
                    getTwoDate!(start, end, nil, nil)
                }
                removeFromSuperview()
            }
            else {
                let alert = UIAlertView(title: ErrorMsg_Choose_Date, message: nil, delegate: nil, cancelButtonTitle: "確定")
                alert.show()
            }
        }
    }
    
    @objc func clickOneDeteDetermineBtn(_ sender:Any) {
        var start = DatePickerStruct()
        if isSpecific {
            if let startPicker = self.viewWithTag(ViewTag.View_StartDatePickerView.rawValue) as? UIDatePicker {
                let componenets = Calendar.current.dateComponents([.year, .month, .day], from: startPicker.date)
                if let day = componenets.day, let month = componenets.month, let year = componenets.year {
                    start.day = String(format: "%02d", day)
                    start.month = String(format: "%02d", month)
                    start.year = String(year)
                }
            }
        }
        else {
            if let startPicker = self.viewWithTag(ViewTag.View_StartDatePickerView.rawValue) as? UIPickerView {
                start.day = DatePicker_Specific_Date[startPicker.selectedRow(inComponent: 0)]
            }
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
public extension UIDevice {

    static let modelName:String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPhone13,1":                              return "iPhone 12 mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4":                              return "iPhone 12 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                    return "iPad (8th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                    return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                    return "iPad Air (4th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "AudioAccessory5,1":                       return "HomePod mini"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}

