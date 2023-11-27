//
//  LoginView.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/13.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import LocalAuthentication 

let Login_Mask_Range = NSRange(location: 4, length: 3)
let Login_Mask = "***"

struct LoginStrcture {
    /// 農漁會代碼
    var bankCode = ""
    /// 身分證
    var aot = ""
    /// 使用者代碼
    var id = ""
    /// 使用者密碼
    var pod = ""
    /// 圖形驗證碼
    var imgPod = ""
    /// 縣市代碼
    var cityCode = ""
}

protocol LoginDelegate {
    func clickLoginBtn(_ info:LoginStrcture)
    func clickFastLogInBtn(_ bankCode:String ,_ account:String,  success:NSInteger)
    func clickLoginRefreshBtn()
    func clickLoginCloseBtn()
    func clickLoadBtn()
    func clickGestureShowBtn(_ info:LoginStrcture)
}
enum BiometryType : Int {
    case none
    case touchID
    case faceID
}

class LoginView:  UIView, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, ImageConfirmViewDelegate  {
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var aotTextfield: UITextField!   // aot
    @IBOutlet weak var idTextfield: UITextField!        // 使用者代碼
    @IBOutlet weak var podTextfield: UITextField!  // 使用者密碼
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageConfirmView: UIView!
    @IBOutlet weak var checkImg: UIImageView!
    
    @IBOutlet weak var BtnLogin: UIButton!
    @IBOutlet weak var BtnFLogIn: UIButton!
    var delegate:LoginDelegate? = nil
    private var request:ConnectionUtility? = nil
    private var list = [[String:[String]]]()
    private var bankCode = [String:String]()
    private var cityCode = [String:String]()
    private var isCheckon = false
    private var currentTextField:UITextField? = nil
    private var loginInfo = LoginStrcture()
    private var imgConfirm:ImageConfirmView? = nil
    private var sAot = ""
    private var curPickerRow1 = 0
    private var curPickerRow2 = 0
    //2019-10-21 add by sweney 快速登入
    var context = LAContext()
    var GesturePwdView:GesturePwd? = nil     // 圖形密碼頁
    //for 快登 - 判斷裝置支援face id or touch id
 
    var Login_layout_show = false

    // MARK: - Override
    override func layoutSubviews() {
        super.layoutSubviews()
        // 2019-12-5 按鈕改色快設定圓角
        BtnLogin.layer.cornerRadius = 5.0
         BtnFLogIn.layer.cornerRadius = 5.0
        BtnLogin.layer.masksToBounds = true
        BtnFLogIn.layer.masksToBounds = true
        // 2019-12-5 end
        
        //IOS 15 frame有異動時會引發layoutsubviews 增加load判斷 add by sweney
        if Login_layout_show == false {
        imgConfirm = Platform.plat.getUIByID(.UIID_ImageConfirmView) as? ImageConfirmView
        imgConfirm?.frame = imageConfirmView.frame
        imgConfirm?.frame.origin = .zero
        
        imgConfirm?.delegate = self
        imageConfirmView.addSubview(imgConfirm!)
        contentView.layer.cornerRadius = Layer_BorderRadius
        
      
        //ADD by Chiu 20201118
        //將舊ＩＤ儲存於userdefault內資料刪除(已改儲存keychain)
        SecurityUtility.utility.writeFileByKey(nil, SetKey: File_Account_Key)
        if let IDAccount =  KeychainManager.keyChainReadData(identifier: File_Account_Key) as? String{
            if (IDAccount.count >= 7){
                  isCheckon = true
                  sAot = IDAccount
               }
                else{
                      isCheckon = false
                      sAot = ""
                 }
        }

        if isCheckon {
                   KeychainManager.keyChianDelete(identifier: File_Account_Key)
                   KeychainManager.keyChainSaveData(data:sAot, withIdentifier: File_Account_Key)
            
                   if (sAot.count >= 7) {
                    aotTextfield.text = (sAot as NSString).replacingCharacters(in: Login_Mask_Range, with: Login_Mask)
                   }
                   checkImg.image = UIImage(named: ImageName.Checkon.rawValue)
               }
               else {
                   //keychain act check 第三方實驗室檢測建議修改
                   //chiu add 20201118
                   if let IDAccount =  KeychainManager.keyChainReadData(identifier: File_Account_Key) as? String{
                       let sAot = IDAccount
                       if (sAot.count >= 7 ){
                        aotTextfield.text = (sAot as NSString).replacingCharacters(in: Login_Mask_Range, with: Login_Mask)}
                       checkImg.image = UIImage(named: ImageName.Checkon.rawValue)
                       isCheckon = true
                   }else{
                       checkImg.image = UIImage(named: ImageName.Checkoff.rawValue)
                       isCheckon = false
                   }
               }
        //2019-12-6 add device check for fast login
        }
        Login_layout_show = true
        
#if DEBUG
        idTextfield.text = "agri2968"
        podTextfield.text = "bank2968"
#endif
    }
   
    
    // MARK: - Public
    func setInitialList(_ list:[[String:[String]]], _ bankCode:[String:String], _ cityCode:[String:String]) {
        self.list = list
        self.bankCode = bankCode
        self.cityCode = cityCode
        
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
                  // bank = key.replacingOccurrences(of: city, with: "")
                    //2019-12-2 edit by sweney 基隆市農會單位會錯，改去除前3個字
                   bank = key.substring(from: 3)
                    break
                }
            }
            for index in 0..<list.count {
                if let array = list[index][city] {
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
                locationTextfield.text = city + " " + bank
            }
        }      
    }
    
    func isNeedRise() -> Bool { // 畫面是否需要提高
        if currentTextField == locationTextfield || currentTextField == aotTextfield {
            return false
        }
        
        return true
    }
    
    func setImageConfirm(_ image:UIImage?) { // 設圖形驗證碼
        imgConfirm?.m_ivShow.image = image
    }
    
    func cleanImageConfirmText() { // 重設圖形驗證碼文字
        imgConfirm?.m_tfInput.text = ""
    }
    
    func saveDataInFile() { // 登入成功後，儲存登入成功的農漁會代碼
        if isCheckon {
             
            //將Accounte改存到keychain
            //chiu add 20201118
            KeychainManager.keyChianDelete(identifier: File_Account_Key)
            let superDuperSecret = loginInfo.aot
            KeychainManager.keyChainSaveData(data:superDuperSecret, withIdentifier: File_Account_Key)

        }
        else {
           
             KeychainManager.keyChianDelete(identifier: File_Account_Key)
        }
        SecurityUtility.utility.writeFileByKey(loginInfo.cityCode, SetKey: File_CityCode_Key, setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
        SecurityUtility.utility.writeFileByKey(loginInfo.bankCode, SetKey: File_BankCode_Key, setEncryptKey: "\(SEA1)\(SEA2)\(SEA3)")
    }
      
    // MARK: - Private
    private func addPickerView(_ textField:UITextField) {
        var frame = self.frame
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
    
    private func inputIsCorrect() -> String? {
        if (locationTextfield.text?.isEmpty)! {
            return ErrorMsg_Choose_CityBank
        }
        if (sAot.isEmpty) {
            if (aotTextfield.text?.isEmpty)! {
                return "\(Enter_Title)\(aotTextfield.placeholder ?? "")"
            }
            if (aotTextfield.text?.count)! < Min_Identify_Length {
                return ErrorMsg_ID_LackOfLength
            }
            if !DetermineUtility.utility.isValidIdentify(aotTextfield.text!) {
                return ErrorMsg_Error_Identify
            }
        }
        else {
            if sAot.count < Min_Identify_Length {
                return ErrorMsg_ID_LackOfLength
            }
            if !DetermineUtility.utility.isValidIdentify(sAot) {
                return ErrorMsg_Error_Identify
            }
        }
        //        if sAot.isEmpty {
        //            return "\(Enter_Title)\(aotTextfield.placeholder ?? "")"
        //        }
        //        if sAot.count < Min_Identify_Length {
        //            return ErrorMsg_ID_LackOfLength
        //        }
        //        if !DetermineUtility.utility.isValidIdentify(sAccount) {
        //            return ErrorMsg_Error_Identify
        //        }
        if (idTextfield.text?.isEmpty)! {
            return "\(Enter_Title)\(idTextfield.placeholder ?? "")"
        }
        if (podTextfield.text?.isEmpty)! {
            return "\(Enter_Title)\(podTextfield.placeholder ?? "")"
        }
        
        return nil
    }
    
 //2019-10-21 add by sweney for fastlogin

    private func FastLogIninputIsCorrect() -> String? {
        if (locationTextfield.text?.isEmpty)! {
            return ErrorMsg_Choose_CityBank
        }
        if (sAot.isEmpty) {
            if (aotTextfield.text?.isEmpty)! {
                return "\(Enter_Title)\(aotTextfield.placeholder ?? "")"
            }
            if (aotTextfield.text?.count)! < Min_Identify_Length {
                return ErrorMsg_ID_LackOfLength
            }
            if !DetermineUtility.utility.isValidIdentify(aotTextfield.text!) {
                return ErrorMsg_Error_Identify
            }
        }
        else {
            if sAot.count < Min_Identify_Length {
                return ErrorMsg_ID_LackOfLength
            }
            if !DetermineUtility.utility.isValidIdentify(sAot) {
                return ErrorMsg_Error_Identify
            }
        }
        
        
        return nil
    }
 //2019-10-21 end 

    // MARK: - Xib Touch Event
    @IBAction func clickCloseBtn(_ sender: Any) {
        delegate?.clickLoginCloseBtn()
    }
    
    @IBAction func clickLoginBtn(_ sender: Any) {
        if let message = inputIsCorrect() {
            let alert = UIAlertView(title: UIAlert_Default_Title, message: message, delegate: nil, cancelButtonTitle:Determine_Title)
            alert.show()
        }
        else {
            self.endEditing(true)
            loginInfo.bankCode = bankCode[locationTextfield.text?.replacingOccurrences(of: " ", with: "") ?? ""] ?? loginInfo.bankCode
            loginInfo.aot = sAot.isEmpty ? aotTextfield.text! : sAot
            loginInfo.id = idTextfield.text ?? loginInfo.id
            loginInfo.pod = podTextfield.text ?? loginInfo.pod
            let city = locationTextfield.text?.components(separatedBy: " ").first ?? ""
            loginInfo.cityCode = cityCode[city] ?? loginInfo.cityCode
            delegate?.clickLoginBtn(loginInfo)
        }
    }
    //2019-10-21 add by sweney 快速登入
    @IBAction func clickFastLogInBtn(_ sender: Any) {
        InitFastLogIn(true)
    }
   
    
    @IBAction func clickLoadBtn(_ sender: Any) {
        self.delegate?.clickLoadBtn()
    }
    
    func TouchIDLogIn () {
        self.context = LAContext()
        //let TouchErConter = 0
        if #available(iOS 10.0, *) {
            context.localizedCancelTitle = "取消"
        }
        // First check if we have the needed hardware support.
        var error: NSError?
        if #available(iOS 9.0, *) {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                
                let reason = "請使用指紋驗證登入"
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason )
                {
                    success, error in
                    
                    if success {
                        //回到主執行緒
                        OperationQueue.main.addOperation {
                            AuthorizationManage.manage.SetLoginInfo(self.loginInfo)
                            self.delegate?.clickFastLogInBtn(self.loginInfo.bankCode,self.loginInfo.aot,success: 1)
                        }
                    } else  {
                    }
                }
            } else {
                let alert = UIAlertView(title: UIAlert_Default_Title, message: "裝置無法使用快速登入，請使用帳號密碼登入！", delegate: nil, cancelButtonTitle:Determine_Title)
                alert.show()
            }
        } else {
            let alert = UIAlertView(title: UIAlert_Default_Title, message: "裝置不支援指紋/臉部辨識快速登入", delegate: nil, cancelButtonTitle:Determine_Title)
            alert.show()
        }
    }
    
    //end
    @IBAction func clickCheckBtn(_ sender: Any) {
        isCheckon = !isCheckon
        if isCheckon {
            checkImg.image = UIImage(named: ImageName.Checkon.rawValue)
        }
        else {
            checkImg.image = UIImage(named: ImageName.Checkoff.rawValue)
        }
    }
    
    // MARK: - selector
    @objc func clickCancelBtn(_ sender:Any) {
        locationTextfield.resignFirstResponder()
    }
    
    @objc func clickDoneBtn(_ sender:Any) {
        let pickerView = locationTextfield.inputView as! UIPickerView
        let dic = list[pickerView.selectedRow(inComponent: 0)]
        let city = [String](dic.keys).first ?? ""
        let place = dic[city]?[pickerView.selectedRow(inComponent: 1)] ?? ""
        locationTextfield.text = city + " " + place
        locationTextfield.resignFirstResponder()

    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        currentTextField = nil
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        if textField == locationTextfield {
            if list.count != 0 {
                addPickerView(textField)
                textField.tintColor = .clear
            }
            else {
                return false
            }
        }
        else if (textField == aotTextfield) {
            textField.text = ""
            sAot = ""
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == idTextfield || textField == podTextfield {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if !DetermineUtility.utility.isEnglishAndNumber(newString) {
                return false
            }
        }
        
        let newLength = (textField.text?.count)! - range.length + string.count
        var maxLength = 0
        
        if textField == aotTextfield {
            maxLength = Max_Identify_Length
            if newLength <= maxLength {
                return true
            }
            else {
                return false
            }
            //            if (textField.markedTextRange != nil) {
            //                if !DetermineUtility.utility.isEnglishAndNumber(string) {
            //                    textField.text = (sAot as NSString).replacingCharacters(in: Login_Mask_Range, with: Login_Mask)
            //                    return false
            //                }
            //                else {
            //                    NSLog("[%@][%@]", sAot, string)
            //                    let replaceRange = NSRange.init(location: range.location, length: 0)
            //                    let newString = (sAot as NSString).replacingCharacters(in: replaceRange, with: string)
            //                    if newString.count <= Max_Identify_Length {
            //                        sAot = newString
            //                        return true
            //                    }
            //                    else {
            //                        return true
            //                    }
            //                }
            //            }
            //            else {
            //                let newString = (sAot as NSString).replacingCharacters(in: range, with: string)
            //                if !DetermineUtility.utility.isEnglishAndNumber(newString) {
            //                    return false
            //                }
            //                if newLength <= Max_Identify_Length {
            //                    sAot = newString
            //                    return true
            //                }
            //                else {
            //                    return false
            //                }
            //            }
        }
        else {
            switch textField {
            case idTextfield, podTextfield:
                maxLength = Max_ID_Pod_Length
                
            default: break
            }
            
            if newLength <= maxLength {
                return true
            }
            else {
                return false
            }
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return list.count
        }
        else {
            let dic = list[curPickerRow1]
            let city = [String](dic.keys).first ?? ""
            return dic[city]?.count ?? 0
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            let dic = list[row]
            return [String](dic.keys).first
        }
        else {
            if pickerView.selectedRow(inComponent: 0) < list.count {
                let dic = list[pickerView.selectedRow(inComponent: 0)]
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
    
    // MARK: - ImageConfirmViewDelegate
    func clickRefreshBtn() {
        delegate?.clickLoginRefreshBtn()
    }
    
    func clickLoadBtn() {
        delegate?.clickLoadBtn()
    }
    func changeInputTextfield(_ input: String){
        loginInfo.imgPod = input
    }
    
    func ImageConfirmTextfieldBeginEditing(_ textfield:UITextField) {
        currentTextField = textfield
    }
    
    func InitFastLogIn (_ BolShowMsg:Bool){
        #if DEBUG
        #else
        if SecurityUtility.utility.isJailBroken() {
            if (BolShowMsg == true ){
            let alert = UIAlertView(title: UIAlert_Default_Title, message: ErrorMsg_IsJailBroken, delegate: nil, cancelButtonTitle:Determine_Title)
            alert.show()
            }
            return
        }
        #endif
        if let message = FastLogIninputIsCorrect() {
             if (BolShowMsg == true ){
            let alert = UIAlertView(title: UIAlert_Default_Title, message: message, delegate: nil, cancelButtonTitle:Determine_Title)
            alert.show()
            }
        }
        else {
            self.endEditing(true)
            loginInfo.bankCode = bankCode[locationTextfield.text?.replacingOccurrences(of: " ", with: "") ?? ""] ?? loginInfo.bankCode
            loginInfo.aot = sAot.isEmpty ? aotTextfield.text! : sAot
            let city = locationTextfield.text?.components(separatedBy: " ").first ?? ""
            loginInfo.cityCode = cityCode[city] ?? loginInfo.cityCode
            
            var wkFastLogInFlag = "0"
            wkFastLogInFlag = SecurityUtility.utility.readFileByKey( SetKey: loginInfo.bankCode     , setDecryptKey: "\(SEA1)\(SEA2)\(SEA3)")  as? String ?? "0"
            let  wkLogInCode = wkFastLogInFlag.substring(from: 0, length: 1)
            let wkID = wkFastLogInFlag.substring(from: 1)
            if (wkFastLogInFlag == "00000000000"){
                 if (BolShowMsg == true ){
                let alert = UIAlertView(title: UIAlert_Default_Title, message: "此裝置快速登入已停用，請重新設定快速登入。", delegate: nil, cancelButtonTitle:Determine_Title)
                alert.show()
                }
            }else
            if wkID.localizedUppercase != String(sAot.isEmpty ? aotTextfield.text! : sAot).localizedUppercase && (wkID != "") {
                     if (BolShowMsg == true ){
                    let alert = UIAlertView(title: UIAlert_Default_Title, message: "此身分證字號尚位設定快速登入！", delegate: nil, cancelButtonTitle:Determine_Title)
                    alert.show()
                    }
                }
                else{
                    //set fast login id
                    // aotTextfield.text = wkID
                    switch wkLogInCode
                    {
                    case "1":
                        //touchid or face id
                        if (getBiometryType() == .touchID){
                                TouchIDLogIn ()
                        }else{
                            if BolShowMsg == true {
                             TouchIDLogIn ()
                            }
                        }
                    case "2":
                        //圖形
                        loginInfo.bankCode = bankCode[locationTextfield.text?.replacingOccurrences(of: " ", with: "") ?? ""] ?? loginInfo.bankCode
                        loginInfo.aot = sAot.isEmpty ? aotTextfield.text! : sAot
                        loginInfo.id = idTextfield.text ?? loginInfo.id
                        loginInfo.pod = podTextfield.text ?? loginInfo.pod
                        let city = locationTextfield.text?.components(separatedBy: " ").first ?? ""
                        loginInfo.cityCode = cityCode[city] ?? loginInfo.cityCode
                        self.delegate?.clickGestureShowBtn(loginInfo)
                    default:
                         if (BolShowMsg == true ){
                        let alert = UIAlertView(title: UIAlert_Default_Title, message: "尚未設定快速登入！", delegate: nil, cancelButtonTitle:Determine_Title)
                        alert.show()
                        }
                    }
            }
        }
    }
 func getBiometryType() -> BiometryType{
    //该参数必须在canEvaluatePolicy方法后才有值
    let authContent = LAContext()
    var error: NSError?
    if authContent.canEvaluatePolicy(
        .deviceOwnerAuthenticationWithBiometrics,
        error: &error) {
        //iPhoneX出厂最低系统版本号：iOS11.0.0
        if #available(iOS 11.0, *) {
            if authContent.biometryType == .faceID {
                return .faceID
            }else if authContent.biometryType == .touchID {
                return .touchID
            }
        } else {
            guard let laError = error as? LAError else{
                return .none
            }
            if laError.code != .touchIDNotAvailable {
                return .touchID
            }
        }
    }
    return .none
}
 
}
