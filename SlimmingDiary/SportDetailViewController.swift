//
//  SportDetailViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/5.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class SportDetailViewController: UIViewController {
    
    
    
    @IBOutlet weak var collectionBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var selectMinuteBtn: UIButton!
    @IBOutlet weak var sampleNameLabel: UILabel!
    
    
    var actionType:ActionType = .insert
    var numberOfRows:Int = 200
    var numberOfComponents:Int = 1
    var selectRowOfbegin:Double = 30
    
    let sportMaster = SportMaster.standard
    var selectImage:UIImage?
    
    
    var detail:sportDetail?{
        
        didSet{
            
            DispatchQueue.main.async {
                
                guard let myDetail = self.detail else{
                    return
                }
                
                self.calorieLabel.text = "消耗  \(myDetail.calories.roundTo(places: 1)) 卡"
                self.selectMinuteBtn.setTitle("\(myDetail.minute) 分鐘", for: .normal)
                self.sampleNameLabel.text = myDetail.sampleName
                
                if self.detail?.imageName != nil,
                   self.actionType == .update{
                   self.imageView.image = UIImage(imageName:myDetail.imageName, search: .documentDirectory)
                    
                }
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        calorieLabel.setShadowView(0,0.1,CGSize.zero)
        
        let insert = UIBarButtonItem(title:"新增", style: .plain, target: self, action:#selector(insertSport))
        
        navigationItem.rightBarButtonItem = insert
        
        
        if detail?.collection == 1{
            collectionBtn.isSelected = true
        }
 
       
         navigationItem.rightBarButtonItem?.title = actionType.rawValue
         navigationItem.title = "\(actionType.rawValue)運動"
     PickerViewController.shared.delegate = self
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    
    @objc func insertSport(){
        
        guard let myDetail = detail else{
            return
        }
        
        if actionType == .insert{
            
           
            
            var diary = sportDiary(minute: myDetail.minute,
                                   sportId:myDetail.detailId,
                                   calories: myDetail.calories)
            
            
            diary.image = selectImage?.resizeImage(maxLength:1024)
            
            
            // if isExist replace
            if let index =  sportMaster.switchIsOnIDs.index(of:myDetail.detailId){
                sportMaster.switchIsOnIDs.remove(at:index)
                sportMaster.sportDiarys.remove(at:index)
            }
            
            sportMaster.switchIsOnIDs.append(myDetail.detailId)
            sportMaster.sportDiarys.append(diary)
            
            
        }else{
            
            
            let cond = "\(SPORTYDIARY_ID) = '\(myDetail.diaryId)'"
            sportMaster.diaryType = .sportDiary
    
            var dict = [String:String]()
            
            if let image = selectImage{
                
                 let selectImageHash  = "sport_\(image.hash)"
                dict[SPORTYDIARY_IMAGENAME] = "'\(selectImageHash)'"
                image.writeToFile(imageName: selectImageHash, search: .documentDirectory)
                
            }
            
            dict[SPORTYDIARY_MINUTE] = "'\(Int(myDetail.minute))'"
            dict[SPORTYDIARY_CALORIE] = "'\(myDetail.calories)'"
            
            
            
            sportMaster.updataDiary(cond:cond, rowInfo:dict)
        
        }
        
        
        navigationController?.popViewController(animated: true)
    
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
    

    
    @IBAction func collectionBtnAction(_ sender: Any) {
        
        
        guard let myDetail = detail else {
            return
        }
        
        var iscollect:Int
        sportMaster.diaryType = .sportDetail
        
        if collectionBtn.isSelected{
            
            iscollect = 0
            collectionBtn.isSelected = false
            
        }else{
            
            iscollect = 1
            collectionBtn.isSelected = true
            
        }
       sportMaster.diaryType = .sportDetail
       sportMaster.updataDiary(cond: "\(SPORTDETAIL_ID) = '\(myDetail.detailId)' ",
       rowInfo: [SPORTDETAIL_COLLECTION :"'\(iscollect)'"])
        
    
    }
    
       
    
    
    @IBAction func minuteBtnAction(_ sender: Any) {
        
      PickerViewController.shared.displayDialog(present: self)
        
        
    }
    @IBAction func selectImageViewTap(_ sender: Any) {
        
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

//MARK: - UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension SportDetailViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        selectImage = UIImage()
        
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectImage = photo
            
        }
        if let myImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectImage = myImage
        }
        
        selectImage = selectImage?.resizeImage(maxLength: 1024)
        imageView.image = selectImage
        
        dismiss(animated: true, completion: nil)
        

    }

}

extension SportDetailViewController:PickerViewDelegate{
    
    func getSelectRow(data:Double){
        
        guard let myDetail = detail else{
            return
        }
        detail = sportDetail(diaryId:myDetail.diaryId,
                             detailId:myDetail.detailId,
                             minute:Int(data),
                             classification:myDetail.classification,
                             sampleName:myDetail.sampleName,
                             imageName:myDetail.imageName,
                             collection:myDetail.collection,
                             emts: myDetail.emts)
        
        
    }
}
