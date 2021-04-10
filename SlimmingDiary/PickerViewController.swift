//
//  PickerViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/18.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

protocol PickerViewDelegate: class {
    func getSelectRow(data: Double)
}

class PickerViewController: UIViewController {
    @IBOutlet var dotLabel: UILabel!
    @IBOutlet var pickerView: UIPickerView!

    weak var delegate: PickerViewDelegate?
    var interger: Double = 1
    var point: Double = 0
    var didSelectRowNumber: Double = 1.0
    var numberOfRows = 1
    var numberOfComponents = 1
    var selectRowOfbegin: Double = 0

    static let shared = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        hideDialog()
    }

    override func viewWillAppear(_: Bool) {
        pickerView.reloadAllComponents()
        dotLabel.isHidden = true

        interger = floor(selectRowOfbegin)
        point = (selectRowOfbegin - interger) * 10
        let s = Float(point)

        pickerView.selectRow(Int(interger - 1), inComponent: 0, animated: true)

        if numberOfComponents == 2 {
            dotLabel.isHidden = false
            pickerView.selectRow(Int(s), inComponent: 1, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func displayDialog(present: UIViewController) {
        present.addChildViewController(self)
        present.view.addSubview(view)
        didMove(toParentViewController: self)
    }

    func hideDialog() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }

    @IBAction func comfirmButton(_: Any) {
        didSelectRowNumber = interger + point
        delegate?.getSelectRow(data: didSelectRowNumber.roundTo(places: 1))
        hideDialog()
    }
}

// MARK: - UIPickerViewDelegate,UIPickerViewDataSource

extension PickerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return numberOfRows
        }
        return 10
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(row + 1)
        }
        return String(row)
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return numberOfComponents
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            interger = Double(row + 1)

        } else {
            point = Double(row) / 10
        }
    }
}
