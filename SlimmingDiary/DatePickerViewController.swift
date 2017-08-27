//
//  DatePickerViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/15.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

func launchDatePickerVC(parVC:UIViewController){
    let man = UIStoryboard(name: "Main", bundle: nil)
    let picker = man.instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
    picker.delegate = parVC as? DatePickerDelegate
    picker.displayPickViewDialog(present: parVC)
}

protocol DatePickerDelegate {
    func getSelectDate(date:Date)
}

class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
     var delegate:DatePickerDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hideDialog()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate = nil
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
    
}
