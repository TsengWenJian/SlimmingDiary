//
//  ShowDiaryImageViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/7.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ShowDiaryImageViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var diaryItems = [DiaryItem]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        scrollView.contentSize = CGSize(width:CGFloat(diaryItems.count) * view.frame.width,
                                        height:scrollView.frame.height-44)
        
        
        
        for (index,item) in diaryItems.enumerated(){
            
            let imageView = UIImageView(frame:CGRect(x:view.frame.width * CGFloat(index),
                                                     y:0,
                                                     width: view.frame.width,
                                                     height:scrollView.frame.height))
            
            
            
            imageView.backgroundColor = UIColor.black
            imageView.contentMode = .scaleAspectFit
            
            
            if let url = item.imageURL{
                  imageView.loadImageCacheWithURL(urlString:url)
            }

            scrollView.addSubview(imageView)
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: imageView.frame.width, height:50))
            label.text = "\(item.title) \(item.detail) 大卡"
            label.textColor = UIColor.white
            label.textAlignment = .center
            imageView.addSubview(label)
            
       }

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
}
    

}

