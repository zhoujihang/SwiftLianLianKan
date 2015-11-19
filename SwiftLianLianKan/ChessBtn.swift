//
//  ChessBtn.swift
//  SwiftLianLianKan
//
//  Created by 周际航 on 15/10/30.
//  Copyright © 2015年 zjh. All rights reserved.
//

import UIKit

class ChessBtn: UIButton {

    var _chessModel: ChessModel?
    
    // 自定义构造函数
    init(model:ChessModel){
        super.init(frame: CGRectZero)
        _chessModel = model.copy() as? ChessModel
        self.setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // 初始化视图
    func setUpViews(){
        self.adjustsImageWhenHighlighted = false
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 8
        
        if _chessModel == nil {return}
        
        let model = _chessModel!
        // 设置图片
        if let icon = model.icon {
            let img = UIImage(named: icon);
            self.setImage(img, forState: UIControlState.Normal)
        }
    }
    
    

}
