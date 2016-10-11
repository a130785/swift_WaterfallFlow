//
//  WWGood.swift
//  swift_WaterfallFlow
//
//  Created by wuwei on 16/5/11.
//  Copyright © 2016年 wuwei. All rights reserved.
//

import Foundation

class WWGood: NSObject {

    var w:Int = 0
    var h:Int = 0
    var price:String?
    var img:String?
    
    //字典转模型
    static func goodWithDict(_ dic:NSDictionary ) -> WWGood {
        let good =  WWGood.init()
        good.setValuesForKeys(dic as! [String : AnyObject])
        return good
    }
    
    // 根据索引返回商品数组
    static func goodsWithIndex(_ index:Int8) -> NSArray {
        let fileName = "\(index % 3 + 1).plist"
        let path = Bundle.main.path(forResource: fileName, ofType: nil)
        let goodsAry = NSArray.init(contentsOfFile: path!)
        let goodsArray = goodsAry?.map{self.goodWithDict($0 as! NSDictionary)}
        return goodsArray! as NSArray
    }
    
}
