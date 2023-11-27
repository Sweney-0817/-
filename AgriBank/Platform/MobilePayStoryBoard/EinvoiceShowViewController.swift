//
//  EinvoiceShowController.swift
//  AgriBank
//
//  Created by ABOT on 2021/4/20.
//  Copyright © 2021 Systex. All rights reserved.
//

import UIKit
class EinvoiceShowViewController: BaseViewController, UITextFieldDelegate {
    
    @IBOutlet weak var einvoiceBarCodeImg: UIImageView!
    
    @IBOutlet weak var einvoiceBarCodeTxt: UILabel!
    @IBOutlet weak var DelBtn: UIButton!
    
    private var errorMessage = ""
    private var MBID = ""
    var brightness: CGFloat? // 明亮度
    
    // MARK: - Public
    func setErrorMessage(_ errorMessage:String) {
        self.errorMessage = errorMessage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! UserChangeIDPwdByPassResultViewController
        controller.setErrorMessage(errorMessage)
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        
       
        super.viewDidLoad()
        self.setLoading(true)
         getTransactionID("14002", TransactionID_Description)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
        super.viewWillDisappear(animated)
        // 將瑩幕亮度調回原設定
        if let brightness = self.brightness {
             UIScreen.main.brightness = brightness
         }
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(false)
        switch description {
        case "QR1102" :
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
               
                    if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let array = data["Result"] as? [[String:Any]]{
                        for item in array {
                            if let MBarcode = item["MBarcode"] as? String, let rMBID =  item["MBID"] as? String {
                                MBID = ""
                                let imgwidth =  einvoiceBarCodeImg.frame.width+100
                                let imgheight = einvoiceBarCodeImg.frame.height
                                self.einvoiceBarCodeImg.image = Code39.code39Image(from: MBarcode, width:  imgwidth, height: imgheight)
                                MBID = rMBID
                            //  self.einvoiceBarCodeImg.image = MakeBarCode128Utility.utility.generateBarCode(from: MBarcode)
                                
                                einvoiceBarCodeTxt.text = MBarcode
                                // 將瑩幕亮度調到最亮
                                self.brightness = UIScreen.main.brightness // keep 住原本的亮度
                                 UIScreen.main.brightness = CGFloat(1)
                            } }
                    }
            
                else if (returnCode == "E_QR1102_01"){
                    let controller = getControllerByID(.FeatureID_EinvoiceAdd)
                   
                    navigationController?.pushViewController(controller, animated: true)
                }else{
                    showAlert(title: UIAlert_Default_Title, msg: "發票載具條碼取得異常", confirmTitle: Determine_Title, cancleTitle: nil, completionHandler: {()}, cancelHandelr: {()})
                }
            }
        case "QR1103" :
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String {
                if returnCode == ReturnCode_Success {
                    let controller = getControllerByID(.FeatureID_EinvoiceAdd)
                   
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        case TransactionID_Description:
            
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                
                if transactionId != "" {
                    postRequest("QR/QR1102", "QR1102", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"14002","Operate":"queryData","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
                }
               
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
          //  self.setLoading(false)
        }
    }
    @IBAction func BtnDel(_ sender: Any) {
        //show del msg
        let confirmHandler : ()->Void = { [self] in
           
            postRequest("QR/QR1103", "QR1103", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"14003","Operate":"queryData","TransactionId":transactionId,"MBID":MBID], true), AuthorizationManage.manage.getHttpHead(true))
            
        }
        let cancelHandler : ()->Void = {()}
        showAlert(title: "注意", msg: "您確認要刪除發票載具條碼?" , confirmTitle: "確認", cancleTitle: "取消", completionHandler: confirmHandler, cancelHandelr: cancelHandler)
        
      
    }
}
