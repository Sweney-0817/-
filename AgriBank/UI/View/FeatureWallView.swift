//
//  FeatureWallView.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/5/16.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import UIKit

protocol FeatureWallViewDelegate {
    func clickFeatureBtn(_ ID: PlatformFeatureID)
}

let FeatureWall_PageControl_BottomDistance:CGFloat = 25
//let FeatureWall_PageControl_currentPageColor = UIColor(red: 69/255, green: 166/255, blue: 108/255, alpha:1)
//let FeatureWall_PageControl_PageColor = UIColor(red: 69/255, green: 166/255, blue: 108/255, alpha:0.2)
let FeatureWall_PageControl_currentPageColor = UIColor(red: 242/255, green: 193/255, blue: 74/255, alpha:1)
let FeatureWall_PageControl_PageColor = UIColor(red: 181/255, green: 181/255, blue: 181/255, alpha:1)

class FeatureWallView: UIView, UIScrollViewDelegate {
    let scrollview = UIScrollView()
    var pageCon = UIPageControl()
    var featureIDList = [PlatformFeatureID]()
    var featureDelegate:FeatureWallViewDelegate? = nil
    var vertical = 0
    var horizontal = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollview.frame = frame
        scrollview.frame.size.height = frame.size.height - FeatureWall_PageControl_BottomDistance/2
        scrollview.frame.origin = .zero
        addSubview(scrollview)
        pageCon.frame.origin.y = frame.size.height - FeatureWall_PageControl_BottomDistance
        pageCon.frame.origin.x = frame.size.width/2 - pageCon.frame.size.width/2
        setFeatureWall(vertical, horizontal)
        addSubview(pageCon)
    }
    
    // MARK: - public
    func setInitial(_ list: [PlatformFeatureID], setVertical vertical: Int, setHorizontal horizontal: Int, SetDelegate delegate:FeatureWallViewDelegate) {
        featureIDList = list
        featureDelegate = delegate
        self.vertical = vertical
        self.horizontal = horizontal
        scrollview.bounces = false
        scrollview.isPagingEnabled = true
        scrollview.delegate = self
        scrollview.showsHorizontalScrollIndicator = false
        
        pageCon.numberOfPages = list.count%(vertical*horizontal) == 0 ? list.count/(vertical*horizontal) : list.count/(vertical*horizontal)+1
        pageCon.frame.size = pageCon.size(forNumberOfPages: pageCon.numberOfPages)
        pageCon.currentPageIndicatorTintColor = FeatureWall_PageControl_currentPageColor
        pageCon.pageIndicatorTintColor = FeatureWall_PageControl_PageColor
        pageCon.hidesForSinglePage = true
    }
    
    func setContentList(_ list: [PlatformFeatureID] ) {
        featureIDList = list
        setFeatureWall(vertical, horizontal)
        pageCon.numberOfPages = list.count%(vertical*horizontal) == 0 ? list.count/(vertical*horizontal) : list.count/(vertical*horizontal)+1
    }

    // MARK: - private
    private func setFeatureWall(_ vertical: Int, _ horizontal: Int)  {
        scrollview.subviews.forEach{ view in if view is FeatureWallCellView {view.removeFromSuperview()} }
        if featureIDList.count > 0 {
            let page = CGFloat( featureIDList.count%(vertical*horizontal) == 0 ? featureIDList.count/(vertical*horizontal) : featureIDList.count/(vertical*horizontal)+1 )
            scrollview.contentSize = CGSize(width: scrollview.frame.size.width*page, height: scrollview.frame.size.height)
            if vertical != 0 && horizontal != 0 {
                let width = scrollview.frame.size.width / CGFloat(vertical)
                let height = scrollview.frame.size.height / CGFloat(horizontal)
                for current in 0...featureIDList.count-1 {
                    let position = getXYPositionByIndex(current, vertical, horizontal)
                    let wallCell = Platform.plat.getUIByID(.UIID_FeatureWallCell, self) as! FeatureWallCellView
                    wallCell.frame = CGRect(x: CGFloat(position.x)*width + CGFloat(position.page)*scrollview.frame.size.width, y: CGFloat(position.y)*height, width: width, height: height)
                    if let info = Platform.plat.getFeatureInfoByID(featureIDList[current]) {
                        wallCell.imageView.image = UIImage(named: String(featureIDList[current].rawValue))
                        wallCell.titleLabel.text = info.name
                        wallCell.titleLabel.font = Scale_Default_Font
                        wallCell.button.addTarget(self, action: #selector(clickFeatureBtn(_:)), for: .touchUpInside)
                        wallCell.button.tag = featureIDList[current].rawValue
                        if UIScreen.main.bounds.height == AgriBank_4sInchSize {
                            wallCell.titleLabel.font = AgriBank_4sInchFont
                        }
                    }
                    scrollview.addSubview(wallCell)
                }
                makeLine(scrollview, vertical, horizontal, page, featureIDList.count)
            }
        }
    }
    
    private func getXYPositionByIndex(_ index: Int, _ vertical: Int, _ horizontal: Int) -> (x: Int, y: Int, page: Int) {
        let pageCount = vertical * horizontal
        let page = index / pageCount
        let x = index % vertical
        let y = (index % pageCount) / vertical
        return (x, y, page)
    }
    
    private func makeLine(_ scrollview: UIScrollView, _ vertical: Int, _ horizontal: Int, _ page: CGFloat, _ total: Int) {
        let Line_Color = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
        scrollview.subviews.forEach{ view in if view.tag == 9876 {view.removeFromSuperview()} }
        let verticalLineSize: CGSize = CGSize(width: 1.0, height: scrollview.frame.size.height/CGFloat(horizontal)-40.0)
        let horizontalLineSize: CGSize = CGSize(width: scrollview.frame.size.width-25.0, height: 1.0)
        for current in 0..<Int(page) {
            let xPosition: CGFloat = scrollview.frame.size.width / CGFloat(vertical)
            let yPosition: CGFloat = scrollview.frame.size.height / CGFloat(horizontal) + 20.0
            if (current == Int(page)-1) {
                let lastPageCount = total % (vertical * horizontal)
                for x in 1..<vertical {
                    //上半直線
                    let original: CGPoint = CGPoint(x: xPosition * CGFloat(x) + scrollview.frame.size.width * CGFloat(current), y: 20.0)
                    let verticalLine: UIView = UIView(frame: CGRect(origin: original, size: verticalLineSize))
                    verticalLine.backgroundColor = Line_Color
                    verticalLine.tag = 9876
                    //下半直線
                    let original2: CGPoint = CGPoint(x: xPosition * CGFloat(x) + scrollview.frame.size.width * CGFloat(current), y: yPosition)
                    let verticalLine2: UIView = UIView(frame: CGRect(origin: original2, size: verticalLineSize))
                    verticalLine2.backgroundColor = Line_Color
                    verticalLine2.tag = 9876
                    switch lastPageCount {
                    case 0:
                        scrollview.addSubview(verticalLine)
                        scrollview.addSubview(verticalLine2)
                    case 1:
                        if (x == 1) { scrollview.addSubview(verticalLine) }
                    case 2:
                        scrollview.addSubview(verticalLine)
                    case 3:
                        scrollview.addSubview(verticalLine)
                    case 4:
                        scrollview.addSubview(verticalLine)
                        if (x == 1) { scrollview.addSubview(verticalLine2) }
                    case 5:
                        scrollview.addSubview(verticalLine)
                        scrollview.addSubview(verticalLine2)
                    default:
                        break
                    }
                }
            }
            else {
                for x in 1..<vertical {
                    //上半直線
                    let original: CGPoint = CGPoint(x: xPosition * CGFloat(x) + scrollview.frame.size.width * CGFloat(current), y: 20.0)
                    let verticalLine: UIView = UIView(frame: CGRect(origin: original, size: verticalLineSize))
                    verticalLine.backgroundColor = Line_Color
                    verticalLine.tag = 9876
                    scrollview.addSubview(verticalLine)
                    //下半直線
                    let original2: CGPoint = CGPoint(x: xPosition * CGFloat(x) + scrollview.frame.size.width * CGFloat(current), y: yPosition)
                    let verticalLine2: UIView = UIView(frame: CGRect(origin: original2, size: verticalLineSize))
                    verticalLine2.backgroundColor = Line_Color
                    verticalLine2.tag = 9876
                    scrollview.addSubview(verticalLine2)
                }
            }
            //畫橫線
            let horizontalLinePosition: CGPoint = CGPoint(x: scrollview.frame.size.width * CGFloat(current)+12.0, y: scrollview.frame.size.height / CGFloat(horizontal))
            let horizontalLine: UIView = UIView(frame: CGRect(origin: horizontalLinePosition, size: horizontalLineSize))
            horizontalLine.backgroundColor = Line_Color
            horizontalLine.tag = 9876
            scrollview.addSubview(horizontalLine)
        }
    }
    // MARK: - selector
    @objc func clickFeatureBtn(_ sender:UIButton)  {
        featureDelegate?.clickFeatureBtn(PlatformFeatureID(rawValue: sender.tag)!)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageCon.currentPage = Int(scrollview.contentOffset.x / UIScreen.main.bounds.size.width)
    }
}

class FeatureWallCellView: UIView {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
}
