//
//  WWCollectionFlowLayout.swift
//  swift_WaterfallFlow
//
//  Created by wuwei on 16/5/12.
//  Copyright © 2016年 wuwei. All rights reserved.
//

import UIKit

class WWCollectionFlowLayout: UICollectionViewFlowLayout {

    var columnCount:Int = 0 // 总列数
    var goodsList = [WWGood]() // 商品数据数组
    private var layoutAttributesArray = [UICollectionViewLayoutAttributes]() //所有item的属性
    
    override func prepareLayout() {
        let contentWidth:CGFloat = (self.collectionView?.bounds.size.width)! - self.sectionInset.left - self.sectionInset.right
        let marginX = self.minimumInteritemSpacing
        let itemWidth = (contentWidth - marginX * 2.0) / CGFloat.init(self.columnCount)
        self.computeAttributesWithItemWidth(CGFloat(itemWidth))
        
    }
    
    /**
     *  根据itemWidth计算布局属性
     */
    func computeAttributesWithItemWidth(itemWidth:CGFloat){
        // 定义一个列高数组 记录每一列的总高度
        var columnHeight = [Int](count: self.columnCount, repeatedValue: Int(self.sectionInset.top))
        // 定义一个记录每一列的总item个数的数组
        var columnItemCount = [Int](count: self.columnCount, repeatedValue: 0)
        var attributesArray = [UICollectionViewLayoutAttributes]()
        
        var index = 0
        for good in self.goodsList {
            
            let indexPath = NSIndexPath.init(forItem: index, inSection: 0)
            let attributes = UICollectionViewLayoutAttributes.init(forCellWithIndexPath: indexPath)
            // 找出最短列号
            let minHeight:Int = columnHeight.sort().first!
            let column = columnHeight.indexOf(minHeight)
            // 数据追加在最短列
            columnItemCount[column!] += 1
            let itemX = (itemWidth + self.minimumInteritemSpacing) * CGFloat(column!) + self.sectionInset.left
            let itemY = minHeight
            // 等比例缩放 计算item的高度
            let itemH = good.h * Int(itemWidth) / good.w
            // 设置frame
            attributes.frame = CGRectMake(itemX, CGFloat(itemY), itemWidth, CGFloat(itemH))
            
            attributesArray.append(attributes)
            // 累加列高
            columnHeight[column!] += itemH + Int(self.minimumLineSpacing)
            index += 1
        }
        
        // 找出最高列列号
        let maxHeight:Int = columnHeight.sort().last!
        let column = columnHeight.indexOf(maxHeight)
        // 根据最高列设置itemSize 使用总高度的平均值
        let itemH = (maxHeight - Int(self.minimumLineSpacing) * columnItemCount[column!]) / columnItemCount[column!]
        self.itemSize = CGSizeMake(itemWidth, CGFloat(itemH))
        // 添加页脚属性
        let footerIndexPath:NSIndexPath = NSIndexPath.init(forItem: 0, inSection: 0)
        let footerAttr:UICollectionViewLayoutAttributes = UICollectionViewLayoutAttributes.init(forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withIndexPath: footerIndexPath)
        footerAttr.frame = CGRectMake(0, CGFloat(maxHeight), self.collectionView!.bounds.size.width, 50)
        attributesArray.append(footerAttr)
        // 给属性数组设置数值
        self.layoutAttributesArray = attributesArray
      
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return self.layoutAttributesArray
    }
}
