//
//  NumbertailGameController.swift
//  DigitalLife
//
//  Created by ChenQianPing on 16/7/8.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//


// 这个文件主要处理游戏的初始化等逻辑

import UIKit

protocol GameModelProtocol : class {
    func changeScore(_ score : Int)
    func insertTile(_ position : (Int , Int), value : Int)
    func moveOneTile(_ from: (Int, Int), to: (Int, Int), value: Int)
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int)
}

class NumbertailGameController : UIViewController {
    
    var dimension : Int = 4                   // 2048游戏中每行每列含有多少个块,一般设置为4
    var threshold : Int = 2048                // 最高分数,判断输赢时使用,一般设置为2048
    
    var bord : GamebordView?
    var scoreV : ScoreView?
    var gameModle : GameModle?
    
    let boardWidth: CGFloat = 280.0        // 游戏区域的长度和高度
    let thinPadding: CGFloat = 3.0         // 游戏区里面小块间的间距
    let viewPadding: CGFloat = 10.0        // 计分板和游戏区块的间距
    let verticalViewOffset: CGFloat = 0.0  // 一个初始化属性,后面会有地方用到
    
    // 这里主要是限制了最少两个块以及最低分数为8分,
    // 另外设置了整个面板的背景色,关于颜色,大家可以取自己喜欢的色和直接换掉上面的十六进制数值即.
    init(demension d : Int , threshold t : Int) {
        dimension = d < 2 ? 2 : d  // 限制了最少两个块
        threshold = t < 8 ? 8 : t  // 最低分数为8分
        super.init(nibName: nil, bundle: nil)
        
        gameModle = GameModle(dimension: dimension , threshold: threshold , delegate: self )
        
        view.backgroundColor = UIColor(red : 0xE6/255, green : 0xE2/255, blue : 0xD4/255, alpha : 1)
        
        setupSwipeConttoller()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
    }
    
    // 注册监听器,监听当前视图里的手指滑动操作,上下左右分别对应下面的四个方法
    func setupSwipeConttoller() {
        let upSwipe = UISwipeGestureRecognizer(target: self , action: #selector(NumbertailGameController.upCommand(_:)))
        upSwipe.numberOfTouchesRequired = 1
        upSwipe.direction = UISwipeGestureRecognizerDirection.up
        view.addGestureRecognizer(upSwipe)
        
        let downSwipe = UISwipeGestureRecognizer(target: self , action: #selector(NumbertailGameController.downCommand(_:)))
        downSwipe.numberOfTouchesRequired = 1
        downSwipe.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(downSwipe)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self , action: #selector(NumbertailGameController.leftCommand(_:)))
        leftSwipe.numberOfTouchesRequired = 1
        leftSwipe.direction = UISwipeGestureRecognizerDirection.left
        view.addGestureRecognizer(leftSwipe)
        
        let rightSwipe = UISwipeGestureRecognizer(target: self , action: #selector(NumbertailGameController.rightCommand(_:)))
        rightSwipe.numberOfTouchesRequired = 1
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        view.addGestureRecognizer(rightSwipe)
    }
    
    // 向上滑动的方法,调用queenMove,传入MoveDirection.UP
    func upCommand(_ r : UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(MoveDirection.up , completion: { (changed : Bool) -> () in
            if  changed {
                self.followUp()
            }
        })
    }
    // 向下滑动的方法,调用queenMove,传入MoveDirection.DOWN
    func downCommand(_ r : UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(MoveDirection.down , completion: { (changed : Bool) -> () in
            if  changed {
                self.followUp()
            }
        })
    }
    
    // 向左滑动的方法,调用queenMove,传入MoveDirection.LEFT
    func leftCommand(_ r : UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(MoveDirection.left , completion: { (changed : Bool) -> () in
            if  changed {
                self.followUp()
            }
        })
    }
    // 向右滑动的方法,调用queenMove,传入MoveDirection.RIGHT
    func rightCommand(_ r : UIGestureRecognizer) {
        let m = gameModle!
        m.queenMove(MoveDirection.right , completion: { (changed : Bool) -> () in
            if  changed {
                self.followUp()
            }
        })
    }
    // 移动之后需要判断用户的输赢情况,如果赢了则弹框提示,给一个重玩和取消按钮
    func followUp() {
        assert(gameModle != nil)
        let m = gameModle!
        let (userWon, _) = m.userHasWon()
        if userWon {
            let winAlertView = UIAlertController(title: "结果", message: "你贏了", preferredStyle: UIAlertControllerStyle.alert)
            let resetAction = UIAlertAction(title: "重置", style: UIAlertActionStyle.default, handler: {(u : UIAlertAction) -> () in
                self.reset()
            })
            winAlertView.addAction(resetAction)
            let cancleAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil)
            winAlertView.addAction(cancleAction)
            self.present(winAlertView, animated: true, completion: nil)
            return
        }
        // 如果没有赢则需要插入一个新的数字块
        let randomVal = Int(arc4random_uniform(10))
        m.insertRandomPositoinTile(randomVal == 1 ? 4 : 2)
        // 插入数字块后判断是否输了,输了则弹框提示
        if m.userHasLost() {
            NSLog("You lost...")
            let lostAlertView = UIAlertController(title: "结果", message: "你输了", preferredStyle: UIAlertControllerStyle.alert)
            let resetAction = UIAlertAction(title: "重置", style: UIAlertActionStyle.default, handler: {(u : UIAlertAction) -> () in
                self.reset()
            })
            lostAlertView.addAction(resetAction)
            let cancleAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.default, handler: nil)
            lostAlertView.addAction(cancleAction)
            self.present(lostAlertView, animated: true, completion: nil)
        }
    }
    
    func reset() {
        assert(bord != nil && gameModle != nil)
        let b = bord!
        let m = gameModle!
        b.reset()
        m.reset()
        m.insertRandomPositoinTile(2)
        m.insertRandomPositoinTile(2)
    }
    
    
    func setupGame() {
        let viewWidth = view.bounds.size.width
        let viewHeight = view.bounds.size.height
        
        func xposition2Center(view v : UIView) -> CGFloat{
            let vWidth = v.bounds.size.width
            return 0.5*(viewWidth - vWidth)
            
        }
        
        func yposition2Center(_ order : Int , views : [UIView]) -> CGFloat {
            assert(views.count > 0)
            let totalViewHeigth = CGFloat(views.count - 1)*viewPadding +
                views.map({$0.bounds.size.height}).reduce(verticalViewOffset, {$0 + $1})
            let firstY = 0.5*(viewHeight - totalViewHeigth)
            
            var acc : CGFloat = 0
            for i in 0..<order{
                acc += viewPadding + views[i].bounds.size.height
            }
            return acc + firstY
        }
        
        let width = (boardWidth - thinPadding*CGFloat(dimension + 1))/CGFloat(dimension)
        
        let scoreView = ScoreView(
            backgroundColor:  UIColor(red : 0xA2/255, green : 0x94/255, blue : 0x5E/255, alpha : 1),
            textColor: UIColor(red : 0xF3/255, green : 0xF1/255, blue : 0x1A/255, alpha : 0.5),
            font: UIFont(name: "HelveticaNeue-Bold", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
        )
        
        let gamebord = GamebordView(
            dimension : dimension,
            titleWidth: width,
            titlePadding: thinPadding,
            cornerRadius: 6,
            backgroundColor:  UIColor(red : 0x90/255, green : 0x8D/255, blue : 0x80/255, alpha : 1),
            foregroundColor:UIColor(red : 0xF9/255, green : 0xF9/255, blue : 0xE3/255, alpha : 0.5)
        )
        
        let views = [scoreView , gamebord]
        
        var f = scoreView.frame
        f.origin.x = xposition2Center(view: scoreView)
        f.origin.y = yposition2Center(0, views: views)
        scoreView.frame = f
        
        f = gamebord.frame
        f.origin.x = xposition2Center(view: gamebord)
        f.origin.y = yposition2Center(1, views: views)
        gamebord.frame = f
        
        view.addSubview(scoreView)
        view.addSubview(gamebord)
        
        scoreV = scoreView
        bord = gamebord
        
        scoreView.scoreChanged(newScore: 0)
        
        assert(gameModle != nil)
        let modle = gameModle!
        modle.insertRandomPositoinTile(2)
        modle.insertRandomPositoinTile(2)
        
    }

}


extension NumbertailGameController : GameModelProtocol {
    
    func changeScore(_ score : Int) {
        assert(scoreV != nil)
        let s =  scoreV!
        s.scoreChanged(newScore: score)
    }
    
    func insertTile(_ pos : (Int , Int) , value : Int){
        assert(bord != nil)
        let b = bord!
        b.insertTile(pos, value: value)
    }
    
    func moveOneTile(_ from: (Int, Int), to: (Int, Int), value: Int) {
        assert(bord != nil)
        let b = bord!
        b.moveOneTiles(from, to: to, value: value)
    }
    
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(bord != nil)
        let b = bord!
        b.moveTwoTiles(from, to: to, value: value)
    }
    
}


/*
 * 上面的代码中注释已经很详细了,大家可能疑问的就是x和y坐标的计算.
 * x坐标很简单,其实就是:当前面板总宽度减去游戏区块宽度,剩下的就是空余的宽度,再除以2就是x点的坐标了。
 * y坐标稍微复杂点在于,以后会加入计分面板,所以他的值应该是:
 * 当前面板总高度减去所有视图的总高度除以2然后在加上在游戏区块之前的视图的总高度,就是游戏区域的y坐标值。
 *
 */
