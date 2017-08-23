//
//  DepositCombinedDetailViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/6.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let DepositCombinedDetail_Title = "綜存戶存單明細"
let DepositCombinedDetail_Memo = "本交易受理時間 : 為各營業單位之營業時間"

class DepositCombinedDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    private var list:[[String:String]]? = nil
    private var account:String? = nil
    
    // MARK: - Public
    func setList(_ list:[[String:String]], _ account:String?) {
        self.list = list
        self.account = account
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: UIID.UIID_ResultCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ResultCell.NibName()!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = DepositCombinedDetail_Title
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
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return MemoView.GetStringHeightByWidthAndFontSize(DepositCombinedDetail_Memo, tableView.frame.width)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = getUIByID(.UIID_MemoView) as! MemoView
        footer.set(DepositCombinedDetail_Memo)
        return footer
    }

    // MARK: - StoryBoard Touch Event
    @IBAction func clickTerminationBtn(_ sender: Any) {
        let confirmRequest = RequestStruct(strMethod: "TRAN/TRAN0502", strSessionDescription: "TRAN0502", httpBody: AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"03005","Operate":"commitTxn","TransactionId":transactionId,"Deposit":account ?? ""], true), loginHttpHead: AuthorizationManage.manage.getHttpHead(true), strURL: nil, needCertificate: false, isImage: false)
        let dataConfirm = ConfirmResultStruct(image: ImageName.CowCheck.rawValue, title: Check_Transaction_Title, list: list, memo: "", confirmBtnName: "確認送出", resultBtnName: "繼續交易", checkRequest: confirmRequest)
        enterConfirmResultController(true, dataConfirm, true)
    }
}
