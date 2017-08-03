//
//  PrepareRecordViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/30.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class PrepareRecordViewController: UIViewController {
    let titleArray = ["名稱","開始日期","天數"]
    var detailArray = ["","",""]{
        didSet{
            prepareTableView.reloadData()
        }
    }
    @IBOutlet weak var prepareTableView: UITableView!
    @IBOutlet weak var titleImage: UIImageView!
    var calendarPickVC:CalendarViewController!
    var pickerVC:PickerViewController!
    var numberOfRows:Int = 7
    var numberOfComponents:Int = 1
    var setSelectRowOfbegin:Double = 1
    var textFieldText:String?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        calendarPickVC = storyboard!.instantiateViewController(withIdentifier: "CalendarViewController") as!
        CalendarViewController
        calendarPickVC.delegate = self
        
        pickerVC = storyboard?.instantiateViewController(withIdentifier:"PickerViewController") as!PickerViewController
        pickerVC.delegate = self
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func addTitleImageAction(_ sender: Any) {
        
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false{
            return
        }
        
        
        let picker = UIImagePickerController()
        picker.sourceType =  .photoLibrary
        picker.mediaTypes = ["public.image"]
        
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
        
        
    }
    
}

extension PrepareRecordViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return 1
        }
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        
        return 0.1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell")
            cell?.textLabel?.text = "下一步"
            
            return cell!
            
        }else{
            
            if indexPath.row == 0{
                
                let textFieldCell = tableView.dequeueReusableCell(withIdentifier: "AddTextFieldTableViewCell") as! AddTextFieldTableViewCell
                
                textFieldCell.titleLabel.text = titleArray[indexPath.row]
                textFieldCell.rightTextField.addTarget(self,action:#selector(setTitleText(sender:)), for:.editingChanged)
                
                
                
                return textFieldCell
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetail")
            cell?.textLabel?.text = titleArray[indexPath.row]
            cell?.detailTextLabel?.text = detailArray[indexPath.row]
            return cell!
        }
        
    }
    
    
    func setTitleText(sender:UITextField){
        
        textFieldText = sender.text
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1{
            
            
            calendarPickVC.displayCalendarPickDialog(self)
            
            
        }else if indexPath.row == 2{
            
            
            pickerVC.displayPickViewDialog(present: self)
            
            
        }else if indexPath.section == 1{
            
            
            
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "TimeLineTableViewController") as! TimeLineTableViewController
            
            nextPage.titleImage = titleImage.image
            nextPage.day = Int(Double(detailArray[2])!)
            
            nextPage.beginDate = detailArray[1]
            nextPage.planTitle = textFieldText
            
            navigationController?.pushViewController(nextPage, animated: true)
        }
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
}

extension PrepareRecordViewController:CalendarPickDelegate{
    
    func getCalenderSelectDate(date:MyDate) {
        
        detailArray[1] = "\(date.year)-\(date.month)-\(date.day)"
        
    }
    
}


extension PrepareRecordViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image = UIImage()
        
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage{
            image = photo
            
        }
        
        
        
           
            let clipImageVC = self.storyboard?.instantiateViewController(withIdentifier:"ClipImageViewController") as? ClipImageViewController
            clipImageVC?.delegate = self
            
            clipImageVC?.image = image
            picker.present(clipImageVC!, animated: true, completion: nil)

    }
    
}
extension PrepareRecordViewController:clipImageVCDelegate{
    func clipImageDone(image: UIImage) {
        titleImage.image = image.resizeImage(maxLength: 1024)
        dismiss(animated: false, completion: nil)
        
    }
}

//MARK: - PickerViewDelegate
extension PrepareRecordViewController:PickerViewDelegate{
    
    func getSelectRow(data:Double){
        
        detailArray[2] = "\(Int(data))"
        
    }
}




