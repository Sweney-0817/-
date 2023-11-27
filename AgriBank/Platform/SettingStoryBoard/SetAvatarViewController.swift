//
//  SetAvatarViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let SetAvatar_Delete_Title = "確定刪除頭像？"

@available(iOS 10.0, *)
class SetAvatarViewController: BasePhotoViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageShadowView: UIView!
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let info = AuthorizationManage.manage.getResponseLoginInfo(), let USUDID = info.USUDID {
                        imageView.image = getPersonalImage(SetAESKey: "\(SEA1)\(SEA2)\(SEA3)", SetIdentify: USUDID, setAccount: USUDID)
        }
        /* UIImagePickerController 與 NotificationCenter.default.addObserver(forName: nil, object: nil, queue: nil) 有衝突*/
        (UIApplication.shared.delegate as! AppDelegate).removeNotificationAllEvent()
        
        /*  UIImageView無法同時支援 陰影+cornerRadius */
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.layer.masksToBounds = true
        /* 陰影效果不好將其移出 */
//        imageShadowView.layer.cornerRadius = imageShadowView.frame.width/2
//        imageShadowView.layer.shadowOffset = CGSize(width: 0, height: 10)
//        imageShadowView.layer.shadowRadius = Shadow_Radious
//        imageShadowView.layer.shadowOpacity = Shadow_Opacity
//        imageShadowView.layer.shadowColor = UIColor.gray.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
            (UIApplication.shared.delegate as! AppDelegate).notificationAllEvent()
    }

    // MARK: - StoryBoard Touch Event
    @IBAction func clickShootBtn(_ sender: Any) {
        if let statusView = UIApplication.shared.windows.first?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = true
        }
        imagePicker?.sourceType = .camera
        present(imagePicker!, animated: true, completion: nil)
    }
    
    @IBAction func clickChooseBtn(_ sender: Any) {
        if let statusView = UIApplication.shared.windows.first?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = true
        }
        imagePicker?.sourceType = .photoLibrary
        present(imagePicker!, animated: true, completion: nil)
    }
    
    @IBAction func clickDeleteBtn(_ sender: Any) {
        if let info = AuthorizationManage.manage.getResponseLoginInfo(), let USUDID = info.USUDID, getPersonalImage(SetAESKey: "\(SEA1)\(SEA2)\(SEA3)", SetIdentify: USUDID, setAccount: USUDID) != nil {
            let alert = UIAlertController(title: UIAlert_Default_Title, message: SetAvatar_Delete_Title, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Cancel_Title, style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: Determine_Title, style: .default) { _ in
                DispatchQueue.main.async {
                    self.imageView.layer.cornerRadius = 0
                    self.imageView.image = UIImage(named: ImageName.LoginLogo.rawValue)
                                      self.savePersonalImage(nil, SetAESKey: "\(SEA1)\(SEA2)\(SEA3)", SetIdentify: USUDID, setAccount: USUDID)
                }
            })
            present(alert, animated: false, completion: nil)
        }
        else {
            showErrorMessage(nil, ErrorMsg_NoImage)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    override func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        super.imagePickerControllerDidCancel(picker)
        if let statusView = UIApplication.shared.keyWindow?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = false
        }
    }
    
    // MARK: - VPImageCropperDelegate
    override func imageCropper(_ cropperViewController: VPImageCropperViewController!, didFinished editedImage: UIImage!) {
        cropperViewController.dismiss(animated: true, completion: nil)
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.image = editedImage
        if let info = AuthorizationManage.manage.getResponseLoginInfo(), let USUDID = info.USUDID {
              savePersonalImage(editedImage, SetAESKey: "\(SEA1)\(SEA2)\(SEA3)", SetIdentify: USUDID, setAccount: USUDID)
        }
        if let statusView = UIApplication.shared.windows.first?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = false
        }
    }

    override func imageCropperDidCancel(_ cropperViewController: VPImageCropperViewController!) {
        super.imageCropperDidCancel(cropperViewController)
        if let statusView = UIApplication.shared.windows.first?.viewWithTag(ViewTag.View_Status.rawValue) {
            statusView.isHidden = false
        }
    }
}
