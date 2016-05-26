//
//  ViewController.swift
//  swift_WaterfallFlow
//
//  Created by wuwei on 16/5/11.
//  Copyright © 2016年 wuwei. All rights reserved.
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


