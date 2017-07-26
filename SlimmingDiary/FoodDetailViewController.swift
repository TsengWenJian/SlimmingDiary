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
    let detailManager = foodDetailManager()
    var pickerVC = PickerViewController()
    var lastPageVC:ActionType!
    var foodTitleArray = [String]()
    var foodDataArray = [String]()
    var foodUnitArray = [String]()
    var amount:Double?
    var weight:Double?
    var foodDiaryId:Int?
    var foodId:Int?
    var dinnerTime:String?
    var numberOfRows:Int = 0
    var numberOfComponents:Int = 0
    var setSelectRowOfbegin:Double = 0
    let master = foodMaster.standard
    
    
    
    @IBOutlet weak var foodDetailsTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var action:String
        
        foodDataArray = detailManager.getFoodDataArray(lastPageVC,
                                                       foodDiaryId:foodDiaryId,
                                                       foodId:foodId,
                                                       amount:amount,
                                                       weight:weight)
        
        
        foodTitleArray = detailManager.foodTitle
        foodUnitArray = detailManager.foodUnit
        
        if detailManager.isCollection == 1{
            collectBtn.isSelected = true
        }
        
        
        
        
        navigationItem.title = "食物資料"
        
        if(lastPageVC == ActionType.insert){
            action = "加入"
        }else{
            action = "修改"
            
        }
        
        
        let save = UIBarButtonItem(title:action, style: .done, target: self, action: #selector(saveFood))
        navigationItem.rightBarButtonItems = [save]
        
        
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        foodDetailsTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        
        pickerVC = storyboard?.instantiateViewController(withIdentifier:"PickerViewController") as!
        PickerViewController
        pickerVC.delegate = self
        
    }
    
    
    
    
    func saveFood(){
        
        
        
        if(lastPageVC == ActionType.insert){
            
            guard let myAmount = Double(foodDataArray[1]),
                let myWeight = Double(foodDataArray[2]),
                let myFoodId = foodId,
                let myDinnerTime = dinnerTime else{
                    
                    return
            }
            
            let diary = foodDiary(dinnerTime:myDinnerTime,
                                  amount:myAmount,
                                  weight:myWeight,
                                  foodId:myFoodId)
            
            if let index =  master.switchIsOn.index(of:myFoodId){
                master.switchIsOn.remove(at:index)
                 master.foodDiaryArrary.remove(at:index)
            }
            
            master.switchIsOn.append(myFoodId)
            master.foodDiaryArrary.append(diary)
            
            
        }else{
            
            
            
            
            let cond = "foodDiary_id=\(foodDiaryId!)"
            
            master.diaryType = .foodDiary
            master.updataDiary(cond:cond,
                               rowInfo:["amount":"\(foodDataArray[1])",
                                "weight":"\(foodDataArray[2])"])
            
            
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
        
        master.updataDiary(cond: "foodDetails_id =\(foodId!) ",
            rowInfo: ["collection" :"'\(iscollect)'"])
        
        
        
        
    }
    
    
    
    func changeData(sender:UIButton){
        
        let point = sender.convert(CGPoint.zero, to:foodDetailsTableView)
        let indexPath = foodDetailsTableView.indexPathForRow(at: point)
        let cell = foodDetailsTableView.cellForRow(at:indexPath!) as! FoodDetailTableViewCell
        
        
        if indexPath?.row == 0{
            numberOfRows = 30
            numberOfComponents = 2
            setSelectRowOfbegin = Double(cell.dataLabel.text!)!
            
        }else{
            numberOfRows = 2000
            numberOfComponents = 1
            setSelectRowOfbegin = Double(cell.dataLabel.text!)!
            
            
        }
        
        pickerVC.displayPickViewDialog(present: self)
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
//MARK: - UITableViewDelegate,UITableViewDataSource
extension FoodDetailViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
        if section == 0{
            headerCell.titleLabel.text = dinnerTime
            headerCell.totalCalorieLebel.text = "-"+foodDataArray[0]
            return headerCell
            
        }else{
            
            headerCell.titleLabel.text = "營養標示"
            return headerCell
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 && indexPath.section == 0{
            return 200
        }
        return 44
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 3
        }else{
            return foodTitleArray.count-3
            
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0{
            
            if indexPath.row <= 1{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as!FoodDetailTableViewCell
                cell.title.text = foodTitleArray[indexPath.row+1]
                cell.dataLabel.text = foodDataArray[indexPath.row+1]
                cell.unit.text = foodUnitArray[indexPath.row+1]
                cell.dataButton.addTarget(self, action:#selector(changeData), for:.touchUpInside)
                
                
                return cell
                
            }else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailProgressCell") as!DetailProgressCell
                
                
                var total = detailManager.total
                
                if total == 0.0{
                    total = 1
                }
                
                
                let pro = myProgress(progess:Int(ceil((Double(foodDataArray[4])!/total)*100)), color:blue)
                let pro2 = myProgress(progess:Int(ceil((Double(foodDataArray[5])!/total)*100)), color:seagreen)
                let pro3 = myProgress(progess:Int(ceil((Double(foodDataArray[8])!/total)*100)), color:coral)
                
                
                
                cell.circleProgressRate.setTitleLabelText(text: foodDataArray[3], size: 25)
                cell.circleProgressRate.setSubTitleLabelText(text:"kcal", size: 18)
                cell.circleProgressRate.setProgress(pro: [pro,pro2,pro3])
                
                
                
                
                
                cell.proteinLabel.text = "蛋白質 " + String(Int(round((Double(foodDataArray[4])!/total)*100))) + "%"
                cell.fatLabel.text = "脂肪 " + String(Int(round((Double(foodDataArray[5])!/total)*100))) + "%"
                
                cell.carbohydrateLabel.text = "碳水化合物 " + String(Int(round((Double(foodDataArray[8])!/total)*100))) + "%"
                
                
                
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
//MARK: - PickerViewDelegate
extension FoodDetailViewController:PickerViewDelegate{
    
    
    
    func getSelectRow(data:Double) {
        
        
        
    
        if numberOfRows == 30{
            
            amount = Double(data)
            
        }else{
            
            weight = Double(data)
        }
        
        foodDataArray = detailManager.getFoodDataArray(lastPageVC,
                                                       foodDiaryId:foodDiaryId,
                                                       foodId:foodId,
                                                       amount:amount,
                                                       weight:weight)
        foodDetailsTableView.reloadData()
    }
    
}

