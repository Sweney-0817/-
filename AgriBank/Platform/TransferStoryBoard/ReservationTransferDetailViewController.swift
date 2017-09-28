//
//  ReservationTransferDetailViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/4.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let ReservationTransferDetailTitle = "預約轉帳明細"
struct ReservationTransDetailStruct {
    var outAccount = ""            // 轉出帳號
    var loginDate = ""             // 登錄日期
    var serialNumber = ""          // 登錄序號
    var reservationTransDate = ""  // 預約轉帳日
    var bankCode = ""              // 銀行代碼
    var inAccount = ""             // 轉入帳號
    var amount = ""                // 金額
    var memo = ""                  // 交易備註
}

class ReservationTransferDetailViewController: BaseViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    private var input:ReservationTransDetailStruct? = nil
    private var list:[[String:String]]? = nil
    private var canTransTime = false    // 是否為交易時間
    
    // MARK: - Public
    func setList(_ list:[[String:String]], _ input:ReservationTransDetailStruct) {
        self.list = list
        self.input = input
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
        setShadowView(bottomView)
        cancelButton.layer.cornerRadius = Layer_BorderRadius
        
        if AuthorizationManage.manage.canCancelReservationTransfer() {
            setLoading(true)
            postRequest("COMM/COMM0701", "COMM0701", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03003","Operate":"queryData"], false), AuthorizationManage.manage.getHttpHead(false))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = ReservationTransferDetailTitle
    }
    
    override func didResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "COMM0701":
            if let data = response.object(forKey: ReturnData_Key) as? [String:Any], let status = data["CanTrans"] as? Int, status == Can_Transaction_Status {
                canTransTime = true
            }
            
        default: super.didResponse(description, response)
        }
        
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.set((list?[indexPath.row][Response_Key])!, (list?[indexPath.row][Response_Value])!)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - StoryBoard Touch Event
    @IBAction func clickCancelBtn(_ sender: Any) {
        if inputIsCorrect() {
            let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0302", strSessionDescription: "TRAN0302", httpBody: AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03003","Operate":"commitTxn","TransactionId":transactionId,"ACTNO":input?.outAccount ?? "","RGDAY":input?.loginDate ?? "","TXTNO":input?.serialNumber ?? ""], true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false)
            
            var dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: [[String:String]](), memo: "", confirmBtnName: "確認取消", resultBtnName: "繼續交易", checkRequest: confirmRequest)
            dataConfirm.list?.append([Response_Key:"轉出帳號",Response_Value:input?.outAccount ?? ""])
            dataConfirm.list?.append([Response_Key:"登錄日期",Response_Value:input?.loginDate ?? ""])
            dataConfirm.list?.append([Response_Key:"預約轉帳日",Response_Value:input?.reservationTransDate ?? ""])
            dataConfirm.list?.append([Response_Key:"銀行代碼",Response_Value:input?.bankCode ?? ""])
            dataConfirm.list?.append([Response_Key:"轉入帳號",Response_Value:input?.inAccount ?? ""])
            dataConfirm.list?.append([Response_Key:"金額",Response_Value:input?.amount.separatorThousand() ?? ""])
            dataConfirm.list?.append([Response_Key:"交易備註",Response_Value:input?.memo ?? ""])
            dataConfirm.list?.append([Response_Key:"登錄序號",Response_Value:input?.serialNumber ?? ""])
            enterConfirmResultController(true, dataConfirm, true)
        }
    }
    
    // MARK: - Private
    private func inputIsCorrect() -> Bool {
        if !AuthorizationManage.manage.canCancelReservationTransfer() {
            showErrorMessage(nil, ErrorMsg_NoAuth)
            return false
        }
        if !canTransTime {
            showErrorMessage(nil, ErrorMsg_IsNot_TransTime)
            return false
        }
        return true
    }
}
