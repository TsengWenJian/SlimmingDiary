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
    let master = foodMaster.standard
    var ok:Int = {
        return 1
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 收到通知刷新 tableView
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSectionArray), name: NSNotification.Name(rawValue: "changeDiaryData"), object:nil)
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
      
        
        refreshSectionArray()
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        diaryTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        let nibBody = UINib(nibName: "BodyTableViewCell", bundle: nil)
        diaryTableView.register(nibBody, forCellReuseIdentifier: "Cell")
        
        let nibFooter = UINib(nibName: "FooterTableViewCell", bundle: nil)
        diaryTableView.register(nibFooter, forCellReuseIdentifier: "footerCell")
        
        
        
        
        
        
        
    }
    
    
    
    func refreshSectionArray(){
        
        sectionArray.removeAll()
        
        let displayDate =  CalenderManager.standard.myDateToString(CalenderManager.standard.displayDate)
        
       
        master.diaryType = .foodDiaryAndDetail
        for i in 0..<dinnerTime.count{
           

            let cond = "Food_Diary.food_id=foodDetails_id and time_interval = '\(dinnerTime[i])'and date = '\(displayDate)'"
            
            let dinnerDiary = master.getFoodDetails(.diaryDate,amount:nil,weight:nil,cond: cond,order: nil)
            sectionArray.append(dinnerDiary)
        }
        
        
        diaryTableView.reloadData()
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BodyTableViewCell
        
        
        
        
        let  diary = sectionArray[indexPath.section][indexPath.row]
        cell.titleLabel.text = diary.sampleName
        
        cell.bodyLabel.text = String(format:"%0.1f",diary.amount) + diary.foodUnit + "(" + String(Int(diary.weight)) + "克" + ")"
        cell.rightLabel.text = String(Int(diary.calorie))
        
        
        
        return cell
    }
    
    
    
    
    func sectionIsExpend(sender:UIButton){
        let section = sender.tag - 1000
        
        if isExpend[section]{
            isExpend[section] = false
        } else {
            isExpend[section] = true
        }
        diaryTableView.reloadSections(IndexSet(integer:section), with: .automatic)
    }
    
    
    
    
    func plusFood(sender:UIButton){
        
        let section = sender.tag - 1500
        
        for i in 0..<dinnerTime.count{
            if section == i{
                let nextPage = storyboard?.instantiateViewController(withIdentifier: "ChoiceFoodViewController") as! ChoiceFoodViewController
                nextPage.dinnerTime = dinnerTime[section]
                nextPage.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(nextPage,animated: true)
            }
            
        }
        
        
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource
extension FoodDiaryViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
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
        
        
        
        if isExpend[section]{
            return sectionArray[section].count
            
            
        }else{
            return 0
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if  let nextPage = storyboard?.instantiateViewController(withIdentifier: "FoodDetailViewController") as? FoodDetailViewController{

            nextPage.foodId = sectionArray[indexPath.section][indexPath.row].foodDiaryId
            nextPage.foodDiaryId = sectionArray[indexPath.section][indexPath.row].foodDiaryId
            nextPage.dinnerTime = dinnerTime[indexPath.section]
            nextPage.lastPageVC = .update
            
            
            navigationController?.pushViewController(nextPage, animated: true)
            
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let id = sectionArray[indexPath.section][indexPath.row].foodDiaryId
            let cond =  "foodDiary_id = \(id)"
            master.diaryType = .foodDiary
            master.deleteDiary(cond: cond)
            sectionArray[indexPath.section].remove(at:indexPath.row)
            
            
            
            diaryTableView.reloadSections(IndexSet(integer:indexPath.section), with: .automatic)
            
        } else if editingStyle == .insert {
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableCell(withIdentifier: "footerCell")as! FooterTableViewCell
        
        
        if sectionArray[section].count == 0{
            
            footerCell.titleLabel.text = "尚未添加食物"
            
        }else{
            footerCell.titleLabel.text = String(sectionArray[section].count) + "項"
        }
        
        
        
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
            
            if calorieSum == 0.0{
                
                return ""
            }else{
                return "- "+String(Int(calorieSum))+" 大卡"
                
            }
            
        }()
        
        var stretchbButton  = UIButton(type: .custom)
        stretchbButton = UIButton(frame:CGRect(x: 0, y: 0,
                                               width: headerCell.contentView.bounds.width,
                                               height:headerCell.contentView.bounds.height))
        stretchbButton.addTarget(self, action: #selector(sectionIsExpend), for: .touchUpInside)
        stretchbButton.tag = 1000 + section
        headerCell.contentView.addSubview(stretchbButton)
        
        
        return headerCell.contentView
        
    }
    
    
    
    
    
    
    
}



