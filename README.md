# swift_WaterfallFlow
swift+CollectionView 瀑布流
记得在学习OC的时候，看到过一个CollectionView实现的瀑布流的项目，从网络加载图片，用SDWebImage做缓存。效果如下：
![WuWeiCollectionView.gif](http://upload-images.jianshu.io/upload_images/1968278-cce7a9a3f0434df9.gif?imageMogr2/auto-orient/strip)

耐不住寂寞，于是花了一个2个晚上用Swift写了一遍。用[SDWebImage](https://github.com/rs/SDWebImage)做缓存，You can Installation with CocoaPods or  Carthage (iOS 8+)，你也可以像我一样直接把SDWebImage源码拷贝到项目中。项目中我是[在同个工程中使用 Swift 和 Objective-C](https://github.com/CocoaChina-editors/Welcome-to-Swift/blob/master/Using%20Swift%20with%20Cocoa%20and%20Objective-C/03Mix%20and%20Match/Swift%20and%20Objective-C%20in%20the%20Same%20Project.md)，图片属性保存在plist中，目录结构如下：

![B5F15132-C66B-4F7C-9AE5-8D8CE11FF502.png](http://upload-images.jianshu.io/upload_images/1968278-b4dc5a3262117c56.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

最关键的是UICollectionViewFlowLayout的设置：
```
//
//  WWCollectionFlowLayout.swift
//  swift_WaterfallFlow
//
//  Created by wuwei on 16/5/12.
//  Copyright © 2016年 wuwei. All rights reserved.
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
     *  根据itemWidth计算布局属性
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
```
模型类WWGood：
```
import Foundation

class WWGood: NSObject {

    var w:Int = 0
    var h:Int = 0
    var price:String?
    var img:String?
    
    //字典转模型
    static func goodWithDict(dic:NSDictionary ) -> WWGood {
        let good =  WWGood.init()
        good.setValuesForKeysWithDictionary(dic as! [String : AnyObject])
        return good
    }
    
    // 根据索引返回商品数组
    static func goodsWithIndex(index:Int8) -> NSArray {
        let fileName = "\(index % 3 + 1).plist"
        let path = NSBundle.mainBundle().pathForResource(fileName, ofType: nil)
        let goodsAry = NSArray.init(contentsOfFile: path!)
        let goodsArray = goodsAry?.map{self.goodWithDict($0 as! NSDictionary)}
        return goodsArray!
    }
    
}
```
UICollectionViewController
```
//
//  ViewController.swift
//  swift_WaterfallFlow
//
//  Created by wuwei on 16/5/11.
//  Copyright © 2016年 wuwei. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController {

    // 商品列表数组
    var goodsList = [WWGood]()
    // 当前的数据索引
    var index:Int8 = 0
    // 底部视图
    var footerView:WWCollectionFooterView?
    // 是否正在加载数据标记
    var loading = false
    // 瀑布流布局
    @IBOutlet weak var flowLayout: WWCollectionFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.loadData()
    }
    
    func loadData() {
        let goods = WWGood.goodsWithIndex(self.index)
        self.goodsList.appendContentsOf(goods as! [WWGood])
        self.index += 1
        // 设置布局的属性
        self.flowLayout.columnCount = 3
        self.flowLayout.goodsList = self.goodsList
        self.collectionView?.reloadData()
    }
    
//MARK:- UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.goodsList.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GoodCellCache", forIndexPath: indexPath) as! WWGoodCell

        cell.setGoodData(self.goodsList[indexPath.item])
        return cell;
    }
    
//MARK:-FooterView
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            self.footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "FooterViewCache", forIndexPath: indexPath) as? WWCollectionFooterView
        }
        return self.footerView!
    }

//MARK:-scrollView代理方法
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.footerView == nil || self.loading == true {
            return
        }
        
        if self.footerView!.frame.origin.y < (scrollView.contentOffset.y + scrollView.bounds.size.height) {
            NSLog("开始刷新"); 
            self.loading = true
            self.footerView?.indicator.startAnimating()
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                self.footerView = nil
                self.loadData()
                self.loading = false
            })
        }
        
    }
   
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
```

源码下载地址：[wu大维的Github](https://github.com/a130785/swift_WaterfallFlow) 如果你要在真机上直接运行我的代码，请修改bundle identifier并使用你的证书。

参考资料：
[Swift中文版](http://wiki.jikexueyuan.com/project/swift/chapter2/01_The_Basics.html)
[Using Swift with Cocoa and Objective-C](https://github.com/CocoaChina-editors/Welcome-to-Swift/blob/master/UsingSwiftwithCocoaandObjective-C%E4%B8%AD%E6%96%87%E6%89%8B%E5%86%8C.md)
