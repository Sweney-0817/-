//
//  LoanPrincipalInterestDetailViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/7.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let LoanPrincipalInterestDetailTitle = "繳交放款本息查詢"

class LoanPrincipalInterestDetailViewController: BaseViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    private var list:[[String:String]]? = nil
    
    // MARK: - Public
    func setList(_ list:[[String:String]]) {
        self.list = list
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
        navigationController?.navigationBar.topItem?.title = LoanPrincipalInterestDetailTitle
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
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ResultCell.GetStringHeightByWidthAndFontSize((list?[indexPath.row][Response_Value])!, tableView.frame.size.width)
    }
}
