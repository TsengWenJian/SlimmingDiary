//
//  DatePickerViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/15.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

protocol DatePickerDelegate {
    func getSelectDate(date:Date)
}

class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
     var delegate:DatePickerDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayPickViewDialog(present:UIViewController){
        present.addChildViewController(self)
        present.view.addSubview(self.view)
        didMove(toParentViewController: self)
    }
    
    func hideDialog(){
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
    }

    
    @IBAction func confirmBtnAction(_ sender: UIButton) {
        
        delegate.getSelectDate(date:datePicker.date)
        hideDialog()
    }
    
    
    
    @IBAction func datePickerAction(_ sender: Any) {
        
        
        
        
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
