//
//  EinvoiceAddViewController.swift
//  AgriBank
//
//  Created by ABOT on 2021/4/22.
//  Copyright © 2021 Systex. All rights reserved.
//

import UIKit

class EinvoiceAddViewController: BaseViewController, UITextFieldDelegate {
    

    @IBOutlet weak var einvoiceTextfield: TextField!
    
    @IBOutlet weak var einvoiceUrl: UILabel!
    
    @IBOutlet weak var AddBtn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    private var errorMessage = ""
    private var currentTextField:UITextField? = nil
    
    // MARK: - Public
    func setErrorMessage(_ errorMessage:String) {
        self.errorMessage = errorMessage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! EinvoiceShowViewController
        controller.setErrorMessage(errorMessage)
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserverToKeyBoard()
        addGestureForKeyBoard()
        
        einvoiceTextfield.setCanUseDefaultAction(bCanUse: true)
        
          getTransactionID("14001", TransactionID_Description)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
        super.viewWillDisappear(animated)
    }
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
        case "QR1101" :
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
                if returnCode == ReturnCode_Success {
                    let controller = getControllerByID(.FeatureID_EinvoiceShow)
                   
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
            
        case TransactionID_Description:
            
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
          //  self.setLoading(false)
        }
    }
    @IBAction func EinvoiceAdd(_ sender: Any) {
        let MBarCode = einvoiceTextfield.text!.uppercased()
        if MBarCode != "" {
        postRequest("QR/QR1101", "QR1101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"14001","Operate":"AddData","TransactionId":transactionId,"MBarcode":MBarCode], true), AuthorizationManage.manage.getHttpHead(true))
        }else{
            showAlert(title: UIAlert_Default_Title, msg: "請輸入發票載具條碼", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
        }
    }
    @IBAction func BtnUrl(_ sender: Any) {
        if let url = URL(string: "https://www.einvoice.nat.gov.tw/APCONSUMER/BTC501W/")
        {
            if #available(iOS 10.0, *)
            {
                UIApplication.shared.open(url, options: [:])
            }
            else
            {
                UIApplication.shared.openURL(url)
            }
        }
    }
    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // MARK: - KeyBoard
    override func keyboardWillShow(_ notification:NSNotification) {
        if currentTextField == einvoiceTextfield   {
            super.keyboardWillShow(notification)
            
        }
    }
}

