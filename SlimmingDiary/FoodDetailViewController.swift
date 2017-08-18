//
//  FoodDetailViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class FoodDetailViewController: UIViewController{
    
    @IBOutlet weak var collectBtn: UIButton!
    
    var pickerVC = PickerViewController()
    var lastPageVC:ActionType = .insert
    var foodTitleArray = [String]()
    var foodDataArray = [String]()
    var foodUnitArray = [String]()
    var foodDiaryId:Int?
    var foodId:Int?
    var dinnerTime:String?
    var numberOfRows:Int = 0
    var numberOfComponents:Int = 0
    var setSelectRowOfbegin:Double = 0
    var correntRow:Int = 0
    var selectImage:UIImage?{
        didSet{
            foodDetailsTableView.reloadData()
        }
    }
    let master = FoodMaster.standard
    
    
    
    @IBOutlet weak var foodDetailsTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       
        
        foodDataArray = master.getFoodDataArray(lastPageVC,
                                                       foodDiaryId:foodDiaryId,
                                                       foodId:foodId,
                                                       amount:nil,
                                                       weight:nil)
        
        
        foodTitleArray = master.foodDetailTitles
        foodUnitArray = master.foodDetailUnits
        
        if master.isCollection == 1{
            collectBtn.isSelected = true
        }
        
        
        selectImage = master.foodDetailImage
        
        navigationItem.title = "食物資料"
        
        let save = UIBarButtonItem(title:lastPageVC.rawValue, style: .done, target: self, action: #selector(saveFood))
        navigationItem.rightBarButtonItems = [save]
        
        
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        foodDetailsTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        
        pickerVC = storyboard?.instantiateViewController(withIdentifier:"PickerViewController") as!
        PickerViewController
        pickerVC.delegate = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    func saveFood(){
    
        if lastPageVC == ActionType.insert{
            
            guard let myAmount = Double(foodDataArray[1]),
                let myWeight = Double(foodDataArray[2]),
                let myFoodId = foodId,
                let myDinnerTime = dinnerTime else{
                    
                    return
            }
            
            var diary = foodDiary(dinnerTime:myDinnerTime,
                                  amount:myAmount,
                                  weight:myWeight,
                                  foodId:myFoodId)
            
            diary.image = selectImage
            
            
            
            if let index =  master.switchIsOn.index(of:myFoodId){
                master.switchIsOn.remove(at:index)
                master.foodDiaryArrary.remove(at:index)
            }
            
            master.switchIsOn.append(myFoodId)
            master.foodDiaryArrary.append(diary)
            
            
        }else{
            
            
            
            
            let cond = "\(FOODDIARY_ID)=\(foodDiaryId!)"
            var dict = [String:String]()
            
            dict = ["\(FOODDIARY_AMOUNT)":"\(foodDataArray[1])",
                "\(FOODDIARY_WEIGHT)":"\(foodDataArray[2])"]
            
            if let image = selectImage{
                
                let selectImageHash  = "food_\(image.hash)"
                dict[FOODDIARY_IMAGENAME] = "'\(selectImageHash)'"
                image.writeToFile(imageName: selectImageHash, search: .documentDirectory)
                
            }
            
            
            master.diaryType = .foodDiary
            master.updataDiary(cond:cond,rowInfo:dict)
            
            
        }
        
        
        navigationController?.popViewController(animated: true)
        
        
        
    }
    
    
    
    @IBAction func collectBtnAction(_ sender: Any) {
        
        var iscollect:Int
        master.diaryType = .foodDetail
        if collectBtn.isSelected{
            
            iscollect = 0
            collectBtn.isSelected = false
            
        }else{
            
            iscollect = 1
            collectBtn.isSelected = true
            
        }
        
        master.updataDiary(cond: "\(FOODDETAIL_Id) =\(foodId!) ",
            rowInfo: ["\(FOODDETAIL_COLLECTION)" :"'\(iscollect)'"])
        
        
        
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            
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
            
        }else if indexPath.section == 1{
            
            correntRow = indexPath.row
            
            if indexPath.row < 2{
                
                if indexPath.row == 0{
                    
                    numberOfRows = 30
                    numberOfComponents = 2
                    
                    
                }else{
                    
                    numberOfRows = 2000
                    numberOfComponents = 1
                    
                }
                
                if let baginData =  Double(foodDataArray[indexPath.row+1]){
                    setSelectRowOfbegin = baginData
                }
                pickerVC.displayPickViewDialog(present: self)
                
            }
        }
    }
    
    
    
    
    
    
}
//MARK: - UITableViewDelegate,UITableViewDataSource
extension FoodDetailViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
        headerCell.contentView.layer.cornerRadius = 0
        headerCell.rightLabel.text = ""
        
        if section == 1{
        
            headerCell.titleLabel.text = dinnerTime
            headerCell.totalCalorieLebel.text = foodDataArray[0]
            return headerCell
            
        }else if section == 2{
            
            headerCell.titleLabel.text = "營養標示"
            return headerCell
            
        }
        
        return nil
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0{
            return 0.1
        }
        return 44
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0{
            return 180
        }
        
        
        if indexPath.row == 2 && indexPath.section == 1{
            return 180
        }
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.1
        }
        return 20
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
            
        }else if section == 1{
            
            return 3
            
        }else{
            return foodTitleArray.count-3
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0{
            
            let cell  = tableView.dequeueReusableCell(withIdentifier: "DetailImageTableViewCell", for: indexPath) as! DetailImageTableViewCell
            
            
            if selectImage != nil{
                
                cell.selectImageView.image = selectImage
    
            }
            
            return cell
            
        }else if indexPath.section == 1{
            
            if indexPath.row <= 1{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as!FoodDetailTableViewCell
                cell.title.text = foodTitleArray[indexPath.row+1]
                cell.dataLabel.text = foodDataArray[indexPath.row+1]
                cell.unit.text = foodUnitArray[indexPath.row+1]
                
                
                
                return cell
                
            }else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailProgressCell") as!DetailProgressCell
                
                
                var total = master.total
                
                if total.isNaN{
                    total = 1
                }
                
                if let data1 = Double(foodDataArray[4]),
                   let data2 = Double(foodDataArray[5]),
                   let data3 = Double(foodDataArray[8]) {
                    
                    
                    
                    let pro = myProgress(progess:(ceil((data1/total)*100)),color:blue)
                    let pro2 = myProgress(progess:(ceil((data2/total)*100)), color:seagreen)
                    let pro3 = myProgress(progess:(ceil((data3/total)*100)), color:coral)
                    
                    cell.circleProgressRate.setTitleLabelText(text:foodDataArray[3],size:25)
                    cell.circleProgressRate.setSubTitleLabelText(text:"kcal",size:18)
                    cell.circleProgressRate.setProgress(pro: [pro,pro2,pro3])
                    
                    
                    cell.proteinLabel.text = "蛋白質 " +  String(format: "%.0f", round((data1/total)*100)) + "%"
                    cell.fatLabel.text = "脂肪 " + String(format: "%.0f", round((data2/total)*100)) + "%"
                    cell.carbohydrateLabel.text = "碳水化合物 " +  String(format: "%.0f", round((data3/total)*100)) + "%"
                }
                    return cell
            }
            
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell")
            var data = foodDataArray[indexPath.row+3]
            
            if  data == "0.0"{
                data = "-"
                
            }
            cell?.detailTextLabel?.text = data+foodUnitArray[indexPath.row+3]
            cell?.textLabel?.text = foodTitleArray[indexPath.row+3]
            
            return cell!
            
            
            
        }
        
        
    }
    
}

extension FoodDetailViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        selectImage = UIImage()
        
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage{
            selectImage = photo
            
        }
        if let myImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectImage = myImage
        }
        
        selectImage = selectImage?.resizeImage(maxLength: 1024)
        
        
        dismiss(animated: true, completion: nil)
        
        
        
    }
    
}

//MARK: - PickerViewDelegate
extension FoodDetailViewController:PickerViewDelegate{
    
    
    
    func getSelectRow(data:Double) {
        
        
        
        guard var amount = Double(foodDataArray[1]),
              var weight = Double(foodDataArray[2]) else{
                return
        }
        
      
        
        if correntRow == 0{
            
            amount = data
            
        }else {
            
            weight = data
        }
        
        foodDataArray = master.getFoodDataArray(lastPageVC,
                                                       foodDiaryId:foodDiaryId,
                                                       foodId:foodId,
                                                       amount:amount,
                                                       weight:weight)
        foodDetailsTableView.reloadData()
    }
    
}

