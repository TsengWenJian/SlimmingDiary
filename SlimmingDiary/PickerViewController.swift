//
//  PickerViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/18.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

protocol PickerViewDelegate {
    
    var numberOfRows:Int{
        get set
    }
    
    var numberOfComponents:Int{
        get set
    }
    
    var setSelectRowOfbegin:Double{
        get set
    }
    
    func getSelectRow(data:Double)
    
    
    
}

class PickerViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    @IBOutlet weak var dotLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    var delegate:PickerViewDelegate?
    var interger:Double = 1
    var point:Double = 0
    var didSelectRowNumber:Double = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        pickerView.reloadAllComponents()
        dotLabel.isHidden = true
        
        guard let de = delegate else{
            return
        }
        
        interger = floor(de.setSelectRowOfbegin)
        point = (de.setSelectRowOfbegin - interger)*10
        let s  = Float(point)
        
        
        
        pickerView.selectRow(Int(interger-1), inComponent: 0, animated: true)
        
        
        if delegate?.numberOfComponents == 2{
            dotLabel.isHidden = false
            pickerView.selectRow(Int(s), inComponent: 1, animated: true)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
    
    @IBAction func comfirmButton(_ sender: Any) {
        
        didSelectRowNumber = interger+point
        delegate?.getSelectRow(data:didSelectRowNumber.roundTo(places: 1))
        hideDialog()
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        if  component == 0{
            return delegate!.numberOfRows
            
        }
        return 10
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0{
            
            
            return String(row+1)
            
        }
        return String(row)
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return  delegate!.numberOfComponents
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        if component == 0{
            interger = Double(row+1)
            
        }else{
            point = Double(row)/10
            
        }
        
    }

}
