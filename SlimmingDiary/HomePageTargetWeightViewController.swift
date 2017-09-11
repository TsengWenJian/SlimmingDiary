
//
//  HomePageTargetWeightViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/12.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class HomePageTargetWeightViewController: UIViewController {
    
    let manager = ProfileManager.standard
    
    @IBOutlet weak var targetProgress: NickProgress3UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
          
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        
        
        
        let denominator =  fabs(manager.userWeight - manager.userTargetWeight)
        let molecular = fabs(manager.userOriginWeight - manager.userTargetWeight)
        var progress = (1-denominator/molecular)*100
        
        
        //  NaN 0.0/0.0
        if progress.isNaN {
            progress = 0
        }
        
        
        
      
        let  denominatorString = String(format:"%.1f", denominator)
        
        
        DispatchQueue.main.async {
            if progress >= 100{
                
                self.targetProgress.setTitleText(text:"恭喜")
                self.targetProgress.setSubTitleText(text: "達成目標")
                self.targetProgress.setDetailText(text: "")
                
                
            }else{
                self.targetProgress.setTitleText(text:"距離目標")
                self.targetProgress.setSubTitleText(text:denominatorString)
                self.targetProgress.setDetailText(text: "kg")
                
            }
            
            
            
            // if progress is not change don't again anim
            if progress != self.targetProgress.getProgress(){
                self.targetProgress.resetProgress(progress)
            }

        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
