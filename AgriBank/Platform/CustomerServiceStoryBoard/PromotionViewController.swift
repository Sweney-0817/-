//
//  PromotionViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

struct PromotionStruct {
    var title:String? = nil
    var date:String? = nil
    var place:String? = nil
    var url:String? = nil
    init (_ title:String, _ date:String, _ place:String, _ url:String) {
        self.title = title
        self.date = date
        self.place = place
        self.url = url
    }
}

class PromotionViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var m_vPlace: UIView!
    @IBOutlet weak var m_tvData: UITableView!
    private var m_iSelectedIndex = -1
    private var m_DDPlace: OneRowDropDownView? = nil
    private var promotionList = [String:[PromotionStruct]]()
    private var cityList = [String]()
    private var chooseCity = ""
    
    // MARK: - Public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let webContentViewController = segue.destination as! WebContentViewController
        if let list = promotionList[chooseCity] {
            webContentViewController.setData(list[m_iSelectedIndex])
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
        setShadowView(m_vPlace)
        setLoading(true)
        postRequest("Info/INFO0101", "INFO0101", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07031","Operate":"getListInfo"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private
    private func goDetail() {
        performSegue(withIdentifier: "goDetail", sender: nil)
    }

    private func setAllSubView() {
        setDDPlace()
        setDataTableView()
    }

    private func setDDPlace() {
        if (m_DDPlace == nil) {
            m_DDPlace = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDPlace?.delegate = self
            m_DDPlace?.setOneRow("提供單位", "")
            m_DDPlace?.frame = CGRect(x:0, y:0, width:m_vPlace.frame.width, height:(m_DDPlace?.getHeight())!)
            m_vPlace.addSubview(m_DDPlace!)
        }
        m_vPlace.layer.borderColor = Gray_Color.cgColor
        m_vPlace.layer.borderWidth = 1
    }

    private func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_PromotionCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_PromotionCell.NibName()!)
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        let action = UIActionSheet()
        action.delegate = self
        for city in cityList  {
            action.addButton(withTitle: city)
        }
        action.show(in: self.view)
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        m_DDPlace?.setOneRow((m_DDPlace?.m_lbFirstRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!)
        chooseCity = actionSheet.buttonTitle(at: buttonIndex) ?? ""
        m_tvData.reloadData()
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 129
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        m_iSelectedIndex = indexPath.row
        goDetail()
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = promotionList[chooseCity] {
            return list.count
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_PromotionCell.NibName()!, for: indexPath) as! PromotionCell
        if let list = promotionList[chooseCity], let title = list[indexPath.row].title, let date = list[indexPath.row].date, let place = list[indexPath.row].place  {
            cell.setData(title, date, place)
        }
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
        switch description {
        case "INFO0101":
            if let data = response.object(forKey: "Data") as? [String:Any], let list = data["AllPromo"] as? [[String:Any]] {
                for index in 0...list.count-1 {
                    let dic = list[index]
                    if let city = dic["CC_CityName"] as? String, let promotion = dic["LocalPromo"] as? [[String:String]] {
                        var pList = [PromotionStruct]()
                        for info in promotion {
                           pList.append( PromotionStruct.init( info["CMI_Title"] ?? "", info["CMI_AddedDT"] ?? "", info["CUM_BankChineseName"] ?? "", info["URL"] ?? "" ) )
                        }
                        promotionList[city] = pList
                        cityList.append(city)
                    }
                }
            }
        default: break
        }
    }
}
