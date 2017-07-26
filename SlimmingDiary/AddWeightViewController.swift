//
//  AddWeightViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/17.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit





class AddWeightViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addPhotoTableView: UITableView!
    
    var type = WeightDiaryType.weight
    
    
    var detailArray = ["","加入"]{
        didSet{
            
            addPhotoTableView.reloadData()
            
        }
    }
    
    
    var titleArray = ["體重","進展照片"]
    var image:UIImage?
    
    
    var weight:Double = 0
    var actionType:ActionType = .insert
    var weightId:Int?
    
    
    
    
    
    let proFileManager = ProfileManager.standard
    let weightMaster = WeightMaster.standard
    
    var pickerVC:PickerViewController!
    var numberOfRows:Int = 300
    var numberOfComponents:Int = 2
    var setSelectRowOfbegin:Double = 1.0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerVC = storyboard?.instantiateViewController(withIdentifier:"PickerViewController")
            as! PickerViewController
        
        
        pickerVC.delegate = self
        titleArray[0] = type.rawValue
        detailArray[0] = "\(weight)"
        
        
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func cancelAction(sender:UIButton){
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func confirmAction(sender:UIButton){
        
        
        var imageName:String?
        
        if let myImage = image{
            
            
            let hashString = "Cache_\(myImage.hash)"
            
            let cachesURL = FileManager.default.urls(for:.cachesDirectory,in:.userDomainMask).first
            let fullFileImageName = cachesURL?.appendingPathComponent(hashString)
            
            
            
            let imageData = UIImageJPEGRepresentation(myImage,1)
            
            
            do{
                try imageData?.write(to:fullFileImageName!,options: [.atomic])
            }catch{
                
                
                print("寫入照片失敗")
                
                return
            }
            
            imageName = hashString
            
        }
        
        
         weightMaster.diaryType = .weightDiary
        
        if actionType == .update {
            
            
            if let id = weightId {
                let cond = "Weight_Id = '\(id)'"
               
                weightMaster.updataDiary(cond:cond,rowInfo: ["Weight_Photo":"'\(imageName ?? "No_Image")'",
                    "Weight_Value":"'\(weight)'"])
            }
            
            
        }else{
            
            let calender = CalenderManager.standard
            if calender.displayDateString() == calender.currentDateString() || calender.isAfterCurrentDay(date:calender.displayDate){
                proFileManager.setUserWeight(weight)
                
            }

            
            
            let diary = WeightDiary(id:nil,
                                    date:calender.displayDateString(),
                                    time:calender.getCurrentTime(),
                                    type:titleArray[0],
                                    value:weight,
                                    photo:imageName)
            
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
       
        image = UIImage()
        
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage{
            image = photo
            
        }
        
        
        if let myImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = myImage
        }
        
        
        
        
       
        photoImageView.image = image?.resizeImage(maxLength:1024)
        
         dismiss(animated: true, completion: nil)
        
    }
    
    
    
}



extension AddWeightViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "AddWeightHeaderTableViewCell") as! AddWeightHeaderTableViewCell
        
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
            
            pickerVC.displayPickViewDialog(present: self)
            
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
