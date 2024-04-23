//
//  SignatureView.swift
//  CAShapeLayer
//
//  Created by 紹郁 on 2024/4/21.
//

import UIKit

class SignatureView: UIView {

    var lineColor = UIColor.black       //預設簽名顏色為黑色
    var lineWidth:CGFloat = 2           //預設簽名寬度為2
    var path:UIBezierPath?              //紀錄簽名路徑
    var touchPoint:CGPoint?             //所有簽名座標
    var startPoint:CGPoint?             //開始簽名座標
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //開始簽名，將第一個接觸到的座標指定給startPoint
        startPoint = touches.first?.location(in: self)
        
    }
        
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //正在簽名，將所有簽名時的座標指定給touchPoint
        touchPoint = touches.first?.location(in: self)
        //初始化path，在startPoint到touchPoint畫一條線
        //可以想像成move是開始的座標，addline是下一個的座標
        //畫完之後再將下一個座標指定成為開始的座標，這樣就能畫出連續的線
        // startPoint --> touchPoint (startPoint) --> touchPoint (startPoint) --> touchPoint
        path = UIBezierPath()
        path?.move(to: startPoint ?? CGPoint.init())
        path?.addLine(to: touchPoint ?? CGPoint.init())
        startPoint = touchPoint
        draw()
    }
    
    func draw() {
        let shape = CAShapeLayer()              
        //初始化 CAShapeLayer()
        shape.path = path?.cgPath               
        //設定 CAShapeLayer要畫出的路徑
        shape.strokeColor = lineColor.cgColor   
        //設定線條的顏色
        shape.lineWidth = lineWidth             
        //設定線條的寬度
        self.layer.addSublayer(shape)
        //將設定的屬性增加到SignatureView的layer
        self.setNeedsLayout()                   
        //更新畫面
    }
    
    func clearView(){
        path?.removeAllPoints()     
        //移除UIBezierPath的所有座標
        
        self.layer.sublayers = nil
        //將SignatureView的layer清除
        
        self.setNeedsDisplay()
        //更新畫面
    }
}
