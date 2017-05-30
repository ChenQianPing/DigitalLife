//
//  GameModle.swift
//  DigitalLife
//
//  Created by ChenQianPing on 16/7/10.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//


/* 
 * 接下来,我们需要新建一个GameModle.swift充当我们的游戏区域的modle层,
 * 来记录当前游戏的状态以及提供一些游戏自身的操作等
 */

import UIKit

class GameModle : NSObject {
    let dimension : Int
    let threshold : Int
    // 存放数字块状态信息
    var gamebord : SequenceGamebord<TileEnum>
    
    unowned let delegate : GameModelProtocol
    // 当前分数,改变后回调用分数视图渲染分数
    var score : Int = 0{
        didSet{
            delegate.changeScore(score)
        }
    }
    
    // 初始化一个都存的Empty的SequenceGamebord<TileEnum>
    init(dimension : Int , threshold : Int , delegate : GameModelProtocol) {
        self.dimension = dimension
        self.threshold = threshold
        self.delegate = delegate
        gamebord = SequenceGamebord(demision: dimension , initValue: TileEnum.empty)
        super.init()
    }
    
    // 新加方法取出游戏区中空置的块
    // 代码很简单,就是通过遍历SequenceGamebord<TileEnum>,将不为空的位置组成一个(Int,Int)的字典数组返回.
    func getEmptyPosition() -> [(Int , Int)] {
        var emptyArrys : [(Int , Int)] = []
        for i in 0..<dimension {
            for j in 0..<dimension {
                if case .empty = gamebord[i , j] {
                    emptyArrys.append((i , j))
                }
            }
        }
        return emptyArrys
    }
    
    // 随机插入的方法
    // 这个方法也很简单,就是取出当前所有的空的位置数组,在随机一个数组中的位置,
    // 之后赋值给gamebord以及调用游戏视图层渲染出新的游戏区块
    func insertRandomPositoinTile(_ value : Int) {
        let emptyArrays = getEmptyPosition()
        if emptyArrays.isEmpty {
            return
        }
        let randomPos = Int(arc4random_uniform(UInt32(emptyArrays.count - 1)))
        let (x , y) = emptyArrays[randomPos]
        gamebord[(x , y)] = TileEnum.tile(value)
        delegate.insertTile((x , y), value: value)
    }
    
    /*
     * -----------算法调用开始-----------
     */
    
    // 提供给主控制器调用,入参为移动方向和一个需要一个是否移动过的Bool值为入参的闭包
    func queenMove(_ direction : MoveDirection , completion : (Bool) -> ()) {
        let changed = performMove(direction)
        completion(changed)
        
    }
    // 移动实现
    func performMove(_ direction : MoveDirection) -> Bool {
        // 根据上下左右返回每列(行)的四个块的坐标
        let getMoveQueen : (Int) -> [(Int , Int)] = { (idx : Int) -> [(Int , Int)] in
            var buffer = Array<(Int , Int)>(repeating: (0, 0) , count: self.dimension)
            for i in 0..<self.dimension {
                switch direction {
                case .up : buffer[i] = (idx, i)
                case .down : buffer[i] = (idx, self.dimension - i - 1)
                case .left : buffer[i] = (i, idx)
                case .right : buffer[i] = (self.dimension - i - 1, idx)
                }
            }
            return buffer
        }
        var movedFlag = false
        // 逐列(行)进行处理
        for i in 0..<self.dimension {
            // 获取当前列(行)的4个坐标
            let moveQueen = getMoveQueen(i)
            // 从gamebord中取出当前4个坐标中的值存为数组
            let tiles = moveQueen.map({ (c : (Int, Int)) -> TileEnum in
                let (source , value) = c
                return self.gamebord[source , value]
            })
            // 调用算法
            let moveOrders = merge(tiles)
            movedFlag = moveOrders.count > 0 ? true : movedFlag
            // 对算法返回结果进行具体处理.1:更新gamebord中的数据,2:更新视图中的数字块
            for order in moveOrders {
                switch order {
                // 单个移动或合并的
                case let .singlemoveorder(s, d, v, m):
                    let (sx, sy) = moveQueen[s]
                    let (dx, dy) = moveQueen[d]
                    if m {
                        self.score += v
                    }
                    // 将原位置置空,新位置设置为新的值
                    gamebord[sx , sy] = TileEnum.empty
                    gamebord[dx , dy] = TileEnum.tile(v)
                    // TODO 调用游戏视图更新视图中的数字块
                    delegate.moveOneTile((sx, sy), to: (dx, dy), value: v)
                // 两个进行合并的
                case let .doublemoveorder(fs , ts , d , v):
                    let (fsx , fsy) = moveQueen[fs]
                    let (tsx , tsy) = moveQueen[ts]
                    let (dx , dy) = moveQueen[d]
                    self.score += v
                    // 将原位置置空，新位置设置为新的值
                    gamebord[fsx , fsy] = TileEnum.empty
                    gamebord[tsx , tsy] = TileEnum.empty
                    gamebord[dx , dy] = TileEnum.tile(v)
                    // TODO 调用游戏视图更新视图中的数字块   
                    delegate.moveTwoTiles((moveQueen[fs], moveQueen[ts]), to: moveQueen[d], value: v)
                    
                }
            }
        }
        return movedFlag
    }
    
    func reset() {
        score = 0
        gamebord.setAll(.empty)
    }
    
    // 如果gamebord中有超过我们定的最大分数threshold的,则用户赢了
    func userHasWon() -> (Bool, (Int, Int)?) {
        for i in 0..<dimension {
            for j in 0..<dimension {
                if case let .tile(v) = gamebord[i, j], v >= threshold {
                    return (true, (i, j))
                }
            }
        }
        return (false, nil)
    }
    
    // 当前gamebord已经满了且两两间的值都不同,则用户输了
    func userHasLost() -> Bool {
        guard getEmptyPosition().isEmpty else {
            return false
        }
        for i in 0..<dimension {
            for j in 0..<dimension {
                switch gamebord[i, j] {
                case .empty:
                    assert(false, "Gameboard reported itself as full, but we still found an empty tile. This is a logic error.")
                case let .tile(v):
                    if tileBelowHasSameValue((i, j), v) || tileToRightHasSameValue((i, j), v) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    func tileBelowHasSameValue(_ location: (Int, Int), _ value: Int) -> Bool {
        let (x, y) = location
        guard y != dimension - 1 else {
            return false
        }
        if case let .tile(v) = gamebord[x, y+1] {
            return v == value
        }
        return false
    }
    
    func tileToRightHasSameValue(_ location: (Int, Int), _ value: Int) -> Bool {
        let (x, y) = location
        guard x != dimension - 1 else {
            return false
        }
        if case let .tile(v) = gamebord[x+1, y] {
            return v == value
        }
        return false
    }
    
    
    /* 
     * -----------具体算法相关开始-----------
     */
    
    func merge(_ group : [TileEnum]) -> [MoveOrder] {
        return convert(collapse(condense(group)))
    }
    
    // 去除空 如:| | |2|2|去掉空为:|2|2| | |
    func condense(_ group : [TileEnum]) -> [TileAction] {
        var buffer = [TileAction]()
        for (index , tile) in group.enumerated(){
            switch tile {
                // 如果buffer的大小和当前group的下标一致,则表示当前数字块不需要移动
                // 如|2| |2| |,第一次时buffer大小和index都是0,不需要移动
                // 下一个2时，buffer大小为1,groupindex为2,则需要移动了
            case let .tile(value) where buffer.count == index :
                buffer.append(TileAction.noaction(source: index, value: value))
            case let .tile(value) :
                buffer.append(TileAction.move(source: index, value: value))
            default:
                break
            }
        }
        return buffer
    }
    
    // 合并相同的    如:|2| | 2|2|合并为:|4|2| | |
    func collapse(_ group : [TileAction]) -> [TileAction] {
        
        var tokenBuffer = [TileAction]()
        // 是否跳过下一个,如果把下一个块合并过来,则下一个数字块应该跳过
        var skipNext = false
        for (idx, token) in group.enumerated() {
            if skipNext {
                skipNext = false
                continue
            }
            switch token {
            // 当前块和下一个块的值相同且当前块不需要移动,那么需要将下一个块合并到当前块来
            case let .noaction(s, v)
                where (idx < group.count-1
                    && v == group[idx+1].getValue()
                    && GameModle.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s)):
                let next = group[idx+1]
                let nv = v + group[idx+1].getValue()
                skipNext = true
                tokenBuffer.append(TileAction.singlecombine(source: next.getSource(), value: nv))
            // 当前块和下一个块的值相同,且两个块都需要移动,则将两个块移动到新的位置
            case let t where (idx < group.count-1 && t.getValue() == group[idx+1].getValue()):
                let next = group[idx+1]
                let nv = t.getValue() + group[idx+1].getValue()
                skipNext = true
                tokenBuffer.append(TileAction.doublecombine(firstSource: t.getSource(), secondSource: next.getSource(), value: nv))
            // 上一步判定不需要移动,但是之前的块有合并过,所以需要移动
            case let .noaction(s, v) where !GameModle.quiescentTileStillQuiescent(idx, outputLength: tokenBuffer.count, originalPosition: s):
                tokenBuffer.append(TileAction.move(source: s, value: v))
            // 上一步判定不需要移动,且之前的块也没有合并,则不需要移动
            case let .noaction(s, v):
                tokenBuffer.append(TileAction.noaction(source: s, value: v))
            // 上一步判定需要移动且不符合上面的条件的,则继续保持移动
            case let .move(s, v):
                tokenBuffer.append(TileAction.move(source: s, value: v))
            default:
                break
            }
        }
        return tokenBuffer
    }
    
    class func quiescentTileStillQuiescent(_ inputPosition: Int, outputLength: Int, originalPosition: Int) -> Bool {
        return (inputPosition == outputLength) && (originalPosition == inputPosition)
    }
    
    // 转换为MOVEORDER便于后续处理
    func convert(_ group : [TileAction]) -> [MoveOrder] {
        var buffer = [MoveOrder]()
        for (idx , tileAction) in group.enumerated() {
            switch tileAction {
            case let .move(s, v) :
                // 单纯的将一个块由s位置移动到idx位置,新值为v
                buffer.append(MoveOrder.singlemoveorder(source: s, destination: idx, value: v, merged: false))
            case let .singlecombine(s, v) :
                // 将一个块由s位置移动到idx位置,且idx位置有数字块,俩数字块进行合并,新值为v
                buffer.append(MoveOrder.singlemoveorder(source: s, destination: idx, value: v, merged: true))
            case let .doublecombine(s, d, v) :
                // 将s和d两个数字块移动到idx位置并进行合并,新值为v
                buffer.append(MoveOrder.doublemoveorder(firstSource: s, secondSource: d, destination: idx, value: v))
            default:
                break
            }
        }
        return buffer
    }
    
    /*
     * -----------具体算法相关结束----------
     */
    
}
