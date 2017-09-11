//
//  TestViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/9/11.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    @IBOutlet weak var testView: NickProgress3UIView!
    @IBOutlet weak var button: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("-----------viewDidLoad---------------")
        button.addTarget(self, action:#selector(progess), for: .touchUpInside)
        
        DispatchQueue.main.async {
            print("----------------- DispatchQueue.main.async---------------")
        }
          testView.setProgress(100)
        // Do any additional setup after loading the view.
    }
    
    func progess(){
        
     
      
        DispatchQueue.global(qos: .userInteractive).async {
             self.testView.setNeedsDisplay()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("-----------viewDidAppear-------------")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
      

        print("-----------viewWillAppear---------------")

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
