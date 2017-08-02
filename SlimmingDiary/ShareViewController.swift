//
//  ShareViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/1.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {
    
    @IBOutlet weak var roundScrollView: UIScrollView!
    @IBOutlet weak var roundView: UIView!
    let selectLabel = UILabel()
    var pageVC:UIPageViewController?
    var recordsVC:ShowRecordsTableViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundView.layer.cornerRadius = 15
        let scolBounds = roundScrollView.bounds
        roundScrollView.contentSize = roundScrollView.bounds.size
        
        
        roundScrollView.contentInset = UIEdgeInsets(top:0,
                                                    left:scolBounds.width/2,
                                                    bottom:0,
                                                    right:0)
        
        selectLabel.text = "全部"
        selectLabel.textAlignment = .center
        selectLabel.frame.size = CGSize(width:scolBounds.width/2,
                                        height:scolBounds.height)
        
        selectLabel.textColor = seagreen
        selectLabel.frame.origin = CGPoint(x:0,y:0)
        selectLabel.layer.cornerRadius = 13
        selectLabel.clipsToBounds = true
        selectLabel.backgroundColor = UIColor.white
        
        roundScrollView.addSubview(selectLabel)
        roundScrollView.delegate = self
        
        if let VC  = self.childViewControllers[0] as? UIPageViewController{
            
            pageVC = VC
//            pageVC?.delegate = self
            
        }
        recordsVC = storyboard?.instantiateViewController(withIdentifier: "ShowRecordsTableViewController") as? ShowRecordsTableViewController
        
        pageVC?.setViewControllers([recordsVC!], direction: .forward, animated: true, completion: nil)
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func scrollViewTapAction(_ sender: UIGestureRecognizer) {
        
        let tapWithX =  sender.location(in:roundScrollView).x
        let x = tapWithX >= roundScrollView.bounds.midX ? -roundScrollView.frame.width/2:0
        roundScrollView.setContentOffset(CGPoint(x:x,y:0),animated:true)
        
        
    }
    
}

extension ShareViewController:UIScrollViewDelegate{
    
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let distance = -scrollView.contentOffset.x
        var x:CGFloat
        
        x = distance >= roundScrollView.frame.width/4 ? -roundScrollView.frame.width/2:0
        
        if !decelerate{
            roundScrollView.setContentOffset(CGPoint(x:x,y: 0), animated: true)
        }
    }
    
}


//extension ShareViewController:UIPageViewControllerDelegate,UIPageViewControllerDataSource{

//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        
//    }
//    
//    
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        
//    }
//    
//    
//    
    
    
    
    
//}
