//
//  DeviceBindingViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import CoreLocation

let DeviceBindingResult_Segue = "GoDeviceBindingResult"
let DeviceBinding_Bank_Title = "農漁會"
let DeviceBinding_CheckCode_Length:Int = 7
let DeviceBinding_Binding_Success_Title = "綁定成功"
let DeviceBinding_Binding_Faild_Title = "綁定失敗"
let DeviceBinding_Memo = "恭喜您已成功綁定此設備！\n若想取消此設備綁定，\n請至本中心網路銀行網頁辦理。"

class DeviceBindingViewController: BaseViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var identifyTextfield: TextField!
    @IBOutlet weak var userCodeTextfield: TextField!
    @IBOutlet weak var podTextfield: TextField!
    @IBOutlet weak var checkCodeTextfield: TextField!
    @IBOutlet weak var bottomVIew: UIView!
    @IBOutlet weak var topTextfield: UITextField!
    
    private var topDropView:OneRowDropDownView? = nil
    private var bankList = [[String:[String]]]()
    private var bankCode = [String:String]()
    private var cityCode = [String:String]()
    private var bindingSuccess = false
    private var resultList:[[String:String]]? = nil
    private var curPickerRow1 = 0
    private var curPickerRow2 = 0
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topDropView = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topDropView?.setOneRow(DeviceBinding_Bank_Title, Choose_Title)
        topDropView?.m_lbFirstRowTitle.textAlignment = .center
        topView.addSubview(topDropView!)
        
        setShadowView(bottomVIew, .Top)
        addGestureForKeyBoard()
        
        getCanLoginBankInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! BasicInfoResultViewController
        controller.setInitial(resultList, bindingSuccess, bindingSuccess ? DeviceBinding_Binding_Success_Title : DeviceBinding_Binding_Faild_Title, bindingSuccess ? DeviceBinding_Memo : "")
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "COMM0403":
            if loginView != nil {
                super.didResponse(description, response)
                return
            }
            if let data = response.object(forKey: ReturnData_Key) as? [String : Any], let array = data["Result"] as? [[String:Any]] {
                for dic in array {
                    var bankNameList = [String]()
                    if let city = dic["hsienName"] as? String, let cityID = dic["hsienCode"] as? String, let list = dic["bankList"] as? [[String:Any]] {
                        for bank in list {
                            if let name = bank["bankName"] as? String {
                                bankNameList.append(name)
                                if let code = bank["bankCode"] as? String {
                                    bankCode["\(city)\(name)"] = code
                                }
                            }
                        }
                        bankList.append( [city:bankNameList] )
                        cityCode[city] = cityID
                    }
                }
            }
            
            if let cCode = SecurityUtility.utility.readFileByKey(SetKey: File_CityCode_Key, setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)") as? String, let bCode = SecurityUtility.utility.readFileByKey(SetKey: File_BankCode_Key, setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)") as? String {
                var city = ""
                for key in cityCode.keys {
                    if cityCode[key] == cCode {
                        city = key
                        break
                    }
                }
                var bank = ""
                for key in bankCode.keys {
                    if bankCode[key] == bCode {
                        bank = key.replacingOccurrences(of: city, with: "")
                        break
                    }
                }
                for index in 0..<bankList.count {
                    if let array = bankList[index][city] {
                        curPickerRow1 = index
                        for i in 0..<array.count {
                            if array[i] == bank {
                                curPickerRow2 = i
                                break
                            }
                        }
                        break
                    }
                }
                if !city.isEmpty && !bank.isEmpty {
                    topDropView?.setOneRow(DeviceBinding_Bank_Title, city + " " + bank)
                }
            }
            
        case "COMM0803":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode == ReturnCode_Success {
                setLoading(true)
                VaktenManager.sharedInstance().associationOperation(withAssociationCode: checkCodeTextfield.text ?? "") { resultCode in
                    self.setLoading(false)
                    if VIsSuccessful(resultCode) {
                        self.bindingSuccess = true
                        self.performSegue(withIdentifier: DeviceBindingResult_Segue, sender: self)
                    }
                    else {
                        self.resultList = [[String:String]]()
                        self.resultList?.append([Response_Key:Error_Title,Response_Value:"\(resultCode.rawValue)"])
                        self.performSegue(withIdentifier: DeviceBindingResult_Segue, sender: self)
                    }
                }
            }
            else {
                if let message = response.object(forKey:ReturnMessage_Key) as? String {
                    resultList = [[String:String]]()
                    resultList?.append([Response_Key:Error_Title,Response_Value:message])
                    self.performSegue(withIdentifier: DeviceBindingResult_Segue, sender: self)
                }
            }
            
        default: super.didResponse(description, response)
        }
    }
    
    // MARK: - Private
    private func addPickerView(_ textField:UITextField) {
        var frame = view.frame
        frame.origin.y = frame.maxY - PickView_Height
        frame.size.height = PickView_Height
        // UIPickerView
        let pickerView = UIPickerView(frame: frame)
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = .white
        pickerView.selectRow(curPickerRow1, inComponent: 0, animated: false)
        pickerView.selectRow(curPickerRow2, inComponent: 1, animated: false)
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barTintColor = ToolBar_barTintColor
        toolBar.tintColor = ToolBar_tintColor
        toolBar.sizeToFit()
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: Determine_Title, style: .plain, target: self, action: #selector(clickDoneBtn(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Cancel_Title, style: .plain, target: self, action: #selector(clickCancelBtn(_:)))
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: ToolBar_Title_Weight, height: toolBar.frame.height))
        titleLabel.textColor = .black
        titleLabel.text = Choose_Title
        titleLabel.textAlignment = .center
        let titleButton = UIBarButtonItem(customView: titleLabel)
        
        toolBar.setItems([cancelButton, spaceButton, titleButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        textField.inputView = pickerView
    }
    
    private func inputIsCorrect() -> Bool {
        if topDropView?.getContentByType(.First) == Choose_Title {
            showErrorMessage(nil, "\(Choose_Title)\(topDropView?.m_lbFirstRowTitle.text ?? "")")
            return false
        }
        if (identifyTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(identifyTextfield.placeholder ?? "")")
            return false
        }
        if !DetermineUtility.utility.isValidIdentify(identifyTextfield.text!) {
            showErrorMessage(nil, ErrorMsg_Error_Identify)
            return false
        }
        if (identifyTextfield.text?.count)! < Min_Identify_Length {
            showErrorMessage(nil, ErrorMsg_ID_LackOfLength)
            return false
        }
        if (userCodeTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(userCodeTextfield.placeholder ?? "")")
            return false
        }
        if (podTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(podTextfield.placeholder ?? "")")
            return false
        }
        if (checkCodeTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(checkCodeTextfield.placeholder ?? "")")
            return false
        }
        return true
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == topTextfield {
            if bankList.count > 0 {
                addPickerView(textField)
            }
            textField.tintColor = .clear
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == identifyTextfield || textField == userCodeTextfield || textField == podTextfield {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if !DetermineUtility.utility.isEnglishAndNumber(newString) {
                return false
            }
        }
        let newLength = (textField.text?.count)! - range.length + string.count
        var maxLength = 0
        switch textField {
        case identifyTextfield:
            maxLength = Max_Identify_Length
            
        case userCodeTextfield, podTextfield:
            maxLength = Max_ID_Pod_Length
            
        case checkCodeTextfield:
            maxLength = DeviceBinding_CheckCode_Length
            
        default: break
        }
        
        if newLength <= maxLength {
            return true
        }
        else {
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickBindingBtn(_ sender: Any) {
//        let location: CLLocation = (UIApplication.shared.delegate as! AppDelegate).m_location
//        guard (location.coordinate.latitude != 0.0 && location.coordinate.longitude != 0.0) else {
//            showAlert(title: UIAlert_Default_Title, msg: "無法取得您的位置，請開啟GPS或網路定位服務", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
//            return
//        }
        if inputIsCorrect() {
            //109-10-16 add by sweney for check e2e key
                       if E2EKeyData == "" {
                                        showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_NoKeyAdConnection, confirmTitle: "確認", cancleTitle: nil, completionHandler: {exit(0)}, cancelHandelr: {()})
                                  }else{
            setLoading(true)
            let uuid = UUID().uuidString
            VaktenManager.sharedInstance().authenticateOperation(withSessionID: uuid) { resultCode in
                if VIsSuccessful(resultCode) {
                    let bankCode = self.bankCode[self.topDropView?.getContentByType(.First).replacingOccurrences(of: " ", with: "") ?? ""] ?? ""
                   let id = SecurityUtility.utility.MD5(string: self.userCodeTextfield.text!)
                    //let pd = SecurityUtility.utility.MD5(string: self.podTextfield.text!)
                    //E2E
                    // let fmt = DateFormatter()
                     //let timeZone = TimeZone.ReferenceType.init(abbreviation:"UTC") as TimeZone?
                     //fmt.timeZone = timeZone
                     //fmt.dateFormat = "yyyy/MM/dd HH:mm:ss"
                     //let loginDateTIme: String = fmt.string(from: Date())
                     let loginDateTIme: String = Date().date2String(dateFormat: "yyyy/MM/dd HH:mm:ss")
                    let pd = E2E.e2Epod(E2EKeyData, pod:self.podTextfield.text! + loginDateTIme)
                   
                    self.postRequest("COMM/COMM0803", "COMM0803", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08011","Operate":"queryData","BR_CODE":bankCode,"ID_DATA":self.identifyTextfield.text!,"USER_ID":id,"PWD":pd as Any,"ASSOCIATIONCODE":self.checkCodeTextfield.text!,"SessionId":uuid], true), AuthorizationManage.manage.getHttpHead(true))
                }
                else {
                    self.showErrorMessage(nil, "\(ErrorMsg_Verification_Faild) \(resultCode.rawValue)")
                    self.setLoading(false)
                }
            }
            }
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return bankList.count
        }
        else {
            let dic = bankList[curPickerRow1]
            let city = [String](dic.keys).first ?? ""
            return dic[city]?.count ?? 0
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let dic = bankList[row]
            return [String](dic.keys).first
        }
        else {
            if pickerView.selectedRow(inComponent: 0) < bankList.count {
                let dic = bankList[pickerView.selectedRow(inComponent: 0)]
                let city = [String](dic.keys).first ?? ""
                if let count = dic[city]?.count, row < count {
                    return dic[city]?[row]
                }
            }
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            curPickerRow1 = row
            curPickerRow2 = 0
            pickerView.reloadComponent(1)
            pickerView.selectRow(curPickerRow2, inComponent: 1, animated: false)
        }
        else {
            curPickerRow2 = row
        }
    }
    
    // MARK: - selector
    func clickCancelBtn(_ sender:Any) {
        topTextfield.resignFirstResponder()
    }
    
    func clickDoneBtn(_ sender:Any) {
        let pickerView = topTextfield.inputView as! UIPickerView
        let dic = bankList[pickerView.selectedRow(inComponent: 0)]
        let city = [String](dic.keys).first ?? ""
        let place = dic[city]?[pickerView.selectedRow(inComponent: 1)] ?? ""
        topDropView?.setOneRow(DeviceBinding_Bank_Title, city + " " + place)
        topTextfield.resignFirstResponder()
    }
    
    // MARK: - LoginDelegate
    override func clickLoginCloseBtn() {
        /* 避免手勢被清除 and 把Observer移除 */
        loginView?.removeFromSuperview()
        loginView = nil
        curFeatureID = nil
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
