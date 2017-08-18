//
//  DiaryTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/26.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class FoodDiaryViewController: UIViewController{
    @IBOutlet weak var diaryTableView: UITableView!
    let dinnerTime = ["早餐","午餐","晚餐","其他"]
    var isExpend = [true,true,true,true]
    var sectionArray = [[foodDetails]]()
    let master = FoodMaster.standard
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        diaryTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        let nibBody = UINib(nibName: "BodyTableViewCell", bundle: nil)
        diaryTableView.register(nibBody, forCellReuseIdentifier: "Cell")
        
        let nibFooter = UINib(nibName: "FooterTableViewCell", bundle: nil)
        diaryTableView.register(nibFooter, forCellReuseIdentifier: "footerCell")

        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSectionArray), name: NSNotification.Name(rawValue: "changeDiaryData"), object:nil)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        refreshSectionArray()
        

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func refreshSectionArray(){
        
        sectionArray.removeAll()
        
        let displayDate =  CalenderManager.standard.displayDateString()
        
       
        master.diaryType = .foodDiaryAndDetail
        for i in 0..<dinnerTime.count{
           

            let cond = "Food_Diary.\(FOODDIARY_DETAILID)=\(FOODDETAIL_Id) and \(FOODDIARY_DINNERTIME) = '\(dinnerTime[i])'and \(FOODDIARY_DATE) = '\(displayDate)'"
            let dinnerDiary = master.getFoodDetails(.diaryData,amount:nil,weight:nil,cond:cond,order: nil)
            sectionArray.append(dinnerDiary)
        }
        
        
        diaryTableView.reloadData()
        
    }
    
    
    
    
    func sectionIsExpend(sender:UIButton){
        let section = sender.tag - 1000
        
        isExpend[section] = isExpend[section] == true ? false:true
        diaryTableView.reloadSections(IndexSet(integer:section), with: .automatic)
    }
    
    

    func plusFood(sender:UIButton){
        
        let section = sender.tag - 1500
        
        for i in 0..<dinnerTime.count{
            if section == i{
                let nextPage = storyboard?.instantiateViewController(withIdentifier: "ChoiceFoodViewController") as! ChoiceFoodViewController
                nextPage.dinnerTime = dinnerTime[section]
                nextPage.diaryType = .food
                
                navigationController?.pushViewController(nextPage,animated: true)
            }
            
        }
        
        
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource
extension FoodDiaryViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return dinnerTime.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return  isExpend[section] == true ? sectionArray[section].count:0
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BodyTableViewCell
        
        
        let  diary = sectionArray[indexPath.section][indexPath.row]
        cell.titleLabel.text = diary.sampleName
        
        cell.bodyLabel.text = "\(diary.amount)" + diary.foodUnit + "(\(Int(diary.weight))克)"
        cell.rightLabel.text = String(Int(diary.calorie))
        
        
        cell.leftImageView.image = diary.imageName == nil ? UIImage(named: "food"):UIImage(imageName: diary.imageName,
                                                                                           search: .documentDirectory)

        
        
        return cell
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if  let nextPage = storyboard?.instantiateViewController(withIdentifier: "FoodDetailViewController") as? FoodDetailViewController{

            let record = sectionArray[indexPath.section][indexPath.row]
            nextPage.foodId = record.foodDetailId
            nextPage.foodDiaryId = record.foodDiaryId
            nextPage.dinnerTime = dinnerTime[indexPath.section]
            nextPage.lastPageVC = .update
            
            navigationController?.pushViewController(nextPage, animated: true)
            
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let id = sectionArray[indexPath.section][indexPath.row].foodDiaryId
            let cond =  "\(FOODDIARY_ID) = \(id)"
            master.diaryType = .foodDiary
            master.deleteDiary(cond: cond)
            master.deleteImage(imageName:sectionArray[indexPath.section][indexPath.row].imageName)
            sectionArray[indexPath.section].remove(at:indexPath.row)
           

            diaryTableView.reloadSections(IndexSet(integer:indexPath.section), with: .automatic)
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableCell(withIdentifier: "footerCell")as! FooterTableViewCell
        
        let recordCount = sectionArray[section].count
        
        footerCell.titleLabel.text = recordCount == 0 ?"尚未添加食物":"\(sectionArray[section].count) 項"
        footerCell.footerButton.addTarget(self, action: #selector(plusFood(sender:)), for: .touchUpInside)
        footerCell.footerButton.tag = 1500 + section
        
        
        return footerCell.contentView

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
        
        
        headerCell.titleLabel.text = dinnerTime[section]
        
        headerCell.totalCalorieLebel.text = {
            var calorieSum:Double = 0
            for foodDiaryCaloria in sectionArray[section]{
                
                calorieSum+=foodDiaryCaloria.calorie
            }
            
            return calorieSum == 0.0 ? "" : "- \(Int(calorieSum)) 大卡"
            
           }()
        
        
        headerCell.expendBtn.addTarget(self, action: #selector(sectionIsExpend), for: .touchUpInside)
        headerCell.expendBtn.tag = 1000 + section
        
        
        
        return headerCell.contentView
        
    }

}



