//
//  ScoreView.swift
//  DigitalLife
//
//  Created by ChenQianPing on 16/7/10.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//


/* 
 * 计分板同样作为一个view
 */

import UIKit

// 这里协议的作用是方便别的类中调用计分板的scoreChanged方法
protocol ScoreProtocol {
    func scoreChanged(newScore s : Int)
}

class ScoreView : UIView , ScoreProtocol {
    // 计分板本身是个lable,作用是显示分数
    var lable : UILabel
    // 分数
    var score : Int = 0 {
        didSet {
            lable.text = "SCORE:\(score)"
        }
    }
    
    let defaultFrame = CGRect(x: 0, y: 0, width: 140, height: 40)
    
    init(backgroundColor bgColor : UIColor, textColor tColor : UIColor , font : UIFont) {
        lable = UILabel(frame : defaultFrame)
        lable.textAlignment = NSTextAlignment.center
        super.init(frame : defaultFrame)
        backgroundColor = bgColor
        lable.textColor = tColor
        lable.font = font
        lable.layer.cornerRadius = 6
        self.addSubview(lable)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scoreChanged(newScore s : Int){
        score = s
    }

}
