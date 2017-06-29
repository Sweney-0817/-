//
//  SideMenuViewController.swift
//  BankBase
//
//  Created by TongYoungRu on 2017/4/24.
//  Copyright © 2017年 TongYoungRu. All rights reserved.
//

import UIKit

protocol SideMenuViewDelegate {
    func willShowViewController(center: UIViewController?) -> Void
}

class SideMenuViewController: UIViewController {
    
    private enum MenuState {
        case Hide
        case Expanding
        case Expand
        case ExpandingToClose
    }
    
    private var leftViewController:UIViewController? = nil
    private var leftDelegate:SideMenuViewDelegate? = nil
    private var rightViewController:UIViewController? = nil
    private var rightDelegate:SideMenuViewDelegate? = nil
    private var centerViewController:UINavigationController? = nil
    private var currentMenuState:MenuState = .Hide
    private var isRightMenuShow = true
    private var moveEndX:CGFloat = 0
    private let animateTime = 0.5
    private var tapGesture:UITapGestureRecognizer? = nil
    private let SideMenu_shadowOpacity = Float(0.5)
    private let SideMenu_shadowRadius = CGFloat(20)
    
    
    // MARK: - Life cycle
    convenience init(SetCenter center:UIViewController, SetLeft left:UIViewController? = nil, SetRight right:UIViewController? = nil, SetWidthRate rate:Float) {
        self.init(nibName: nil, bundle: nil)
        centerViewController = UINavigationController(rootViewController:center)
        view.addSubview((centerViewController?.view)!)
        addChildViewController(centerViewController!)
        centerViewController?.didMove(toParentViewController:self)
        leftViewController = left
        leftDelegate = left as? SideMenuViewDelegate
        rightViewController = right
        rightDelegate = right as? SideMenuViewDelegate
        moveEndX = self.view.frame.width*CGFloat(rate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(HandlePanGesture))
        view.addGestureRecognizer(gesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - pubilc function
    func ShowSideMenu(_ IsRight:Bool) {
        switch currentMenuState {
        case .Hide:
            if AddSideController(IsRight) {
                AnimateSidemenu(IsRight)
                isRightMenuShow = IsRight
            }
        
        case .Expand:
            if IsRight {
                rightDelegate?.willShowViewController(center: self.centerViewController?.topViewController)
            }
            else {
                leftDelegate?.willShowViewController(center: self.centerViewController?.topViewController)
            }
            HideSideMenu(IsRight)
            
        default:
            break
        }
    }
    
    // MARK: - private
    private func AnimateSidemenu(_ IsRight:Bool) {
        UIView.animate(withDuration: animateTime, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { () -> Void in
            if IsRight {
                self.centerViewController?.view.frame.origin = CGPoint(x:self.moveEndX-self.view.frame.width, y:0)
            }
            else {
                self.centerViewController?.view.frame.origin = CGPoint(x:self.view.frame.width-self.moveEndX, y:0)
            }
        }, completion: { (complete) -> Void in
            if complete {
                if IsRight {
                    self.rightViewController?.didMove(toParentViewController: self)
                }
                else {
                    self.leftViewController?.didMove(toParentViewController: self)
                }
                self.currentMenuState = .Expand
                if self.tapGesture == nil {
                    self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.HandleTapGseture))
                    self.centerViewController?.view.addGestureRecognizer(self.tapGesture!)
                }
            }
        })
    }
    
    private func HideSideMenu(_ IsRight:Bool)  {
        UIView.animate(withDuration: animateTime, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: { () -> Void in
            self.centerViewController?.view.frame.origin = .zero
        }, completion: { (complete) -> Void in
            if complete {
                if IsRight {
                    self.rightViewController?.view.removeFromSuperview()
                    self.rightViewController?.removeFromParentViewController()
                }
                else {
                    self.leftViewController?.view.removeFromSuperview()
                    self.leftViewController?.removeFromParentViewController()
                }
                self.currentMenuState = .Hide
                self.centerViewController?.view.layer.shadowOpacity = 0
                if self.tapGesture != nil {
                    self.centerViewController?.view.removeGestureRecognizer(self.tapGesture!)
                    self.tapGesture = nil
                }
            }
        })
    }
    
    private func AddSideController(_ IsRight:Bool) -> Bool {
        var success = false
        if IsRight {
            if rightViewController != nil {
                rightViewController?.view.frame = CGRect(origin: CGPoint(x: moveEndX, y: 0), size: CGSize(width: view.frame.width-moveEndX, height: view.frame.height))
                view.insertSubview((rightViewController?.view)!, at:0)
                addChildViewController(rightViewController!)
                success = true
            }
        }
        else {
            if leftViewController != nil {
                leftViewController?.view.frame = CGRect(origin: .zero, size: CGSize(width: view.frame.width-moveEndX, height: view.frame.height))
                view.insertSubview((leftViewController?.view)!, at:0)
                addChildViewController(leftViewController!)
                success = true
            }
        }
        
        if success {
            centerViewController?.view.layer.shadowOpacity = SideMenu_shadowOpacity
            centerViewController?.view.layer.shadowRadius = SideMenu_shadowRadius
        }
        
        return success
    }
    
    // MARK: - GestureRecognizer Selector
    func HandlePanGesture(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            if currentMenuState == .Expand {
                currentMenuState = .ExpandingToClose
            }
            else if currentMenuState == .Hide {
                let poiont = sender.velocity(in: view)
                if poiont.x < 0 && AddSideController(true) {
                    currentMenuState = .Expanding
                    isRightMenuShow = true
                }
                else if poiont.x > 0 && AddSideController(false) {
                    currentMenuState = .Expanding
                    isRightMenuShow = false
                }
            }
            
        case .changed:
            if currentMenuState == .Expanding || currentMenuState == .ExpandingToClose {
                var positionX = (centerViewController?.view!.frame.origin.x)! + sender.translation(in:centerViewController?.view!).x
                if isRightMenuShow {
                    if positionX < (moveEndX-(centerViewController?.view.frame.width)!) {
                        positionX = moveEndX-(centerViewController?.view.frame.width)!
                    }
                    else if positionX > 0 {
                        positionX = 0
                    }
                }
                else {
                    if positionX > ((centerViewController?.view.frame.width)!-moveEndX) {
                        positionX = (centerViewController?.view.frame.width)!-moveEndX
                    }
                    else if positionX < 0 {
                        positionX = 0
                    }
                }
                centerViewController?.view!.frame.origin.x = positionX
                sender.setTranslation(.zero, in: centerViewController?.view)
            }
            
        default:
            if currentMenuState == .ExpandingToClose {
                 HideSideMenu(isRightMenuShow)
            }
            else {
                if isRightMenuShow {
                    if (centerViewController?.view!.frame.maxX)! > (rightViewController?.view.frame.midX)! {
                        HideSideMenu(isRightMenuShow)
                    }
                    else {
                        AnimateSidemenu(isRightMenuShow)
                    }
                }
                else {
                    if (centerViewController?.view!.frame.minX)! > (leftViewController?.view.frame.midX)!  {
                        AnimateSidemenu(isRightMenuShow)
                    }
                    else {
                        HideSideMenu(isRightMenuShow)
                    }
                }
            }
            break
        }
    }
    
    func HandleTapGseture(_ sender: UITapGestureRecognizer) {
        if currentMenuState == .Expand && sender.state == .ended {
            HideSideMenu(isRightMenuShow)
        }
    }
}

