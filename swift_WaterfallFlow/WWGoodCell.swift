//
//  WWGoodCell.swift
//  swift_WaterfallFlow
//
//  Created by wuwei on 16/5/11.
//  Copyright © 2016年 wuwei. All rights reserved.
//

import UIKit

class WWGoodCell: UICollectionViewCell {

    @IBOutlet weak var priceView: UILabel!
    @IBOutlet weak var imageview: UIImageView!

    var good:WWGood?
    
    func setGoodData(good:WWGood) {
        self.good = good
        let url = NSURL.init(string: good.img!)
        self.imageview.sd_setImageWithURL(url)
        self.priceView.text = good.price
    }
    
}
