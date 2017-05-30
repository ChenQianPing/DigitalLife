//
//  BaseModle.swift
//  DigitalLife
//
//  Created by ChenQianPing on 16/7/10.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

import Foundation

// 数组中存放的枚举,要么空要么一个带值的Tile
enum TileEnum {
    case empty
    case tile(Int)
}

// 用户操作--上下左右
enum MoveDirection {
    case up,down,left,right
}

// 用于存放数字块的移动状态,是否需要移动以及两个一块合并并移动等,关键数据是数组中位置以及最新的数字块的值
enum TileAction {
    case noaction(source : Int , value : Int)
    case move(source : Int , value : Int)
    case singlecombine(source : Int , value : Int)
    case doublecombine(firstSource : Int , secondSource : Int , value : Int)
    
    func getValue() -> Int {
        switch self {
        case let .noaction(_, value) : return value
        case let .move(_, value) : return value
        case let .singlecombine(_, value) : return value
        case let .doublecombine(_, _, value) : return value
        }
    }
    
    func getSource() -> Int {
        switch self {
        case let .noaction(source , _) : return source
        case let .move(source , _) : return source
        case let .singlecombine(source , _) : return source
        case let .doublecombine(source , _ , _) : return source
        }
    }
}

// 最终的移动数据封装,标注了所有需移动的块的原位置及新位置,以及块的最新值
enum MoveOrder {
    case singlemoveorder(source : Int , destination : Int , value : Int , merged : Bool)
    case doublemoveorder(firstSource : Int , secondSource : Int , destination : Int , value : Int)
}

struct SequenceGamebord<T> {
    var demision : Int
    // 存放实际值的数组
    var tileArray : [T]
    
    init(demision d : Int , initValue : T ) {
        self.demision = d
        tileArray = [T](repeating: initValue , count: d*d)
    }
    
    // 通过当前的x,y坐标来计算存储和取出的位置
    subscript(row : Int , col : Int) -> T {
        get {
            assert(row >= 0 && row < demision && col >= 0 && col < demision)
            return tileArray[demision*row + col]
        }
        set {
            assert(row >= 0 && row < demision && col >= 0 && col < demision)
            tileArray[demision*row + col] = newValue
        }
    }
    
    // 初始化时使用
    mutating func setAll(_ value : T){
        for i in 0..<demision {
            for j in 0..<demision {
                self[i , j] = value
            }
        }
    }
}


/* 
 * 上段代码涉及到两个关键字,其中subscript就是给结构体定义下标访问方式,mutating是结构体在修改自身属性时必须要加的.
 */
