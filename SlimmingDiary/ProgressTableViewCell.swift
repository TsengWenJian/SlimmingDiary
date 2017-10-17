//
//  ProgressTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/14.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ProgressTableViewCell: UITableViewCell{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageConrol: UIPageControl!
    
    let weightProgress = NickProgress2UIView()
    let fatProgress = NickProgress2UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = UIScreen.main.bounds.width - 24
        scrollView.delegate = self
        
        
        scrollView.contentSize = CGSize(width:width*2,height:scrollView.frame.height)
        
        let page1View = UIView(frame: CGRect(x:0,y:0,
                                             width:width,
                                             height:frame.height))
        
        
        
        
        let page2View = UIView(frame: CGRect(x:width,
                                             y:0,
                                             width:width,
                                             height:frame.height))
        
        weightProgress.lineWidth = 7
        fatProgress.lineWidth = 7
        
        
        weightProgress.frame.size = CGSize(
            width:width*2/3,
            height:width*1/3)
        
        weightProgress.backgroundColor = UIColor.clear
        fatProgress.backgroundColor = UIColor.clear
        
        
        
        
        fatProgress.frame.size = CGSize(
            width:width*2/3,
            height:width*1/3)
        
        
        let center = CGPoint(x: page1View.center.x, y: page1View.center.y-10)
        weightProgress.center = center
        fatProgress.center = center
        
        
        
        scrollView.addSubview(page1View)
        scrollView.addSubview(page2View)
        page1View.addSubview(weightProgress)
        page2View.addSubview(fatProgress)
        
        let stringOrigin = CGPoint(x:page1View.bounds.maxX-45, y: 10)
        
        let weightImage = UIImageView()
        weightImage.image = UIImage(named: "dumbbell-training")
        weightImage.frame.origin = stringOrigin
        weightImage.frame.size = CGSize(width: 40, height:40)
        
        
       

        let fatImage = UIImageView()
        fatImage.image = UIImage(named: "sumo-fighter")
        fatImage.frame.origin = stringOrigin
        fatImage.frame.size = CGSize(width: 40, height:40)


        page1View.addSubview(weightImage)
        page2View.addSubview(fatImage)

        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    
    
}

extension ProgressTableViewCell:UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPageNumber = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        pageConrol.currentPage = currentPageNumber
        
        
    }
    
    
}

