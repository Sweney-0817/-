//
//  ShowDetailViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class ShowDetailViewController: BaseViewController, UITableViewDataSource {
    private var titleList:[String]? = nil
    private var detailList:[String]? = nil
    private var barTitle:String? = nil
    
    // MARK: - Public
    func SetInitial(_ title:String, _ titleList:[String]?, _ detailList:[String]?) {
        barTitle = title
        self.titleList = titleList
        self.detailList = detailList
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        titleList = ["帳號","帳戶餘額","可用餘額"]
        detailList = ["1234567890", "999,999,999.00", "100,000,000"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = barTitle
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (titleList?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SystemCell_Identify)
        if cell == nil {
            cell = UITableViewCell(style: .value2, reuseIdentifier:SystemCell_Identify)
            let separetor = UIView(frame: CGRect(origin: CGPoint(x: 0, y: tableView.rowHeight-Separator_Height), size: CGSize(width: tableView.frame.width, height: Separator_Height)))
            separetor.backgroundColor = Gray_Color
            cell?.contentView.addSubview(separetor)
        }
        cell?.selectionStyle = .none
        cell?.textLabel?.text = titleList?[indexPath.row]
        cell?.textLabel?.textColor = Cell_Title_Color
        cell?.textLabel?.font = Cell_Font_Size
        cell?.detailTextLabel?.text = detailList?[indexPath.row]
        cell?.detailTextLabel?.textColor = Cell_Detail_Color
        cell?.detailTextLabel?.font = Cell_Font_Size
        return cell!
    }
}
