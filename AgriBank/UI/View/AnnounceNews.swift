//
//  AnnounceNews.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/5/15.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import UIKit

let AnnounceNews_Repeat_Time:TimeInterval = 5

protocol AnnounceNewsDelegate {
    func clickNesw(_ index:Int)
}

class AnnounceNews: UIView, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var newsTableView: UITableView!
    var list:[String]? = nil
    var delegate:AnnounceNewsDelegate? = nil
    
    func setContentList(_ list:[String], _ delegate:AnnounceNewsDelegate? = nil) {
        self.list = list
        newsTableView.separatorStyle = .none
        newsTableView.reloadData()
        Timer.scheduledTimer(timeInterval: AnnounceNews_Repeat_Time, target: self, selector: #selector(scrollNewsView(_:)), userInfo: nil, repeats: true)
        self.delegate = delegate
    }
    
    func scrollNewsView(_ theTimer:Timer) {
        if list?.count != 0 {
            let lastIndexPath = newsTableView.indexPathsForVisibleRows?.last
            let scrollIndexPath = IndexPath(row:((lastIndexPath?.row)!+1 < (list?.count)! ? (lastIndexPath?.row)!+1 : 0), section: 0)
            newsTableView.scrollToRow(at: scrollIndexPath, at: .top, animated: (scrollIndexPath.row == 0 ? false: true))
        }
        else {
            theTimer.invalidate()
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.clickNesw(indexPath.row)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        if list != nil {
            return 1
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if list != nil {
            return (list?.count)!
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "newsCell")
//        cell.textLabel?.text = list?[indexPath.row]
//        cell.textLabel?.textColor = .white
        cell.textLabel?.attributedText = NSAttributedString(string: list?[indexPath.row] ?? "", attributes: [NSFontAttributeName:Default_Font,NSForegroundColorAttributeName:UIColor.white])
        
        
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.frame.height
    }
}
