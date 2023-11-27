//
//  UserFirstChangeIDPwdViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let UserFirstChangeIDPwd_Seque = "GoFirstChangeResult"
let UserFirstChangeID_ClickCancel_Title = "您尚未完成首次登入變更帳密，系統將執行登出"

class UserFirstChangeIDPwdViewController: BaseViewController, UITextFieldDelegate {
    @IBOutlet weak var sourceIDTextfield: TextField!
    @IBOutlet weak var newIDTextfield: TextField!
    @IBOutlet weak var againIDTextfield: TextField!
    @IBOutlet weak var sourcePodTextfield: TextField!
    @IBOutlet weak var newPodTextfield: TextField!
    @IBOutlet weak var labelNote: UILabel!
    @IBOutlet weak var againPodTextfield: TextField!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var scrollview: UIScrollView!
    private var errorMessage = ""
    private var gesture:UIPanGestureRecognizer? = nil
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        /* 帳戶狀態在「首登」時，只能回首頁並登出 or 變更帳號密碼 */
        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = nil
        gesture = UIPanGestureRecognizer(target: self, action: #selector(HandlePanGesture))
        navigationController?.view.addGestureRecognizer(gesture!)

        // Do any additional setup after loading the view.
       // labelNote.numberOfLines = 0
       // labelNote.sizeToFit()
        scrollview.contentSize = CGSize(width: scrollview.frame.size.width , height: scrollview.frame.size.height)
        
        setShadowView(bottomView, .Top)
        addGestureForKeyBoard()
        
        getTransactionID("01013", TransactionID_Description)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! UserChangeIDPwdResultViewController
        controller.setErrorMessage(errorMessage)
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case TransactionID_Description:
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
            }
            else {
                super.didResponse(description, response)
            }
            
        case "COMM0112":
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                }
            }
            performSegue(withIdentifier: UserFirstChangeIDPwd_Seque, sender: nil)
            
        default: super.didResponse(description, response)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if gesture != nil {
            navigationController?.view.removeGestureRecognizer(gesture!)
        }
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Private
    private func inputIsCorrect() -> Bool {
        if (sourceIDTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(sourceIDTextfield.placeholder!)")
            return false
        }
        if (newIDTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(newIDTextfield.placeholder!)")
            return false
        }
        if (againIDTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(againIDTextfield.placeholder!)")
            return false
        }
        if (sourcePodTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(sourcePodTextfield.placeholder!)")
            return false
        }
        if (newPodTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(newPodTextfield.placeholder!)")
            return false
        }
        
        if (againPodTextfield.text?.isEmpty)! {
            showErrorMessage(nil, "\(Enter_Title)\(againPodTextfield.placeholder!)")
            return false
        }
        if newIDTextfield.text! == sourceIDTextfield.text! {
            showErrorMessage(nil, ErrorMsg_IDNotSame)
            return false
        }
        if (newIDTextfield.text?.count)! < NewInput_MinLength || (newIDTextfield.text?.count)! > NewInput_MaxLength {
            showErrorMessage(nil, "\(newIDTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Length)")
            return false
        }
        if let info = AuthorizationManage.manage.GetLoginInfo() {
            if info.aot == newIDTextfield.text! {
                showErrorMessage(nil, "\(newIDTextfield.placeholder ?? "")\(ErrorMsg_IDPD_SameIdentify)")
                return false
            }
        }
        if !DetermineUtility.utility.isAllEnglishOrNumber(newIDTextfield.text!) {
            showErrorMessage(nil, "\(newIDTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Combine)")
            return false
        }
//        if !DetermineUtility.utility.checkInputEnglihandNumber(newIDTextfield.text!){
//            showErrorMessage(nil, "\(newIDTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Combine2)")
//            return false
//        }
        
        if !DetermineUtility.utility.checkInputNotContinuous(newIDTextfield.text!) {
            showErrorMessage(nil, "\(newIDTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Continous)")
            return false
        }
        if againIDTextfield.text! != newIDTextfield.text! {
            showErrorMessage(nil, ErrorMsg_IDAgainIDNeedSame)
            return false
        }
        if sourcePodTextfield.text! == newPodTextfield.text! {
            showErrorMessage(nil, ErrorMsg_PDNotSame)
            return false
        }
        if newPodTextfield.text! == newIDTextfield.text!{
            showErrorMessage(nil, ErrorMsg_IDPD_SameIDPow)
            return false
        }
        if (newPodTextfield.text?.count)! < NewInput_MinLength || (newIDTextfield.text?.count)! > NewInput_MaxLength {
            showErrorMessage(nil, "\(newPodTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Length)")
            return false
        }
        if let info = AuthorizationManage.manage.GetLoginInfo() {
            if info.aot == newIDTextfield.text! {
                showErrorMessage(nil, "\(newPodTextfield.placeholder ?? "")\(ErrorMsg_IDPD_SameIdentify)")
                return false
            }
        }
        if !DetermineUtility.utility.isAllEnglishOrNumber(newPodTextfield.text!) {
            showErrorMessage(nil, "\(newPodTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Combine)")
            return false
        }
//        if !DetermineUtility.utility.checkInputEnglihandNumber(newPodTextfield.text!){
//            showErrorMessage(nil, "\(newPodTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Combine2)")
//            return false
//        }
        if !DetermineUtility.utility.checkInputNotContinuous(newPodTextfield.text!) {
            showErrorMessage(nil, "\(newPodTextfield.placeholder ?? "")\(ErrorMsg_IDPD_Continous)")
            return false
        }
        if againPodTextfield.text! != newPodTextfield.text! {
            showErrorMessage(nil, ErrorMsg_PDAgainPDNeedSame)
            return false
        }
        return true
    }
    
    // MARK: - StoryBoard Touch Event
      @IBAction func clickCheckBtn(_ sender: Any) {
        if inputIsCorrect() {
            //109-10-16 add by sweney for check e2e key
            if E2EKeyData == "" {
                             showAlert(title: UIAlert_Default_Title, msg: ErrorMsg_NoKeyAdConnection, confirmTitle: "確認", cancleTitle: nil, completionHandler: {exit(0)}, cancelHandelr: {()})
                       }else{
            setLoading(true)
            let idMd5 = SecurityUtility.utility.MD5(string: sourceIDTextfield.text!)
           // let pdMd5 = SecurityUtility.utility.MD5(string: sourcePodTextfield.text!)
            let idMd5_1 = SecurityUtility.utility.MD5(string: sourceIDTextfield.text!.uppercased())
           // let pdMd5_1 = SecurityUtility.utility.MD5(string: sourcePodTextfield.text!.uppercased())
            //E2E
                           // let fmt = DateFormatter()
                            //let timeZone = TimeZone.ReferenceType.init(abbreviation:"UTC") as TimeZone?
                            //fmt.timeZone = timeZone
                            //fmt.dateFormat = "yyyy/MM/dd HH:mm:ss"
                            //let loginDateTIme: String = fmt.string(from: Date())
                            let loginDateTIme: String = Date().date2String(dateFormat: "yyyy/MM/dd HH:mm:ss")
            let pdMd50 = sourcePodTextfield.text! + loginDateTIme
            let pdMd51 = sourcePodTextfield.text!.uppercased() + loginDateTIme
           
            let pdMd5 = E2E.e2Epod(E2EKeyData, pod:pdMd50)
            let pdMd5_1 = E2E.e2Epod(E2EKeyData, pod:pdMd51)
            let pdNPd = againPodTextfield.text! + loginDateTIme
            let pdNPoD = E2E.e2Epod(E2EKeyData, pod:pdNPd)
            
                           postRequest("Comm/COMM0112", "COMM0112", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"01013","Operate":"commitTxn","OID":idMd5,"NID":SecurityUtility.utility.MD5(string: againIDTextfield.text!),"OPWD":pdMd5 ?? "","NPWD":pdNPoD ?? "","ID1":idMd5_1,"PWD1":pdMd5_1 ?? "", "TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
        }
        }
        //109-10-16 end
    }
    
    @IBAction func clickCloseBtn(_ sender: Any) {
        let alert = UIAlertController(title: UIAlert_Default_Title, message: UserFirstChangeID_ClickCancel_Title, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Cancel_Title, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
            DispatchQueue.main.async {
                self.postLogout()
                self.navigationController?.popViewController(animated: true)
            }
        })
        present(alert, animated: false, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !DetermineUtility.utility.isEnglishAndNumber(newString) {
            return false
        }

        let newLength = (textField.text?.count)! - range.length + string.count
        if newLength > Max_ID_Pod_Length {
            return false
        }
        
        return true
    }
    
    // MARK: - GestureRecognizer Selector
    func HandlePanGesture(_ sender: UIPanGestureRecognizer) {}
}
