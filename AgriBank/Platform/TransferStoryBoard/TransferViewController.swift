//
//  TransferViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/23.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class TransferViewController: BaseViewController, UITextFieldDelegate, DropDownViewDelegate {
    @IBOutlet weak var topCons: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var accountTypeSegCon: UISegmentedControl!
    @IBOutlet weak var showBankAccountView: UIView!
    @IBOutlet weak var showBankAccountHeight: NSLayoutConstraint!
    @IBOutlet weak var chooseActTypeView: UIView!
    @IBOutlet weak var chooseActTypeHeight: NSLayoutConstraint!
    @IBOutlet weak var enterAccountView: UIView!
    @IBOutlet weak var enterAccountHeight: NSLayoutConstraint!
    @IBOutlet weak var gapHeight: NSLayoutConstraint!
    @IBOutlet weak var predesignatedBtn: UIButton!
    @IBOutlet weak var nonPredesignatedBtn: UIButton!
    private var isPredesignated = true     // 是否為約定轉帳
    private var isCustomizeAct = true      // 是否為自訂帳號
    private var sShowBankAccountHeight:CGFloat = 0
    private var sChooseActTypeHeight:CGFloat = 0
    private var sEnterAccountHeight:CGFloat = 0
    private var sGapHeight:CGFloat = 0
    private var topDropView:DropDownView? = nil
    private var showBankAccountDropView:DropDownView? = nil
    private var enterAccountDorpView:DropDownView? = nil
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        accountTypeSegCon.layer.borderWidth = Layer_BorderWidth
        accountTypeSegCon.layer.cornerRadius = Layer_BorderRadius
        accountTypeSegCon.layer.borderColor = Orange_Color.cgColor
        accountTypeSegCon.setTitleTextAttributes([NSFontAttributeName:Default_Font], for: .normal)
        
        sShowBankAccountHeight = showBankAccountHeight.constant
        sChooseActTypeHeight = chooseActTypeHeight.constant
        sEnterAccountHeight = enterAccountHeight.constant
        sGapHeight = gapHeight.constant
        
        if isPredesignated {
            chooseActTypeView.isHidden = true
            chooseActTypeHeight.constant = 0
            enterAccountView.isHidden = true
            enterAccountHeight.constant = 0
            gapHeight.constant = 0
            
        }
        else {
            if isCustomizeAct {
                showBankAccountView.isHidden = true
                showBankAccountHeight.constant = 0
            }
            else {
                enterAccountView.isHidden = true
                enterAccountHeight.constant = 0
            }
        }
        
        topDropView = getUIByID(.UIID_DropDownView) as? DropDownView
        topDropView?.setThreeRow("轉出帳號", "", "幣別", "", "餘額", "")
        topDropView?.frame = topView.frame
        topDropView?.frame.origin = .zero
        topView.addSubview(topDropView!)
        setShadowView(topView)
        topView.layer.borderWidth = Layer_BorderWidth
        topView.layer.borderColor = Gray_Color.cgColor
        
        showBankAccountDropView = getUIByID(.UIID_DropDownView) as? DropDownView
        showBankAccountDropView?.setTwoRow("銀行代碼", "", "轉入帳號", "")
        showBankAccountDropView?.frame = showBankAccountView.frame
        showBankAccountDropView?.frame.origin = .zero
        showBankAccountView.addSubview(showBankAccountDropView!)
        
        enterAccountDorpView = getUIByID(.UIID_DropDownView) as? DropDownView
        enterAccountDorpView?.setOneRow("銀行代碼", "")
        enterAccountDorpView?.frame.origin = .zero
        enterAccountDorpView?.frame.size.width = enterAccountView.frame.size.width
        enterAccountView.addSubview(enterAccountDorpView!)
        
        setShadowView(middleView)
        middleView.layer.borderWidth = Layer_BorderWidth
        middleView.layer.borderColor = Gray_Color.cgColor
        
        AddObserverToKeyBoard()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - private 
    private func SetBtnColor(_ isPredesignated:Bool) {
        self.isPredesignated = isPredesignated
        if isPredesignated {
            predesignatedBtn.backgroundColor = Orange_Color
            predesignatedBtn.setTitleColor(.white, for: .normal)
            nonPredesignatedBtn.backgroundColor = .white
            nonPredesignatedBtn.setTitleColor(.black, for: .normal)
        }
        else {
            nonPredesignatedBtn.backgroundColor = Orange_Color
            nonPredesignatedBtn.setTitleColor(.white, for: .normal)
            predesignatedBtn.backgroundColor = .white
            predesignatedBtn.setTitleColor(.black, for: .normal)
        }
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickAccountBtn(_ sender: Any) {
        
    }

    @IBAction func clickPredesignatedBtn(_ sender: Any) {
        SetBtnColor(true)
        chooseActTypeView.isHidden = true
        chooseActTypeHeight.constant = 0
        enterAccountView.isHidden = true
        enterAccountHeight.constant = 0
        gapHeight.constant = 0
        showBankAccountView.isHidden = false
        showBankAccountHeight.constant = sShowBankAccountHeight
    }
 
    @IBAction func clickNonPredesignatedBtn(_ sender: Any) {
        SetBtnColor(false)
        chooseActTypeView.isHidden = false
        chooseActTypeHeight.constant = sChooseActTypeHeight
        gapHeight.constant = sGapHeight
        if isCustomizeAct {
            showBankAccountView.isHidden = true
            showBankAccountHeight.constant = 0
            enterAccountView.isHidden = false
            enterAccountHeight.constant = sEnterAccountHeight
        }
        else {
            enterAccountView.isHidden = true
            enterAccountHeight.constant = 0
            showBankAccountView.isHidden = false
            showBankAccountHeight.constant = sShowBankAccountHeight
        }
    }

    @IBAction func clickChangeActType(_ sender: Any) {
        let segCon:UISegmentedControl = sender as! UISegmentedControl
        switch segCon.selectedSegmentIndex {
        case 0:
            isCustomizeAct = true
            showBankAccountView.isHidden = true
            showBankAccountHeight.constant = 0
            enterAccountView.isHidden = false
            enterAccountHeight.constant = sEnterAccountHeight
        default:
            isCustomizeAct = false
            enterAccountView.isHidden = true
            enterAccountHeight.constant = 0
            showBankAccountView.isHidden = false
            showBankAccountHeight.constant = sShowBankAccountHeight
        }
    }
    
    @IBAction func clickSendBtn(_ sender: Any) {
//        var data = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: "請確認本次交易資訊", memo: "", list: [[String:String]](), confirmBtnName: "確認送出", resultBtnName: "繼續交易")
        var data = ConfirmResultStruct(ImageName.CowCheck.rawValue, "請確認本次交易資訊", [[String:String]](), nil, "確認送出", "繼續交易")
        data.list!.append(["Key": "轉出帳號", "Value":"12345678901234"])
        data.list!.append(["Key": "銀行代碼", "Value":"008"])
        data.list!.append(["Key": "轉入帳號", "Value":"12345678901235"])
        data.list!.append(["Key": "轉帳金額", "Value":"9,999,999.00"])
        data.list!.append(["Key": "備註/交易備註", "Value":"備註"])
        data.list!.append(["Key": "受款人E-mail", "Value":"1234@gmail.com"])
        enterConfirmResultController(true, data, true)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: - DropDownViewDelegate
    func clickDropDownView() {
        
    }
}
