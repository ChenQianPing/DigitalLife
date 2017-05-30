//
//  GamebordView.swift
//  DigitalLife
//
//  Created by ChenQianPing on 16/7/8.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//


// 这个文件就是我们游戏区块的视图文件

import UIKit

class GamebordView : UIView {
    
    var dimension : Int = 0           // 每行(列)区块个数
    var tileWidth : CGFloat = 0.0     // 每个小块的宽度
    var tilePadding : CGFloat = 0.0   // 每个小块间的间距
    var cornerRadius: CGFloat
    
    let provider = AppearanceProvider()
    
    let tilePopStartScale: CGFloat = 0.1
    let tilePopMaxScale: CGFloat = 1.1
    let tilePopDelay: TimeInterval = 0.05
    let tileExpandTime: TimeInterval = 0.18
    let tileContractTime: TimeInterval = 0.08
    
    let tileMergeStartScale: CGFloat = 1.0
    let tileMergeExpandTime: TimeInterval = 0.08
    let tileMergeContractTime: TimeInterval = 0.08
    
    let perSquareSlideDuration: TimeInterval = 0.08
    
    var tiles : Dictionary<IndexPath , TileView>

    // 这个方法其实就是在游戏区块中添加了dimension*dimension个小块,每个小块的颜色是我们传入的foregroundColor
    init(dimension d : Int, titleWidth width : CGFloat, titlePadding padding : CGFloat, cornerRadius radius: CGFloat,backgroundColor : UIColor, foregroundColor : UIColor ) {
        dimension = d
        tileWidth = width
        tilePadding = padding
        cornerRadius = radius
        tiles = Dictionary()
        let totalWidth = tilePadding + CGFloat(dimension)*(tilePadding + tileWidth)
        super.init(frame : CGRect(x: 0, y: 0, width: totalWidth, height: totalWidth))
        setColor(backgroundColor: backgroundColor , foregroundColor: foregroundColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 初始化,其中backgroundColor是游戏区块的背景色,foregroundColor是小块的颜色
    func setColor(backgroundColor bgcolor : UIColor, foregroundColor forecolor : UIColor){
        self.backgroundColor = bgcolor
        var xCursor = tilePadding
        var yCursor : CGFloat
        
        for _ in 0..<dimension{
            yCursor = tilePadding
            for _ in 0..<dimension {
                let tileFrame = UIView(frame : CGRect(x: xCursor, y: yCursor, width: tileWidth, height: tileWidth))
                tileFrame.backgroundColor = forecolor
                tileFrame.layer.cornerRadius = 8
                addSubview(tileFrame)
                yCursor += tilePadding + tileWidth
            }
            xCursor += tilePadding + tileWidth
        }
        
    }
    
    func insertTile(_ pos : (Int , Int) , value : Int) {
        assert(positionIsValied(pos))
        let (row , col) = pos
        let x = tilePadding + CGFloat(row)*(tilePadding + tileWidth)
        let y = tilePadding + CGFloat(col)*(tilePadding + tileWidth)
        
        let r = (cornerRadius >= 2) ? cornerRadius - 2 : 0
        
//        let tileView = TileView(position : CGPointMake(x, y), width: tileWidth, value: value, delegate: provider)
        
        let tileView = TileView(position: CGPoint(x: x, y: y), width: tileWidth, value: value, radius: r, delegate: provider)
        
        tileView.layer.setAffineTransform(CGAffineTransform(scaleX: tilePopStartScale, y: tilePopStartScale))
        
        addSubview(tileView)
        bringSubview(toFront: tileView)
        
        tiles[IndexPath(row : row , section:  col)] = tileView
        
        // 这里就是一些动画效果,如果有兴趣可以研究下,不影响功能
        UIView.animate(withDuration: tileExpandTime, delay: tilePopDelay, options: UIViewAnimationOptions(),
                                   animations: {
                                    tileView.layer.setAffineTransform(CGAffineTransform(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
            },
                                   completion: { finished in
                                    UIView.animate(withDuration: self.tileContractTime, animations: { () -> Void in
                                        tileView.layer.setAffineTransform(CGAffineTransform.identity)
                                    })
        })
    }
    
    func positionIsValied(_ position : (Int , Int)) -> Bool{
        let (x , y) = position
        return x >= 0 && x < dimension && y >= 0 && y < dimension
    }
    
    func reset() {
        for (_, tile) in tiles {
            tile.removeFromSuperview()
        }
        tiles.removeAll(keepingCapacity: true)
    }
    
    // 从from位置移动一个块到to位置,并赋予新的值value
    func moveOneTiles(_ from : (Int , Int)  , to : (Int , Int) , value : Int) {
        let (fx , fy) = from
        let (tx , ty) = to
        let fromKey = IndexPath(row: fx , section: fy)
        let toKey = IndexPath(row: tx, section: ty)
        
        // 取出from位置和to位置的数字块
        guard let tile = tiles[fromKey] else{
//            assert(false, "not exists tile")
            return
        }
        let endTile = tiles[toKey]
        
        // 将from位置的数字块的位置定到to位置
        var changeFrame = tile.frame
        changeFrame.origin.x = tilePadding + CGFloat(tx)*(tilePadding + tileWidth)
        changeFrame.origin.y = tilePadding + CGFloat(ty)*(tilePadding + tileWidth)
        
        tiles.removeValue(forKey: fromKey)
        tiles[toKey] = tile
        
        // 动画以及给新位置的数字块赋值
        let shouldPop = endTile != nil
        UIView.animate(withDuration: perSquareSlideDuration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.beginFromCurrentState,
                                   animations: {
                                    // Slide tile
                                    tile.frame = changeFrame
            },
                                   completion: { (finished: Bool) -> Void in
                                    // 对新位置的数字块赋值
                                    tile.value = value
                                    endTile?.removeFromSuperview()
                                    if !shouldPop || !finished {
                                        return
                                    }
                                    tile.layer.setAffineTransform(CGAffineTransform(scaleX: self.tileMergeStartScale, y: self.tileMergeStartScale))
                                    // Pop tile
                                    UIView.animate(withDuration: self.tileMergeExpandTime,
                                        animations: {
                                            tile.layer.setAffineTransform(CGAffineTransform(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
                                        },
                                        completion: { finished in
                                            // Contract tile to original size
                                            UIView.animate(withDuration: self.tileMergeContractTime, animations: {
                                                tile.layer.setAffineTransform(CGAffineTransform.identity)
                                            }) 
                                    })
        })
    }
    
    // 将from里两个位置的数字块移动到to位置,并赋予新的值,原理同上
    func moveTwoTiles(_ from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
        assert(positionIsValid(from.0) && positionIsValid(from.1) && positionIsValid(to))
        let (fromRowA, fromColA) = from.0
        let (fromRowB, fromColB) = from.1
        let (toRow, toCol) = to
        let fromKeyA = IndexPath(row: fromRowA, section: fromColA)
        let fromKeyB = IndexPath(row: fromRowB, section: fromColB)
        let toKey = IndexPath(row: toRow, section: toCol)
        
        guard let tileA = tiles[fromKeyA] else {
//            assert(false, "placeholder error")
            return
        }
        guard let tileB = tiles[fromKeyB] else {
//            assert(false, "placeholder error")
            return
        }
        
        var finalFrame = tileA.frame
        finalFrame.origin.x = tilePadding + CGFloat(toRow)*(tileWidth + tilePadding)
        finalFrame.origin.y = tilePadding + CGFloat(toCol)*(tileWidth + tilePadding)
        
        let oldTile = tiles[toKey]
        oldTile?.removeFromSuperview()
        tiles.removeValue(forKey: fromKeyA)
        tiles.removeValue(forKey: fromKeyB)
        tiles[toKey] = tileA
        
        UIView.animate(withDuration: perSquareSlideDuration,
                                   delay: 0.0,
                                   options: UIViewAnimationOptions.beginFromCurrentState,
                                   animations: {
                                    // Slide tiles
                                    tileA.frame = finalFrame
                                    tileB.frame = finalFrame
            },
                                   completion: { finished in
                                    // 赋值
                                    tileA.value = value
                                    tileB.removeFromSuperview()
                                    if !finished {
                                        return
                                    }
                                    tileA.layer.setAffineTransform(CGAffineTransform(scaleX: self.tileMergeStartScale, y: self.tileMergeStartScale))
                                    // Pop tile
                                    UIView.animate(withDuration: self.tileMergeExpandTime,
                                        animations: {
                                            tileA.layer.setAffineTransform(CGAffineTransform(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
                                        },
                                        completion: { finished in
                                            // Contract tile to original size
                                            UIView.animate(withDuration: self.tileMergeContractTime, animations: {
                                                tileA.layer.setAffineTransform(CGAffineTransform.identity)
                                            }) 
                                    })
        })
    }
    
    func positionIsValid(_ pos: (Int, Int)) -> Bool {
        let (x, y) = pos
        return (x >= 0 && x < dimension && y >= 0 && y < dimension)
    }
    
}
