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
    @IBOutlet weak var addDiaryBtn: UIButton!
    let selectLabel = UILabel()
    var recordsVC:ShowDiarysTableViewController?
    
    var currnetPage = 0{
        didSet{
            
            if currnetPage == 0{
                selectLabel.text = "全部"
                recordsVC?.currentPage = 0
                
            }else{
                selectLabel.text = "個人"
                recordsVC?.currentPage = 1
            
            }
            loginStatusIsChange()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        setNavRoundScrollView()
        
        if let VC  = self.childViewControllers[0] as? ShowDiarysTableViewController{
            
            recordsVC = VC
        }
        
        
        
        loginStatusIsChange()
        NotificationCenter.default.addObserver(self,selector:#selector(loginStatusIsChange),
                                               name: NSNotification.Name(rawValue:"loginStatus"),
                                               object: nil)
  
     
        
        
        
    }
    
    func setNavRoundScrollView(){
        
        roundView.layer.cornerRadius = 15
        let scolBounds = roundScrollView.bounds
        roundScrollView.contentSize = roundScrollView.bounds.size
        
        
        let itemWidth = scolBounds.width/2
        roundScrollView.contentInset = UIEdgeInsets(top:0,
                                                    left:itemWidth,
                                                    bottom:0,
                                                    right:0)
        
        selectLabel.text = "全部"
        selectLabel.textAlignment = .center
        selectLabel.frame.size = CGSize(width:itemWidth,
                                        height:scolBounds.height)
        
        selectLabel.textColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
        selectLabel.frame.origin = CGPoint(x:0,y:0)
        selectLabel.layer.cornerRadius = 13
        selectLabel.clipsToBounds = true
        selectLabel.backgroundColor = UIColor.white
        
        roundScrollView.addSubview(selectLabel)
        roundScrollView.delegate = self

        
    }
    
    @objc func loginStatusIsChange(){
        
        
        if currnetPage == 1{
            
            
            addDiaryBtn.isHidden = !DataService.standard.isLogin
            
        }else{
            addDiaryBtn.isHidden = true
        }
        
        
        
        
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


// MARK: - UIScrollViewDelegate
extension ShareViewController:UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        if scrollView.contentOffset.x == 0.0{

            currnetPage = 0
            
        }else if scrollView.contentOffset.x == -scrollView.frame.width/2{
            
            currnetPage = 1
            
        }
    }

    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let distance = -scrollView.contentOffset.x
        var x:CGFloat
        
        x = distance >= roundScrollView.frame.width/4 ? -roundScrollView.frame.width/2:0
        
        if !decelerate{
            roundScrollView.setContentOffset(CGPoint(x:x,y: 0), animated: true)
        }
    }
    
}


