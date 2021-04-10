//
//  DatePickerViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/15.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

protocol DatePickerDelegate: class {
    func getSelectDate(date: Date)
}

class DatePickerViewController: UIViewController {
    @IBOutlet var datePicker: UIDatePicker!
    weak var delegate: DatePickerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        hideDialog()
    }

    func displayPickViewDialog(present: UIViewController) {
        present.addChildViewController(self)
        present.view.addSubview(view)
        didMove(toParentViewController: self)
    }

    func hideDialog() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }

    @IBAction func confirmBtnAction(_: UIButton) {
        delegate.getSelectDate(date: datePicker.date)
        hideDialog()
    }
}
