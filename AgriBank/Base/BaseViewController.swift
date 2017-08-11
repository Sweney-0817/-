//
//  BaseViewController.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/4/6.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import Foundation
import UIKit

#if DEBUG
let URL_PROTOCOL = "http"
let URL_DOMAIN = "52.187.113.27/FFICMAPI/api"
#else
let URL_PROTOCOL = "https"
let URL_DOMAIN = ""
#endif
let REQUEST_URL = "\(URL_PROTOCOL)://\(URL_DOMAIN)"
let BarItem_Height_Weight = 30
let NavigationBarColor = UIColor(colorLiteralRed: 46/255, green: 134/255, blue: 201/255, alpha: 1)
let Loading_Weight = 100
let Loading_Height = 100

class BaseViewController: UIViewController, ConnectionUtilityDelegate {
    var request:ConnectionUtility? = nil
    var needShowBackBarItem:Bool = true
    var transactionId = ""
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let rButton = UIButton(type: .custom)
        rButton.frame = CGRect(x: 0, y: 0, width: BarItem_Height_Weight, height: BarItem_Height_Weight)
        rButton.addTarget(self, action: #selector(clickShowSideMenu), for: .touchUpInside)
        rButton.setImage(UIImage(named: ImageName.RightBarItem.rawValue), for: .normal)
        rButton.setImage(UIImage(named: ImageName.RightBarItem.rawValue), for: .highlighted)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rButton)
        
        if needShowBackBarItem {
            let lButton = UIButton(type: .custom)
            lButton.frame = CGRect(x: 0, y: 0, width: BarItem_Height_Weight, height: BarItem_Height_Weight)
            lButton.addTarget(self, action: #selector(clickBackBarItem), for: .touchUpInside)
            lButton.setImage(UIImage(named: ImageName.BackBarItem.rawValue), for: .normal)
            lButton.setImage(UIImage(named: ImageName.BackBarItem.rawValue), for: .highlighted)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: lButton)
        }
        else {
            navigationItem.setHidesBackButton(true, animated:false);
        }
        
        navigationController?.navigationBar.barTintColor = NavigationBarColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.topItem?.title = getFeatureName(getCurrentFeatureID())
        navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName:Default_Font,NSForegroundColorAttributeName:UIColor.white]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - public
    func postRequest(_ strMethod:String, _ strSessionDescription:String, _ httpBody:Data?, _ loginHttpHead:[String:String]?, _ strURL:String? = nil, _ needCertificate:Bool = false, _ isImage:Bool = false)  {
        request = !isImage ? ConnectionUtility() : ConnectionUtility(.Image)
        request?.postRequest(self, strURL == nil ? "\(REQUEST_URL)/\(strMethod)": strURL!, strSessionDescription, httpBody, loginHttpHead, needCertificate)
    }
    
    func getControllerByID(_ ID:PlatformFeatureID) -> UIViewController {
        return Platform.plat.getControllerByID(ID)
    }
    
    func getUIByID(_ ID:UIID) -> Any? {
        return Platform.plat.getUIByID(ID, self)
    }
    
    func getFeatureName(_ ID:PlatformFeatureID) -> String {
        return Platform.plat.getFeatureNameByID(ID)
    }
    
    func getFeatureInfoByID(_ ID:PlatformFeatureID) -> FeatureStruct? {
        return Platform.plat.getFeatureInfoByID(ID)
    }
    
    func getCurrentFeatureID() -> PlatformFeatureID {
        return Platform.plat.getCurrentFeatureID()
    }
    
    func enterFeatureByID(_ ID:PlatformFeatureID, _ animated:Bool) {
        if self is HomeViewController {
            Platform.plat.popToRootViewController()
            navigationController?.popToRootViewController(animated: animated)
        }
        else {
            if let con = navigationController?.viewControllers.first {
                if con is HomeViewController {
                    (con as! HomeViewController).enterFeatureByID(ID, animated)
                }
            }
        }
    }
    
    func setShadowView(_ view:UIView) {
        view.layer.shadowRadius = Shadow_Radious
        view.layer.shadowOpacity = Shadow_Opacity
        view.layer.shadowColor = UIColor.black.cgColor
    }
    
    func enterConfirmResultController(_ isConfirm:Bool,_ data:ConfirmResultStruct,_ animated:Bool) {
        if isConfirm {
            let controller = getControllerByID(.FeatureID_Confirm)
            (controller as! ConfirmViewController).setData(data)
            navigationController?.pushViewController(controller, animated: animated)
        }
        else {
            let controller = getControllerByID(.FeatureID_Result)
            (controller as! ResultViewController).setData(data)
            navigationController?.pushViewController(controller, animated: animated)
        }
    }
    
    func setLoading(_ isLoading:Bool) {
        if isLoading {
            if view.viewWithTag(ViewTag.View_Loading.rawValue) == nil {
                let loadingView = UIView(frame: view.frame)
                loadingView.tag = ViewTag.View_Loading.rawValue
                loadingView.backgroundColor = Loading_Background_Color
                
                let backgroundView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: Loading_Weight, height: Loading_Height)))
                backgroundView.backgroundColor = .white
                backgroundView.center = loadingView.center
                loadingView.addSubview(backgroundView)
                
                let loading = UIActivityIndicatorView(activityIndicatorStyle: .gray)
                loading.startAnimating()
                loading.center = loadingView.center
                loadingView.addSubview(loading)
                
                view.addSubview(loadingView)
            }
        }
        else {
            if let loadingView = view.viewWithTag(ViewTag.View_Loading.rawValue) {
                loadingView.removeFromSuperview()
            }
        }
    }
    
    func getTransactionID(_ workCode:String, _ description:String) {
        postRequest("Comm/COMM0601", description, AuthorizationManage.manage.converInputToHttpBody(["WorkCode":workCode,"Operate":"getTranID"], false), AuthorizationManage.manage.getHttpHead(false))
    }
    
    func showErrorMessage(_ title:String?, _ message:String?) {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle:"確認")
        alert.show()
    }
    
    // MARK: - ConnectionUtilityDelegate
    func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        setLoading(false)
        if let returnMsg = response.object(forKey: "ReturnMsg") as? String, let returnCode = response.object(forKey: "ReturnCode") as? String  {
            let message = "ReturnMsg:\(returnMsg) ReturnCode:\(returnCode)"
            showErrorMessage(nil, message)
        }
    }
    
    func didFailedWithError(_ error: Error) {
        setLoading(false)
        let alert = UIAlertView(title: nil, message: "Error Message:\(error.localizedDescription)", delegate: nil, cancelButtonTitle:"確認")
        alert.show()
    }
    
    // MARK: - UIBarButtonItem Selector
    func clickShowSideMenu() {
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            (rootViewController as! SideMenuViewController).ShowSideMenu(true)
        }
    }
    
    func clickBackBarItem() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - KeyBoard
    func AddObserverToKeyBoard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        view.frame.origin.y = -keyboardHeight
    }
    
    func keyboardWillHide(_ notification:NSNotification) {
        view.frame.origin.y = 0
    }
}
