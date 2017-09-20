//
//  HomePageTodayStepViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/9/10.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import CoreMotion

class HomePageTodayStepViewController: UIViewController {
    @IBOutlet weak var todayStepView: NickProgress3UIView!
    let pedometer = CMPedometer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPedometerUpdate()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPedometerUpdate(){
        
        if CMPedometer.isStepCountingAvailable(){
            
            let calender = Calendar.current
            var dateComp = calender.dateComponents([.year,.month,.day], from:Date())
            dateComp.hour = 0
            dateComp.minute = 0
            dateComp.second = 0
            
            
            
            
            let midnightOfToday = calender.date(from:dateComp)
            
            
            
            self.pedometer.queryPedometerData(from: midnightOfToday!, to: Date(), withHandler: { (data, error2) in
                
                if let numberOfSteps = data?.numberOfSteps {
                    
                    
                    
                    
                    let target:Double = ProfileManager.standard.targetStep
                    let step = numberOfSteps.doubleValue
                    var progress = (step/target)*100
                    
                    //  NaN 0.0/0.0
                    if progress.isNaN {
                        progress = 0
                    }
                    
                    DispatchQueue.main.async {
                        
                        if progress >= 100{
                            
                            progress = 100
                            self.todayStepView.setTitleText(text:"達成目標")
                            self.todayStepView.setSubTitleText(text:"\(Int(step))")
                            
                        }else{
                            
                            self.todayStepView.setTitleText(text:"已走")
                            self.todayStepView.setSubTitleText(text:"\(Int(step))")
                            
                            
                        }
                        
                        
                        self.todayStepView.setDetailText(text: "步")
                        
                        // if progress is not change don't again anim
                        
                        
                        if progress != self.todayStepView.getProgress(){
                            self.todayStepView.resetProgress(progress)
                        }
                        
                    }
                    
                    
                    
                }
                
                
            })
            
        }else{
            
            DispatchQueue.main.async {
                
                self.todayStepView.setTitleText(text:"裝置")
                self.todayStepView.setSubTitleText(text:"不支援")

            }
          

            
        }
        
        
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
