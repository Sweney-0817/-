//
//  PolygonView.swift
//  AgriBank
//
//  Created by SYSTEX on 2018/7/18.
//  Copyright © 2018年 Systex. All rights reserved.
//

import UIKit

protocol PolygonViewDelegate {
    func clickPolygonView(_ strContent: String)
}
class PolygonView: UIView {
    var m_strContent: String? = nil
    var m_aryPoint: [CGPoint] = [CGPoint]()
    var m_Delegate: PolygonViewDelegate? = nil

    init (frame: CGRect, content: String) {
        super.init(frame: frame)
//        self.m_Delegate = delegate
        m_strContent = content
//        self.makePoly(m_strContent ?? "", frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        self.makePoly(m_strContent ?? "", frame: frame)
        super.draw(rect)
    }
    
    private func makePoly(_ str: String, frame: CGRect) {
        let vPoly:UIView = UIView(frame: CGRect(origin: .zero, size: frame.size))
        vPoly.backgroundColor = UIColor.clear
        let minusY = drawPoly(vPoly)
        let lb: UILabel = UILabel(frame: CGRect(origin: .zero, size: frame.size))
        lb.text = m_strContent
        lb.textAlignment = .center
        self.addSubview(vPoly)
        self.addSubview(lb)
        self.frame.origin = CGPoint(x: self.frame.origin.x, y: self.frame.origin.y-minusY+1)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(HandleTapGesture))
        self.addGestureRecognizer(gesture)
    }
    @objc private func HandleTapGesture(sender: UITapGestureRecognizer) {
        let point: CGPoint = sender.location(in: self)
        if (self.checkClickPoint(point)) {
            NSLog(String(format: "==== polyTap[%@][%f][%f] ====", m_strContent ?? "", point.x, point.y))
            m_Delegate?.clickPolygonView(m_strContent!)
        }
        else {
            NSLog(String(format: "==== [%f][%f] ====", m_strContent ?? "", point.x, point.y))
        }
    }
    private func mySin(_ fNum: CGFloat) -> CGFloat {
        return sin(fNum*CGFloat.pi/180);
    }
    private func myCos(_ fNum: CGFloat) -> CGFloat {
        return cos(fNum*CGFloat.pi/180);
    }
    private func drawPoly(_ target: UIView) -> CGFloat {
        m_aryPoint.removeAll()
        let center: CGPoint = CGPoint(x: target.frame.size.width/2, y: target.frame.size.height/2)
        let allAngle: CGFloat = 360.0
        let allPoly: Int = 6
        let fRadius: CGFloat = CGFloat(min(center.x, center.y))
        let path: UIBezierPath = UIBezierPath()
        //        path.lineWidth = 3
        var minY: CGFloat = CGFloat.greatestFiniteMagnitude
        for i in 0..<allPoly {
            var point: CGPoint = CGPoint()
            point.x = fRadius*myCos(allAngle/CGFloat(allPoly)*CGFloat(i))+center.x
            point.y = fRadius*mySin(allAngle/CGFloat(allPoly)*CGFloat(i))+center.y
            if (i==0) {
                path.move(to: point)
            }
            else {
                path.addLine(to: point)
            }
            m_aryPoint.append(point)
            minY = min(minY, point.y)
        }
        path.close()
        //for test
        //漸層
        let c = UIGraphicsGetCurrentContext()!
//        let clipPath: CGPath = UIBezierPath(ovalIn: converted_rect).cgPath
        let clipPath: CGPath = path.cgPath
        c.setFillColor(UIColor.white.cgColor)
        c.saveGState()
        c.setLineWidth(5.0)
        c.addPath(clipPath)
        c.replacePathWithStrokedPath()
        c.clip()

        // Draw gradient
        let colors = [UIColor.blue.cgColor, UIColor.red.cgColor]
        let offsets = [ CGFloat(0.0), CGFloat(1.0) ]
        let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: offsets)
        let start = CGPoint(x: 0, y: 0)
        let end = CGPoint(x: 0, y: self.frame.maxY)
        c.drawLinearGradient(grad!, start: start, end: end, options: [])

        c.restoreGState()

        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
//        let arc: CAShapeLayer = CAShapeLayer()
//        arc.path = path.cgPath
//        arc.position = self.center
//        arc.fillColor = UIColor.white.cgColor
//        arc.strokeColor = UIColor.purple.cgColor
//        arc.lineWidth = 3

//        let gradient = CAGradientLayer()
//        gradient.frame = self.bounds
//        gradient.colors = [UIColor.magenta.cgColor, UIColor.cyan.cgColor]
//        let shapeMask = CAShapeLayer()
//        shapeMask.path = path.cgPath
//        gradient.mask = shapeMask
//        target.layer.addSublayer(gradient)
//==========================================
        let shapLayer: CAShapeLayer = CAShapeLayer()
        shapLayer.lineWidth = 3
//        shapLayer.fillColor = UIColor.clear.cgColor
//        shapLayer.strokeColor = UIColor.blue.cgColor
        shapLayer.path = path.cgPath
        target.layer.addSublayer(shapLayer)

        return minY
    }
    private func checkClickPoint(_ point: CGPoint) -> Bool {
        var iCross: Int = 0 // 交點
        let iPointCount: Int = m_aryPoint.count
        for i in 0..<iPointCount {
            let p1: CGPoint = m_aryPoint[i]
            let p2: CGPoint = m_aryPoint[(i + 1) % iPointCount]
            // 求解 y=p.y 與 p1 p2 的交點
            // p1p2 與 y=p0.y平行
            if (p1.y == p2.y) {
                continue
            }
            // 交點在p1p2延伸線上
            if (point.y < min(p1.y, p2.y)) {
                continue
            }
            // 交點在p1p2延伸線上
            if (point.y >= max(p1.y, p2.y)) {
                continue
            }
            // 求交點的 X 座標
            let x: CGFloat = (point.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + (p1.x)
            // 只統計單邊交點
            if (x > point.x) {
                iCross += 1
            }
        }
        return (iCross % 2 == 1)
    }
}
