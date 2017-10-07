//
//  AddWeightViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/17.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class AddWeightViewController: UIViewController{
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addPhotoTableView: UITableView!
    
    var type = WeightDiaryType.weight
    
    
    var detailArray = ["體重","加入"]{
        didSet{
            addPhotoTableView.reloadData()
        }
    }
    
    
    var titleArray = ["體重","進展照片"]
    var selectImage:UIImage?
    var weight:Double = 0
    var actionType:ActionType = .insert
    var weightId:Int?
    
    
    let proFileManager = ProfileManager.standard
    let weightMaster = WeightMaster.standard
    
    
    var numberOfRows:Int = 200
    var numberOfComponents:Int = 2
    var setSelectRowOfbegin:Double = 1.0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleArray[0] = type.rawValue
        detailArray[0] = "\(weight)"
         PickerViewController.shared.delegate = self
        
    }
    
   
    
    
    //MARK:- Function
    @objc func cancelAction(sender:UIButton){
        dismiss(animated: true, completion: nil)
    }
    

    @objc func confirmAction(sender:UIButton){
        
        var imageName:String?
        
        if let myImage = selectImage{
            
            
            let hashString = "WeightProgress_\(myImage.hash)"
            myImage.writeToFile(imageName: hashString, search: .documentDirectory)
            imageName = hashString
            
        }
        
        
        weightMaster.diaryType = .weightDiary
        
        if actionType == .update {
            
            
            if let id = weightId {
                let cond = "\(WEIGHTDIARY_ID) = '\(id)'"
                
                weightMaster.updataDiary(cond:cond,
                                         rowInfo:[WEIGHTDIARY_PHOTO:"'\(imageName ?? "No_Image")'",
                                                  WEIGHTDIARY_VALUE:"'\(weight)'"])
            }
            
            
            
        }else{
            
            let calender = CalenderManager.standard
            
            if calender.displayDateString() == calender.currentDateString() || calender.isAfterCurrentDay(date:calender.displayDate){
                
                if titleArray[0] == "體重"{
                proFileManager.setUserWeight(weight)
                }
                
            }
            
            let diary = WeightDiary(id:nil,
                                    date:calender.displayDateString(),
                                    time:calender.getCurrentTime(),
                                    type:titleArray[0],
                                    value:weight,
                                    imageName:imageName)
            
            weightMaster.insertWeightDiary(diary)
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }

    
    func launchImagePickerWithSourceType(type:UIImagePickerControllerSourceType){
        
        
        if UIImagePickerController.isSourceTypeAvailable(type) == false{
            return
            
        }
        
        let picker = UIImagePickerController()
        picker.sourceType =  type
        picker.delegate = self
        
        if type == .camera{
            picker.mediaTypes = ["public.image"]
            
        }else{
            picker.allowsEditing = true;
            
        }
        present(picker, animated: true, completion: nil)
        
    }
    
    
    
}


//MARK: -UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension AddWeightViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
       
        
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectImage = photo
            
        }
        if let myImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectImage = myImage
        }
        selectImage = selectImage?.resizeImage(maxLength: 1024)
        photoImageView.image = selectImage
        dismiss(animated: true, completion: nil)
        
    }
    
}


//MARK: -UITableViewDelegate,UITableViewDataSource
extension AddWeightViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "AddWeightHeaderTableViewCell") as! AddWeightHeaderTableViewCell
        
        var title:String
        title = actionType == .insert ? "新增紀錄":"修改記錄"
        headerCell.TitleLabel.text = title
        headerCell.cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        headerCell.confirmBtn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        
        return headerCell.contentView
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return detailArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0{
            
            if let detail = Double(detailArray[0]){
                
                setSelectRowOfbegin = detail
            }
            
             PickerViewController.shared.displayDialog(present: self) 
            
        }
        
        
        if indexPath.row == 1{
            let alertVC = UIAlertController(title:"選擇照片", message:"", preferredStyle:.actionSheet)
            
            let camera = UIAlertAction(title: "拍照", style: .default, handler: { (UIAlertAction) in
                self.launchImagePickerWithSourceType(type:.camera)
            })
            
            
            let library = UIAlertAction(title: "相簿", style: .default, handler: { (UIAlertAction) in
                self.launchImagePickerWithSourceType(type:.photoLibrary)
            })
            
            
            let cancel = UIAlertAction(title: "取消", style:.cancel, handler:nil)
            
            
            alertVC.addAction(camera)
            alertVC.addAction(library)
            alertVC.addAction(cancel)
            present(alertVC, animated: true, completion: nil)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
        cell.textLabel?.text = titleArray[indexPath.row]
        cell.detailTextLabel?.text = detailArray[indexPath.row]
        
        return cell
    }
}

extension AddWeightViewController:PickerViewDelegate{
    
    func getSelectRow(data:Double){
        weight = data
        detailArray[0] = "\(data)"
        
        
    }
}
