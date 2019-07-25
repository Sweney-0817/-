//
//  IntroductionView.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/5/18.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import UIKit

protocol IntroductionViewDelegate {
    func closeIntroductionView()
}

@objcMembers
class IntroductionView: UIView, UIScrollViewDelegate {
    var introductionDelegate:IntroductionViewDelegate? = nil
    var pageControl:UIPageControl? = nil
    var scrollView:UIScrollView? = nil

    func SetImageList(_ list: [UIImage], setDelegate delegate: IntroductionViewDelegate) {
        introductionDelegate = delegate
        
        scrollView = UIScrollView(frame: CGRect(origin: .zero, size: frame.size))
        scrollView?.contentSize = CGSize(width: frame.width*CGFloat(list.count), height: frame.height)
        scrollView?.bounces = false
        scrollView?.isPagingEnabled = true
        scrollView?.delegate = self
        addSubview(scrollView!)
        
        var position = CGPoint.zero
        for image in list {
            let imageView = UIImageView(frame: CGRect(origin: position, size: frame.size))
            imageView.image = image
            scrollView?.addSubview(imageView)
            position.x += frame.width
        }
        
        pageControl = UIPageControl()
        pageControl?.numberOfPages = list.count
        pageControl?.isEnabled = false
        let pageConSize = (pageControl?.size(forNumberOfPages: list.count))!
        pageControl?.frame = CGRect(origin: CGPoint(x: frame.midX-pageConSize.width/2, y: frame.maxY-pageConSize.height), size: pageConSize)
        addSubview(pageControl!)
        
        let closeButton = UIButton(frame: CGRect(origin: (scrollView?.frame.origin)!, size: (scrollView?.contentSize)!))
        closeButton.addTarget(self, action: #selector(clickCloseButton(_:)), for: .touchUpInside)
        closeButton.backgroundColor = .clear
        scrollView?.addSubview(closeButton)
    }
    
    func clickCloseButton(_ senden: UIButton) {
        introductionDelegate?.closeIntroductionView()
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x/scrollView.frame.width)
        pageControl?.currentPage = page
    }
}
