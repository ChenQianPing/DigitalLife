//
//  TileView.swift
//  DigitalLife
//
//  Created by ChenQianPing on 16/7/10.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//


/*
 * 往游戏中加入数字块,一个数字块其实也就是一个view
 */


import UIKit

class TileView : UIView {
    
    // 数字块中的值
    var value : Int = 0 {
        didSet{
            backgroundColor = delegate.tileColor(value)
            lable.textColor = delegate.numberColor(value)
            lable.text = "\(value)"
        }
    }
    
    // 提供颜色选择
    unowned let delegate : AppearanceProviderProtocol
    
    // 一个数字块也就是一个lable
    var lable : UILabel
    
    init(position : CGPoint, width : CGFloat, value : Int, radius: CGFloat, delegate d: AppearanceProviderProtocol) {
        delegate = d
        lable = UILabel(frame : CGRect(x: 0 , y: 0 , width: width , height: width))
        lable.textAlignment = NSTextAlignment.center
        lable.minimumScaleFactor = 0.5
        lable.font = UIFont(name: "HelveticaNeue-Bold", size: 15) ?? UIFont.systemFont(ofSize: 15)
        super.init(frame: CGRect(x: position.x, y: position.y, width: width, height: width))
        addSubview(lable)
//        lable.layer.cornerRadius = 6
        
        layer.cornerRadius = radius
        
        self.value = value
        backgroundColor = delegate.tileColor(value)
        lable.textColor = delegate.numberColor(value)
        lable.text = "\(value)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
