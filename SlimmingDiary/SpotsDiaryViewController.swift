//
//  SpotsDiaryTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/11.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class SpotsDiaryViewController:UIViewController{
    @IBOutlet weak var spotsDiaryTableView: UITableView!
    let dinnerTime = ["運動"]
    var isExpend:Bool = false
    var sportItems = [sportDetail](){
        didSet{spotsDiaryTableView.reloadData()}
    }
    let master = SportMaster.standard
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        spotsDiaryTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        let nibBody = UINib(nibName: "BodyTableViewCell", bundle: nil)
        spotsDiaryTableView.register(nibBody, forCellReuseIdentifier: "Cell")
        
        let nibFooter = UINib(nibName: "FooterTableViewCell", bundle: nil)
        spotsDiaryTableView.register(nibFooter, forCellReuseIdentifier: "footerCell")
        
    
        
    }
    
    
    
    
    func refreshSectionArray(){
        
        
        
        let displayDate =  CalenderManager.standard.displayDateString()
        
        
        master.diaryType = .sportDiaryAndDetail
        let cond = "Sport_Diary.SportDiary_DetailId=SportDetail_Id and SportDiary_Date = '\(displayDate)'"
        
        let items = master.getSportDetails(.diaryData, minute: nil, cond: cond, order: nil)
        sportItems = items
        
    
    }
    
    
    func sectionIsExpend(sender:UIButton){
        
        
        if isExpend{
            isExpend = false
        } else {
            isExpend = true
        }
        spotsDiaryTableView.reloadSections(IndexSet(integer:0), with: .automatic)
    }
    
    func plusFood(sender:UIButton){
        
        
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "ChoiceFoodViewController") as! ChoiceFoodViewController
        nextPage.dinnerTime = ""
        nextPage.diaryType = .sport
        navigationController?.pushViewController(nextPage,animated: true)
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        refreshSectionArray()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK: - UITableViewDelegate,UITableViewDataSource
extension SpotsDiaryViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        
        if isExpend {
            return sportItems.count
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!BodyTableViewCell
        
        let item = sportItems[indexPath.row]
        cell.titleLabel.text = item.sampleName
        cell.bodyLabel.text = "\(item.minute)分"
        cell.rightLabel.text = String(Int(item.calories))
        
        let image = item.imageName == nil ? UIImage(named: "sport"): UIImage(imageName:item.imageName,
                                                                             search:.documentDirectory)
        cell.leftImageView.image = image
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
        headerCell.titleLabel.text = dinnerTime[section]
        
        headerCell.totalCalorieLebel.text = {
            
            
            var calorieSum:Double = 0
            
            for i in sportItems{
                
                calorieSum += i.calories
            }
            
            
            if calorieSum == 0.0{
                return ""
            }else{
                return "- "+String(Int(calorieSum))+" 大卡"
                
            }
        }()
        
        
        headerCell.expendBtn.addTarget(self, action: #selector(sectionIsExpend), for: .touchUpInside)
        
        
        return headerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableCell(withIdentifier: "footerCell") as!FooterTableViewCell
        if sportItems.count == 0{
            
            footerCell.titleLabel.text = "尚未添加運動"
            
        }else{
            footerCell.titleLabel.text = String(sportItems.count) + "項"
        }
        
        
        
        footerCell.footerButton.addTarget(self, action: #selector(plusFood(sender:)), for: .touchUpInside)
        
        
        
        
        return footerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextPage = storyboard?.instantiateViewController(withIdentifier:"SportDetailViewController") as! SportDetailViewController
        nextPage.detail = sportItems[indexPath.row]
        nextPage.lastPageVC = .update
        navigationController?.pushViewController(nextPage, animated: true)
        
        
        
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            
            let id = sportItems[indexPath.row].diaryId
            let cond =  "SportDiary_Id = \(id)"
            master.diaryType = .sportDiary
            master.deleteDiary(cond: cond)
            master.deleteImage(imageName:sportItems[indexPath.row].imageName)
            sportItems.remove(at:indexPath.row)
            
            
        }
    }
    
    
}
