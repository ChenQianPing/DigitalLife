//
//  ReadMe.swift
//  DigitalLife
//
//  Created by ChenQianPing on 16/7/8.
//  Copyright © 2016年 ChenQianPing. All rights reserved.
//

/* 
 * 《2048》是比较流行的一款数字游戏.
 * 原版2048首先在github上发布,原作者是Gabriele Cirulli.它是基于《1024》和《小3传奇》的玩法开发而成的新型数字游戏.
 * 2048,一个最近风靡全球的游戏。
 * 2048,一个令玩家爱不释手的游戏。
 * 2048,规则大家应该都知道了，这里在赘述一面：
 * 在玩法规则也非常的简单，一开始方格内会出现2或者4等这两个小数字，玩家只需要上下左右其中一个方向来移动出现的数字，所有的数字就会向滑动的方向靠拢，而滑出的空白方块就会随机出现一个数字，相同的数字相撞时会叠加靠拢，然后一直这样，不断的叠加最终拼凑出2048这个数字就算成功。
 
 
 * 参考文献:
 * https://github.com/scarlettbai/2048.git
 * https://github.com/austinzheng/swift-2048

 * 1.手把手教你编写2048(一)
 * http://blog.csdn.net/silk_bar/article/details/51108348
 * http://blog.scarlettbai.com/swift-2048-1-t1460210839/
 
 * 2.手把手教你编写2048(二)
 * http://blog.csdn.net/silk_bar/article/details/51116235
 * http://blog.scarlettbai.com/swift-2048-2-t1460210839/
 
 * 3.手把手教你编写2048(三)
 * http://blog.csdn.net/silk_bar/article/details/51235968
 * http://blog.scarlettbai.com/swift-2048-3-t1461499308/
 
 * 开源项目Swift-2048学习、分析
 * http://www.jianshu.com/p/52a774403a7d
 
 * 鹅厂程序猿:使用Swift+SpriteKit编写2048
 * http://djt.qq.com/article/view/1194
 
 * SpriteKit做的《2048》
 * http://code.cocoachina.com/view/125236
 * 使用iOS 7的SpriteKit做的《2048》游戏。
 * 虽然该游戏是经典的《2048》的衍生品,但也不完全相同.
 * 比如游戏提供了三种棋盘结构（3x3, 4x4以及5x5）,跟可活动的空间密切相关.该游戏还有有三种游戏模式以及其他UI主题.
 
 * 2048游戏详解(JS版)
 * http://www.cnblogs.com/chengguanhui/p/4693518.html
 
 * Swift实战之2048小游戏
 * http://www.cnblogs.com/tt2015-sz/p/4843858.html
 
 * 2048 长官版
 * http://www.cnblogs.com/afrog/p/3918064.html
 
 
 * 项目结构:
 * 1.GameModle.swift
 * 全工程最庞大的一个文件,在models文件夹下,这个文件主要是算法的实现(移动合并算法),
 * 虽然说是model文件后缀,但是本人实在想不到这个文件和MVC中的model有什么关系.
 
 * 2.BaseModle.swift
 * 里面定义着本项目用到的所有的,用户自定义的结构体与枚举
 
 * 3.ScoreView.swift
 * 本文件里面定义着代表分数的view
 
 * 4.GamebordView.swift
 * 和文件名称一样,这个文件是游戏的主要面板也就是下面这个
 
 * 5.TileView.swift
 * 文件名也出卖了它,这个让用户看起来就是2048游戏中的那些可以移动的数字.
 
 * 6.NumbertailGameController.swift
 * 游戏的主要控制器,几乎所有的逻辑均在这里处理
 
 * 7.ApperanceProvider.swift
 * 项目辅助功能,它决定着游戏中数字以及TileView的颜色

 */
