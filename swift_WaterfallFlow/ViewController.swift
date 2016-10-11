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
        self.collectionView?.backgroundColor = UIColor.white
        self.loadData()
    }
    
    func loadData() {
        let goods = WWGood.goodsWithIndex(self.index)
        self.goodsList.append(contentsOf: goods as! [WWGood])
        self.index += 1
        // 设置布局的属性
        self.flowLayout.columnCount = 3
        self.flowLayout.goodsList = self.goodsList
        self.collectionView?.reloadData()
    }
    
//MARK:- UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.goodsList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoodCellCache", for: indexPath) as! WWGoodCell

        cell.setGoodData(self.goodsList[(indexPath as NSIndexPath).item])
        return cell;
    }
    
//MARK:-FooterView
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionFooter {
            self.footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FooterViewCache", for: indexPath) as? WWCollectionFooterView
        }
        return self.footerView!
    }

//MARK:-scrollView代理方法
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.footerView == nil || self.loading == true {
            return
        }
        
        if self.footerView!.frame.origin.y < (scrollView.contentOffset.y + scrollView.bounds.size.height) {
            NSLog("开始刷新"); 
            self.loading = true
            self.footerView?.indicator.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                self.footerView = nil
                self.loadData()
                self.loading = false
            })
        }
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}


