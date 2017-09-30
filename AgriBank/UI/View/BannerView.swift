//
//  BannerView.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/5/11.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import UIKit

let Default_Banner_Image_Name = "Default"
let Banner_Repeat_Time:TimeInterval = 5

struct BannerStructure {
    var imageURL:String
    var link:String
}

class BannerView: UIView, ConnectionUtilityDelegate, UIScrollViewDelegate {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentSizeWidth: NSLayoutConstraint!
    private var contentList:[BannerStructure]? = nil
    private var imageList = [Int:UIImage]()
    private var request:ConnectionUtility? = nil
    
    func setContentList(_ list: [BannerStructure]?)  {
        contentList = list
        contentView.subviews.forEach{view in view.removeFromSuperview()}
        addImageView()
    }
    
    private func addImageView() {
        if contentList != nil {
            pageControl.numberOfPages = (contentList?.count)!
            contentSizeWidth.constant = self.frame.width * CGFloat(pageControl.numberOfPages-1)
            var xStart:CGFloat = 0
            var img:UIImageView? = nil
            for index in 1...contentList!.count {
                img = UIImageView(image: UIImage(named:Default_Banner_Image_Name))
                img?.frame = self.frame
                img?.frame.origin.x = xStart
                img?.tag = index
                contentView.addSubview(img!)
                xStart += (img?.frame.size.width)!
            }
            if let content = contentList?[Int(pageControl.currentPage)] {
                postRequest("", String(Int(pageControl.currentPage)), false, nil, nil, content.imageURL)
            }
            _ = Timer.scheduledTimer(timeInterval: Banner_Repeat_Time, target: self, selector: #selector(pageChanged), userInfo: nil, repeats: true);
        }
    }

    private func postRequest(_ strMethod:String, _ strSessionDescription:String, _ needCertificate:Bool = false,  _ httpBody:Data? = nil, _ dicHttpHead:[String:String]? = nil, _ strURL:String? = nil)  {
        request = ConnectionUtility(.Image)
        request?.requestData(self, strURL == nil ? "\(REQUEST_URL)/\(strMethod)": strURL!, strSessionDescription, httpBody, dicHttpHead, needCertificate)
    }
    
    @objc private func pageChanged() {
        let page = self.pageControl.currentPage+1 == self.pageControl.numberOfPages ? 0 : self.pageControl.currentPage+1
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        scrollView.scrollRectToVisible(frame, animated:true)
        pageControl.currentPage = page
        if imageList[page] == nil && page < (contentList?.count)! {
            if let content = contentList?[page] {
                postRequest("", String(page), false, nil, nil, content.imageURL)
            }
        }
    }
    
    // MARK: - XIB Event
    @IBAction func clickBannerBtn(_ sender: Any) {
        if let content = contentList?[pageControl.currentPage].link {
            if UIApplication.shared.canOpenURL(URL(string: content)!) {
                UIApplication.shared.openURL(URL(string: content)!)
            }
        }
    }
    
    // MARK: - ConnectionUtilityDelegate
    func didRecvdResponse(_ description:String, _ response: NSDictionary) {
        let responseImage = response[RESPONSE_IMAGE_KEY] as? UIImage
        if let page = Int(description) {
            if let imgView = contentView.viewWithTag(page+1) {
                (imgView as! UIImageView).image = responseImage
            }
            imageList[page] = responseImage
        }
    }
    
    func didFailedWithError(_ error: Error) {
        
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x/scrollView.frame.width)
        pageControl.currentPage = page
        if imageList[page] == nil && page < (contentList?.count)! {
            if let content = contentList?[page] {
                postRequest("", String(page), false, nil, nil, content.imageURL)
            }
        }
    }
}
