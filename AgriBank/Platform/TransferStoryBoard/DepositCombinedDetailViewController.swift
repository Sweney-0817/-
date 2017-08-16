//
//  DepositCombinedDetailViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/6.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let DepositCombinedDetailTitle = "綜存戶存單明細"
let DepositCombinedDetailMemo_startX:CGFloat = 15
let DepositCombinedDetailMemo_startY:CGFloat = 20

class DepositCombinedDetailViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
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
        navigationController?.navigationBar.topItem?.title = ReservationTransferDetailTitle
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ResultCell.NibName()!, for: indexPath) as! ResultCell
        cell.set((list?[indexPath.row]["Key"])!, (list?[indexPath.row]["Value"])!)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView.init(frame:  CGRect(origin: .zero, size: CGSize(width: tableView.frame.width, height: tableView.sectionFooterHeight)))
        let label = UILabel(frame: CGRect(origin: CGPoint(x: DepositCombinedDetailMemo_startX, y: DepositCombinedDetailMemo_startY), size: CGSize(width: view.frame.width-DepositCombinedDetailMemo_startX*2, height: view.frame.height-DepositCombinedDetailMemo_startY)))
        label.text = "本交易受理時間 : 為各營業單位之營業時間 (8:30 - 15:30)"
        label.numberOfLines = 0
        label.textColor = Memo_Color
        label.font = Default_Font
        view.addSubview(label)
        return view
    }

    // MARK: - StoryBoard Touch Event
    @IBAction func clickTerminationBtn(_ sender: Any) {

    }
}
