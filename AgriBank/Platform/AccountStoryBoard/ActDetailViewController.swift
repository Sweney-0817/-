//
//  ActDetailViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/6/15.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class ActDetailViewController: BaseViewController, ChooseTypeDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var chooseTypeView: ChooseTypeView!    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transDayView: UIView!
    private var typeList:[String]? = nil
    private let cellTitleList = ["交易日期","攤還本金","本金餘額"]
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        typeList = ["活期存款","支票存款","定期存款","放款存款"]
        chooseTypeView.setTypeList(typeList, setDelegate: self)
        tableView.register(UINib(nibName: UIID.UIID_OverviewCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_OverviewCell.NibName()!)
        tableView.reloadData()
        setShadowView(transDayView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_OverviewCell.NibName()!, for: indexPath) as! OverviewCell
        cell.title1Label.text = cellTitleList[0]
        cell.title2Label.text = cellTitleList[1]
        cell.title3Label.text = cellTitleList[2]
        return cell
    }

    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
    }
    
    // MARK: - Xib Event
    @IBAction func clickAccountBtn(_ sender: Any) {
    }
    
    @IBAction func clickDateBtn(_ sender: Any) {
        let btn = (sender as! UIButton)
        if btn.title(for: .normal) == "自訂" {
            let background = UIView.init(frame: view.frame)
            background.backgroundColor = Gray_Color
            background.tag = ViewTag.View_DoubleDatePickerBackground.rawValue
            view.addSubview(background)
            
            let start = UIDatePicker.init(frame: CGRect.init(x: 30, y: 130, width: 320, height: 200))
            start.datePickerMode = .date
            start.locale = Locale(identifier: "zh_CN")
            start.backgroundColor = .white
            background.addSubview(start)
            
            let startLabel = UILabel.init(frame: CGRect.init(x: 30, y: 100, width: 320, height: 30))
            startLabel.text = "起始日"
            startLabel.font = Cell_Font_Size
            startLabel.backgroundColor = Green_Color
            startLabel.textAlignment = .center
            startLabel.textColor = .white
            background.addSubview(startLabel)
            
            let end = UIDatePicker.init(frame: CGRect.init(x: 30, y: 380, width: 320, height: 200))
            end.backgroundColor = .white
            end.datePickerMode = .date
            end.locale = Locale(identifier: "zh_CN")
            background.addSubview(end)
            
            let endLabel = UILabel.init(frame: CGRect.init(x: 30, y: 350, width: 320, height: 30))
            endLabel.text = "截止日"
            endLabel.font = Cell_Font_Size
            endLabel.backgroundColor = Green_Color
            endLabel.textAlignment = .center
            endLabel.textColor = .white
            background.addSubview(endLabel)
            
            let button = UIButton.init(frame: CGRect.init(x: 30, y: 590, width: 320, height: 40))
            button.setBackgroundImage(UIImage.init(named: ImageName.ButtonLarge.rawValue), for: .normal)
            button.tintColor = .white
            button.setTitle("確定", for: .normal)
            button.addTarget(self, action: #selector(clickDetermineBtn(_:)), for: .touchUpInside)
            background.addSubview(button)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: ShowDetail_Segue_Identify, sender: nil)
    }
    
    // MARK: - Selector
    func clickDetermineBtn(_ sender:Any) {
        if let datePickerView = view.viewWithTag(ViewTag.View_DoubleDatePickerBackground.rawValue) {
            datePickerView.removeFromSuperview()
        }
    }
}
