//
//  ChessModel.swift
//  SwiftLianLianKan
//
//  Created by 周际航 on 15/10/30.
//  Copyright © 2015年 zjh. All rights reserved.
//

import Foundation

class ChessModel: NSObject, NSCopying {
    
    var icon:String?
    var title:String?
    var message:String?
    
    // 纪录当前棋子的位置
    var index_row:Int?      // 第几行
    var index_column:Int?   // 第几列
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let newModel = ChessModel()
        newModel.icon = self.icon
        newModel.title = self.title
        newModel.message = self.message
        newModel.index_row = self.index_row
        newModel.index_column = self.index_column
        return newModel
    }
    
}
