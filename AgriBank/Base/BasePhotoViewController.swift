//
//  BasePhotoViewController.swift
//  BankPublicVersion
//
//  Created by TongYoungRu on 2017/5/10.
//  Copyright © 2017年 Systex. All rights reserved.
//

import UIKit

let Original_Image_Key = "UIImagePickerControllerOriginalImage"
let VPImageCropperVC_XStart = 0
let VPImageCropperVC_YStart = 100
let VPImageCropperVC_Width = UIScreen.main.bounds.width
let VPImageCropperVC_Height = UIScreen.main.bounds.width
let VPImageCropperVC_LimitRatio = Int(3)
let BasePhoto_Type = ".jpg"
let CompressionValue_Image = CGFloat(0.2)

enum PhotoActionSheetTitle {
    case first, second
    func simpleDescription() -> String {
        switch self {
        case .first:
            return "相簿"
        case .second:
            return "相機"
        }
    }
}

class BasePhotoViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func clickPersonalImage(_ cancelTitle:String ,_ otherTitle:[PhotoActionSheetTitle]) {
        let actSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: cancelTitle, destructiveButtonTitle: nil)
        otherTitle.forEach{ title in actSheet.addButton(withTitle: title.simpleDescription()) }
        actSheet.tag = ViewTag.ActionSheet_Photo.rawValue
        actSheet.show(in: view)
    }
    
    func savePersonalImage(_ image:UIImage, SetAESKey key:String, SetIdentify identify:String, setAccount account:String? = nil) {
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                FileManager.SearchPathDomainMask.userDomainMask, true)
        let documnetPath = documentPaths[0] as NSString
        let directory = SecurityUtility.utility.AES256Encrypt(identify as NSString, key as NSString)
        let directoryPath = documnetPath.appendingPathComponent(directory)
        if !FileManager.default.fileExists(atPath: directoryPath) {
            do {
                try FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: false, attributes: nil)
            }
            catch let error as NSError {
                print("SavePersonalImage FileManager.default.createDirectory - \(error.description)" )
                return
            }
        }
        
        let imageName = SecurityUtility.utility.AES256Encrypt((account != nil ? account! : identify) as NSString, key as NSString) + BasePhoto_Type
        let imageCompression = UIImageJPEGRepresentation(image, CompressionValue_Image)
        do  {
            try imageCompression?.write(to: URL(fileURLWithPath: directoryPath).appendingPathComponent(imageName), options: .atomic)
        }
        catch let error as NSError {
            print("SavePersonalImage imageCompression?.write - \(error.description)" )
        }
    }
    
    func getPersonalImage(SetAESKey key:String, SetIdentify identify:String, setAccount account:String? = nil) -> UIImage? {
        var image:UIImage? = nil
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                                FileManager.SearchPathDomainMask.userDomainMask, true)
        let documnetPath = documentPaths[0] as NSString
        let directory = SecurityUtility.utility.AES256Encrypt(identify as NSString, key as NSString)
        let directoryPath = documnetPath.appendingPathComponent(directory)
        if FileManager.default.fileExists(atPath: directoryPath) {
            let imageName = SecurityUtility.utility.AES256Encrypt((account != nil ? account! : identify) as NSString, key as NSString) + BasePhoto_Type
            do {
                let imageData = try Data(contentsOf: URL(fileURLWithPath:directoryPath).appendingPathComponent(imageName), options: .mappedIfSafe)
                image = UIImage(data: imageData)
            }
            catch let error as NSError {
                print("GetPersonalImage Data - \(error.description)" )
            }
        }
        return image
    }
    
    // MARK: - UIActionSheetDelegate
    public func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet.tag == ViewTag.ActionSheet_Photo.rawValue {
            if buttonIndex != actionSheet.cancelButtonIndex {
                let imgVc = UIImagePickerController()
                imgVc.delegate = self
                switch actionSheet.buttonTitle(at: buttonIndex)! {
                case PhotoActionSheetTitle.first.simpleDescription():
                    imgVc.sourceType = .photoLibrary
                    break
                case PhotoActionSheetTitle.second.simpleDescription():
                    imgVc.sourceType = .camera
                    break
                default:
                    break
                }
                present(imgVc, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: {
            if let portraitImg = info[Original_Image_Key] as? UIImage {
                let imgVcClip = VPImageCropperViewController(image: portraitImg, cropFrame: CGRect(origin: CGPoint(x: VPImageCropperVC_XStart, y: VPImageCropperVC_YStart), size: CGSize(width: VPImageCropperVC_Width, height:VPImageCropperVC_Height)), limitScaleRatio: VPImageCropperVC_LimitRatio)
                imgVcClip?.delegate = self
                self.present(imgVcClip!, animated: true, completion: nil)
            }
            else {
                print("func imagePickerController - info[Original_Image_Key] as? UIImage => faild")
            }
        })
    }
    
    // MARK: - VPImageCropperDelegate
    func imageCropper(_ cropperViewController: VPImageCropperViewController!, didFinished editedImage: UIImage!) {
        cropperViewController.dismiss(animated: true, completion: nil)
    }
    
    func imageCropperDidCancel(_ cropperViewController: VPImageCropperViewController!) {
        cropperViewController.dismiss(animated: true, completion: nil)
    }
}
