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
    var detailArray = ["","",""]
    
    @IBOutlet weak var prepareTableView: UITableView!
    @IBOutlet weak var titleImage: UIImageView!
    
    
    var numberOfRows:Int = 7
    var numberOfComponents:Int = 1
    var setSelectRowOfbegin:Double = 1
    var textFieldText:String?
    var checkIsSelectImage:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func checkIsWriteDone()->String?{
        
        
        if !checkIsSelectImage{
            return  "請選擇封面圖片"
            
        }else{
            
            for (index,text) in detailArray.enumerated(){
                if text == ""{
                    
                    return   "請填寫\(titleArray[index])"
                    
                }
            }
            
        }
        return nil
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
//MARK: - UITableViewDelegate,UITableViewDataSource
extension PrepareRecordViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 1 ? 1:titleArray.count
        
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
            
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetail", for: indexPath)
            cell.textLabel?.text = titleArray[indexPath.row]
        
                cell.detailTextLabel?.text = detailArray[indexPath.row]

            
            return cell
        }
        
    }
    
    
    func setTitleText(sender:UITextField){
        
        textFieldText = sender.text
        
        if let textString = textFieldText{
            
            detailArray[0] = textString
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        
        
        
        if indexPath.row == 1{
            
            launchCalanderPickerVC(self)
            
            
        }else if indexPath.row == 2{
            
            
            launchPickerVC(parVC: self)
            
            
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let err = checkIsWriteDone(){
            
            let alert = UIAlertController(error: err)
            present(alert, animated: true, completion: nil)
            
            
        }else{
            
           
            let nextPage = segue.destination as! MakeShareDiaryTableViewController
                    
            let back = UIBarButtonItem(title:"Back",style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem = back
            nextPage.actionType = .insert
            nextPage.titleImage = titleImage.image
            nextPage.day = Int(detailArray[2])
            nextPage.beginDate = detailArray[1]
            nextPage.diaryTitle = textFieldText
            
        }
        
    }
    
}




//MARK: - CalendarPickDelegate
extension PrepareRecordViewController:CalendarPickDelegate{
    
    func getCalenderSelectDate(date:MyDate) {
        
        detailArray[1] = "\(date.year)-\(date.month)-\(date.day)"
        prepareTableView.reloadData()
        
    }
    
}



//MARK: - UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension PrepareRecordViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image = UIImage()
        
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage{
            image = photo
            
        }
        
        let clipImageVC = self.storyboard?.instantiateViewController(withIdentifier:"ClipImageViewController") as? ClipImageViewController
        clipImageVC?.delegate = self
        
        clipImageVC?.selectImage = image
        picker.present(clipImageVC!, animated: true, completion: nil)
        
    }
    
}
extension PrepareRecordViewController:clipImageVCDelegate{
    
    func clipImageDone(image: UIImage) {
        titleImage.image = image.resizeImage(maxLength:1024)
        checkIsSelectImage = true
        dismiss(animated: false, completion: nil)
        
    }
}

//MARK: - PickerViewDelegate
extension PrepareRecordViewController:PickerViewDelegate{
    
    func getSelectRow(data:Double){
        
        detailArray[2] = "\(Int(data))"
        prepareTableView.reloadData()
        
    }
}




