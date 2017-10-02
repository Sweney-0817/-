//
//  SetAvatarViewController.swift
//  AgriBank
//
//  Created by TongYoungRu on 2017/7/11.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

class SetAvatarViewController: BasePhotoViewController {
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let info = AuthorizationManage.manage.GetLoginInfo() {
            imageView.image = getPersonalImage(SetAESKey: AES_Key, SetIdentify: info.id, setAccount: info.id)
            imageView.layer.cornerRadius = imageView.frame.width/2
            imageView.layer.masksToBounds = true
        }
        /* UIImagePickerController 與 NotificationCenter.default.addObserver(forName: nil, object: nil, queue: nil) 有衝突*/
        (UIApplication.shared.delegate as! AppDelegate).removeNotificationAllEvent()
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
        imageView.layer.cornerRadius = 0
        imageView.layer.masksToBounds = false
        imageView.image = UIImage(named: ImageName.Login.rawValue)
        if let info = AuthorizationManage.manage.GetLoginInfo() {
            savePersonalImage(nil, SetAESKey: AES_Key, SetIdentify: info.id, setAccount: info.id)
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
        imageView.layer.masksToBounds = true
        imageView.image = editedImage
        imageView.clipsToBounds = true
        if let info = AuthorizationManage.manage.GetLoginInfo() {
            savePersonalImage(editedImage, SetAESKey: AES_Key, SetIdentify: info.id, setAccount: info.id)
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
