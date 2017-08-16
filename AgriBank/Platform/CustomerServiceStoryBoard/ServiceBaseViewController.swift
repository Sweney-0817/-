//
//  ServiceBaseViewController.swift
//  AgriBank
//
//  Created by SYSTEX on 2017/7/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit
import CoreLocation

struct ServiceBaseStruct {
    var name:String? = nil
    var address:String? = nil
    var phone:String? = nil
    var fax:String? = nil
    var distance:String? = nil
    var type:String? = nil
    var location:CLLocationCoordinate2D? = nil
    init (_ name:String, _ address:String, _ phone:String, _ fax:String, _ distance:String, _ type:String, _ location:CLLocationCoordinate2D) {
        self.name = name
        self.address = address
        self.phone = phone
        self.fax = fax
        self.distance = distance
        self.type = type
        self.location = location
    }
}

let ServiceBase_TypeList = ["全部","農漁會","ATM"]
let ServiceBase_Default_SearchRange = "我的週遭"
let ServiceBase_CellHeight = CGFloat(100)
let ServiceBase_Segue = "goDetail"
let ServiceBase_Action_Title = "請選擇查詢範圍"
let ServiceBase_Unit_Type = "1"
let ServiceBase_ATM_Type = "2"
let ServiceBase_OneDrop_Title = "查詢範圍"

class ServiceBaseViewController: BaseViewController, OneRowDropDownViewDelegate, UIActionSheetDelegate, ChooseTypeDelegate, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var m_vPlace: UIView!
    @IBOutlet weak var m_vChooseTypeView: ChooseTypeView!
    @IBOutlet weak var m_tvData: UITableView!

    private var m_DDPlace: OneRowDropDownView? = nil
    private var m_iSelectedIndex = -1
    private var m_strSearchRange = ServiceBase_Default_SearchRange
    private var currentType = ServiceBase_TypeList.first!
    private var aroundMeList = [ServiceBaseStruct]()
    private var unitInfoList = [String:[ServiceBaseStruct]]() // 據點
    private var unitList = [String]()                         // 據點 - city
    private var ATMInfoList = [String:[ServiceBaseStruct]]()  // ATM
    private var ATMList = [String]()                          // ATM - city
    private var curData = [ServiceBaseStruct]()
    private var locationManager:CLLocationManager? = nil
    private var curLocation = CLLocationCoordinate2D()

    // MARK: - Public
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()

        setAllSubView()
        setShadowView(m_vChooseTypeView)
        
        // 開啟定位
        if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.delegate = self
            if CLLocationManager.authorizationStatus() == .notDetermined  {
                locationManager?.requestWhenInUseAuthorization()
            }
        }
        else {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager?.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager?.stopUpdatingLocation()
    }
    
    // MARK: - Private
    private func setAllSubView() {
        setDDPlace()
        setChooseTypeView()
        setDataTableView()
    }
    
    private func setDDPlace() {
        if m_DDPlace == nil {
            m_DDPlace = getUIByID(.UIID_OneRowDropDownView) as? OneRowDropDownView
            m_DDPlace?.delegate = self
            m_DDPlace?.setOneRow(ServiceBase_OneDrop_Title, ServiceBase_Default_SearchRange)
            m_DDPlace?.frame = CGRect(x:0, y:0, width:m_vPlace.frame.width, height:(m_DDPlace?.getHeight())!)
            m_vPlace.addSubview(m_DDPlace!)
        }
        m_vPlace.layer.borderColor = Gray_Color.cgColor
        m_vPlace.layer.borderWidth = 1
    }
    
    private func setChooseTypeView() {
        m_vChooseTypeView.setTypeList(ServiceBase_TypeList, setDelegate: self)
        m_vChooseTypeView.layer.borderColor = Gray_Color.cgColor
        m_vChooseTypeView.layer.borderWidth = 1
    }
    
    private func setDataTableView() {
        m_tvData.register(UINib(nibName: UIID.UIID_ServiceBaseCell.NibName()!, bundle: nil), forCellReuseIdentifier: UIID.UIID_ServiceBaseCell.NibName()!)
    }
    
    private func initDataTitleForType() {
        curData.removeAll()
        switch m_strSearchRange {
        case ServiceBase_Default_SearchRange:
            if let index = ServiceBase_TypeList.index(of: currentType) {
                switch index {
                case 0:
                    curData.append(contentsOf: aroundMeList)
                case 1:
                    for info in aroundMeList {
                        if info.type == ServiceBase_Unit_Type {
                            curData.append(info)
                        }
                    }
                case 2:
                    curData = [ServiceBaseStruct]()
                    for info in aroundMeList {
                        if info.type == ServiceBase_ATM_Type {
                            curData.append(info)
                        }
                    }
                default: break
                }
            }
        default:
            if let index = ServiceBase_TypeList.index(of: currentType) {
                switch index {
                case 0:
                    if unitInfoList[m_strSearchRange] != nil {
                        curData.append(contentsOf: unitInfoList[m_strSearchRange]!)
                    }
                    if ATMInfoList[m_strSearchRange] != nil {
                        curData.append(contentsOf: ATMInfoList[m_strSearchRange]!)
                    }
                case 1:
                    if unitInfoList[m_strSearchRange] != nil {
                        curData.append(contentsOf: unitInfoList[m_strSearchRange]!)
                    }
                case 2:
                    if ATMInfoList[m_strSearchRange] != nil {
                        curData.append(contentsOf: ATMInfoList[m_strSearchRange]!)
                    }
                default: break
                }
            }
        }
        m_tvData.reloadData()
    }

    // MARK: - OneRowDropDownViewDelegate
    func clickOneRowDropDownView(_ sender: OneRowDropDownView) {
        var cityList = [ServiceBase_Default_SearchRange]
        if let index = ServiceBase_TypeList.index(of: currentType) {
            switch index {
            case 0:
                cityList.append(contentsOf: unitList)
            case 1:
                cityList.append(contentsOf: unitList)
            case 2:
                cityList.append(contentsOf: ATMList)
            default: break
            }
        }
        
        if cityList.count != 0 {
            let action = UIActionSheet()
            action.delegate = self
            action.title = ServiceBase_Action_Title
            for city in cityList  {
                action.addButton(withTitle: city)
            }
            action.show(in: view)
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        m_strSearchRange = actionSheet.buttonTitle(at: buttonIndex)!
        initDataTitleForType()
        m_DDPlace?.setOneRow((m_DDPlace?.m_lbFirstRowTitle.text)!, actionSheet.buttonTitle(at: buttonIndex)!)
        m_tvData.reloadData()
    }
    
    // MARK: - ChooseTypeDelegate
    func clickChooseTypeBtn(_ name:String) {
        if currentType != name {
            currentType = name
            initDataTitleForType()
        }
        m_tvData.reloadData()
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ServiceBase_CellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        m_iSelectedIndex = indexPath.row
        performSegue(withIdentifier: ServiceBase_Segue, sender: nil)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return curData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UIID.UIID_ServiceBaseCell.NibName()!, for: indexPath) as! ServiceBaseCell
        if indexPath.row < curData.count {
            cell.setData(curData[indexPath.row].name ?? "", curData[indexPath.row].address ?? "", m_strSearchRange == ServiceBase_Default_SearchRange ? (curData[indexPath.row].distance ?? "") : "")
        }
        cell.selectionStyle = .none
        return cell
    }
    
    // MARK: - ConnectionUtilityDelegate
    override func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        switch description {
        case "INFO0301":
            if let data = response.object(forKey: "Data") as? [String:Any], let array = data["No"] as? [[String:String]] {
                for info in array {
                    if let name = info["Name"], let address = info["Address"], let tel = info["Tel"], let fax = info["Fax"], let distance = info["Distance"], let type = info["Type"], let longitude = info["Longitude"], let latitude = info["Latitude"] {
                        aroundMeList.append(ServiceBaseStruct(name, address, tel, fax, distance, type, CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0, longitude: CLLocationDegrees(longitude) ?? 0)))
                    }
                }
                initDataTitleForType()
                m_tvData.reloadData()
                postRequest("Info/INFO0302", "INFO0302", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07053","Operate":"getListInfo"], false), AuthorizationManage.manage.getHttpHead(false))
            }
        case "INFO0302":
            setLoading(false)
            if let data = response.object(forKey: "Data") as? [String:Any] {
                if let unit = data["Unit"] as? [[String:String]] {
                    for info in unit {
                        if let city = info["CC_CityName"] {
                            if unitList.index(of: city) == nil {
                                unitList.append(city)
                            }
                            if let name = info["CUM_FullBankChineseName"], let address = info["CUM_Address"], let tel = info["CUM_Telephone"], let fax = info["CUM_Fax"], let longitude = info["CUM_Longitude"], let latitude = info["CUM_Latitude"] {
                                if var array = unitInfoList[city] {
                                    array.append(ServiceBaseStruct(name, address, tel, fax, "", "", CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0, longitude: CLLocationDegrees(longitude) ?? 0)))
                                }
                                else {
                                    unitInfoList[city] = [ServiceBaseStruct(name, address, tel, fax, "", "", CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0, longitude: CLLocationDegrees(longitude) ?? 0))]
                                }
                            }
                        }
                    }
                }
                if let ATM = data["Unit"] as? [[String:String]]  {
                    for info in ATM {
                        if let city = info["CC_CityName"] {
                            if ATMList.index(of: city) == nil {
                                ATMList.append(city)
                            }
                            if let name = info["CAM_ATMName"], let address = info["CAM_Address"],let longitude = info["CAM_Longitude"], let latitude = info["CAM_Latitude"] {
                                if var array = ATMInfoList[city] {
                                    array.append(ServiceBaseStruct(name, address, "", "", "", "", CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0, longitude: CLLocationDegrees(longitude) ?? 0)))
                                }
                                else {
                                    ATMInfoList[city] = [ServiceBaseStruct(name, address, "", "", "", "", CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude) ?? 0, longitude: CLLocationDegrees(longitude) ?? 0))]
                                }
                            }
                        }
                    }
                }
            }
            
        default: super.didRecvdResponse(description, response)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinate = locations.first?.coordinate {
            if curLocation.latitude != coordinate.latitude || curLocation.longitude != coordinate.longitude {
                curLocation = coordinate
                setLoading(true)
                postRequest("Info/INFO0301", "INFO0301", AuthorizationManage.manage.converInputToHttpBody(["WorkCode":"07052","Operate":"getListInfo","Longitude":curLocation.longitude,"Latitude":curLocation.latitude], false), AuthorizationManage.manage.getHttpHead(false))
            }
        }
    }
}
