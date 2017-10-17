//
//  MyTabBarViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/9/9.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class MyTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if !ProfileManager.standard.isInputDone{
            
            DispatchQueue.main.async {
                
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier:"EnterInformation"){
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }

            }
            
            return

        }
        
        checkIsLogIn()
        
    }
    
    
    func checkIsLogIn(){
        
        let manager = DataService.standard
        let profileManager = ProfileManager.standard
        
        
        if manager.isLogin{
            
            if profileManager.userUid == nil{
                manager.userLogOut()
                
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
