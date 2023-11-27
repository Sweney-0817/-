//
//  UserChangeIDPwdByPassViewController.swift
//  AgriBank
//
//  Created by Sweney on 2019/8/28.
//  Copyright © 2019 Systex. All rights reserved.
//
//108-8-28 Add by Sweney - 密碼沿用增加

import UIKit

let UserChangeIDPwdByPass_Seque = "GoChangeByPassResult"

class UserChangeIDPwdByPassViewController: BaseViewController {
    
    @IBOutlet weak var msgLabel: UILabel!
    
    private var isChangePod = false
    private var errorMessage = ""
    private var isClickChangeBtn = false
    private var gesture:UIPanGestureRecognizer? = nil
    
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
       
         getTransactionID("08005", TransactionID_Description)
        
    }
    
    func PostByPsassTrl(){
        self.setLoading(true)
    postRequest("Usif/USIF0302", "USIF0302", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"08005","Operate":"dataConfirm","TransactionId":transactionId], true), AuthorizationManage.manage.getHttpHead(true))
   
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if gesture != nil {
            navigationController?.view.removeGestureRecognizer(gesture!)
        }
        super.viewWillDisappear(animated)
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        self.setLoading(true)
        switch description {
        case "USIF0302" :
            
            if let returnCode = response.object(forKey: ReturnCode_Key) as? String, returnCode != ReturnCode_Success {
                if let message = response.object(forKey: ReturnMessage_Key) as? String {
                    errorMessage = message
                }
            }
            
            performSegue(withIdentifier: UserChangeIDPwdByPass_Seque, sender: nil)
             // self.setLoading(false)
        case TransactionID_Description:
            
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let tranId = data[TransactionID_Key] as? String {
                transactionId = tranId
                
                if transactionId != "" {
                    self.PostByPsassTrl()
                }
               
            }
            else {
                super.didResponse(description, response)
            }
            
        default: super.didResponse(description, response)
          //  self.setLoading(false)
        }
    }
    
    
    
   
    
    // MARK: - GestureRecognizer Selector
    func HandlePanGesture(_ sender: UIPanGestureRecognizer) {}
}
