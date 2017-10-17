//
//  WeightDiaryViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/10.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class WeightDiaryViewController: UIViewController{
    @IBOutlet weak var weightTableView: UITableView!
    
    var sectionTitle = ["體重","體脂"]
    var isExpend = [false,false]
    var containerIsDisplay:Bool = false
    var weightDiaryArray = [[WeightDiary]]()
    let weightMaster = WeightMaster.standard
    let bodyManager = BodyInformationManager.standard
    let profileManager = ProfileManager.standard
    var weightView = NickProgress2UIView()
    var bodyFatView =  NickProgress2UIView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell",bundle: nil)
        weightTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        
        let nibFooter = UINib(nibName: "FooterTableViewCell",bundle: nil)
        weightTableView.register(nibFooter, forCellReuseIdentifier: "footerCell")
        
        NotificationCenter.default.addObserver(self, selector:#selector(refreshWeightDiary), name: NSNotification.Name(rawValue: "changeDiaryData"), object:nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshWeightDiary()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func refreshWeightDiary(){
        
        if (self.parent?.parent as? MainDiaryViewController)?.currentPage != 2{
            
            return
            
        }

        weightDiaryArray.removeAll()
        weightMaster.diaryType = .weightDiary
        
        for title in sectionTitle{
            let cond = "\(WEIGHTDIARY_TYPE) = '\(title)' and \(WEIGHTDIARY_DATE) = '\(CalenderManager.standard.displayDateString())'"
            let diary = weightMaster.getWeightDiary(cond: cond, order: nil)
            weightDiaryArray.append(diary)
            
        }
        
        self.weightTableView.reloadData()
        
    }
    
    func setWeightProgress(){
        
        guard let weight = weightMaster.getLasetWeightValue(.weight) else{
            return
        }
        
        bodyManager.setBodyData(profileManager.userHeight,
                                weight,
                                profileManager.userGender)
        
        if bodyManager.getBmi() == weightView.getProgress(){
            return
            
        }
        
        
        let bmi  = String(format:"%0.1f",bodyManager.getBmi())
        weightView.setTitleText(text:bodyManager.getWeightType().rawValue)
        weightView.setTitleColor(bodyManager.getWeightTypeColor())
        weightView.setDetailText(text:"理想 \(bodyManager.getIdealWeight())kg")
        weightView.setSubTitleText(text:"BMI:\(bmi)")
        weightView.resetProgress(progress:bodyManager.getBmi())
        
    }
    
    func setBodyFatProgress(){
        
        guard let bodyFat = weightMaster.getLasetWeightValue(.bodyFat) else{
            bodyFatView.setSubTitleText(text:"--")
            return
        }
        
        if bodyFat == bodyFatView.getProgress(){
            return
        }
        
        
        let bodyType = bodyManager.getBodyFatType(fat: bodyFat)
        bodyFatView.setTitleText(text:bodyType.rawValue)
        bodyFatView.setTitleColor(bodyManager.getBodyFatTitleColor(type:bodyType))
        bodyFatView.setDetailText(text:"理想 \(bodyManager.getIdealBodyFat())%")
        bodyFatView.setSubTitleText(text:"\(bodyFat)")
        bodyFatView.resetProgress(progress:bodyFat)
        
    }
    
    
    @objc func sectionIsExpend(sender:UIButton){
        let section = sender.tag - 1000
        
        isExpend[section-1] = !isExpend[section-1]
        weightTableView.reloadSections(IndexSet(integer:section), with: .automatic)
    }
    
    
    
    @objc func plusWeight(sender:UIButton){
        
        let section = sender.tag - 1500
        let type:WeightDiaryType = section == 1 ?.weight:.bodyFat
        
        
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "AddWeightViewController") as! AddWeightViewController
        
        let data:Double
        
        if let value =  weightMaster.getLasetWeightValue(type){
            
            data = value
            
        }else{
            
            data = 15
        }
        
        nextPage.type = type
        nextPage.actionType = .insert
        nextPage.weight = data
        navigationController?.showDetailViewController(nextPage, sender: self)
    }
}


//MARK: - UITableViewDelegate,UITableViewDataSource
extension WeightDiaryViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return weightDiaryArray.count+1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0{
            return 1
        }
        
        if isExpend[section-1]{
            
            return weightDiaryArray[section-1].count
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if indexPath.section == 0{
            
            let progressCell = tableView.dequeueReusableCell(withIdentifier: "ProgressTableViewCell", for: indexPath) as! ProgressTableViewCell
            
            
            weightView = progressCell.weightProgress
            setWeightProgress()
            
            
            bodyFatView = progressCell.fatProgress
            setBodyFatProgress()
            
            
            return progressCell
            
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeightDiaryBodyTableViewCell", for: indexPath) as! WeightDiaryBodyTableViewCell
        
        
        
        let diary = weightDiaryArray[indexPath.section-1]
        cell.titleLabel.text = diary[indexPath.row].time
        
        let detailUint = indexPath.section == 1 ?"kg":"%"
        cell.detailLabel.text = "\(diary[indexPath.row].value) \(detailUint)"
        cell.photoImageView.image = UIImage(imageName:diary[indexPath.row].imageName,search:.documentDirectory)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 187
        }
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
        
        
        if section == 0{
            return nil
        }
        
        headerCell.titleLabel.text = sectionTitle[section-1]
        headerCell.totalCalorieLebel.text = nil
        headerCell.expendBtn.addTarget(self, action:#selector(sectionIsExpend), for: .touchUpInside)
        headerCell.expendBtn.tag = 1000 + section
        
        
        return headerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0{
            return 1
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 0{
            return nil
        }
        
        let diary = weightDiaryArray[section-1]
        
        let footerCell = tableView.dequeueReusableCell(withIdentifier: "footerCell") as!FooterTableViewCell
        
        var footText:String = "尚未添加紀錄"
        
        if diary.count > 0 {
            footText = "\(diary.count)項"
            
        }
        footerCell.titleLabel.text = footText
        footerCell.footerButton.addTarget(self,action:#selector(plusWeight), for: .touchUpInside)
        footerCell.footerButton.tag = 1500 + section
        
        return footerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if section == 0{
            return 20
        }
        
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0{
            return
        }
        
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "ProgressPhotoViewController") as! ProgressPhotoViewController
        
        if weightDiaryArray[indexPath.section-1][indexPath.row].imageName == "No_Image"{
            
            
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "AddWeightViewController") as! AddWeightViewController
            
            if indexPath.section == 2{
                nextPage.type = .bodyFat
            }
            
            
            nextPage.actionType = .update
            nextPage.type = .weight
            nextPage.weight = weightDiaryArray[indexPath.section-1][indexPath.row].value
            navigationController?.showDetailViewController(nextPage, sender: self)
            nextPage.weightId = weightDiaryArray[indexPath.section-1][indexPath.row].id
            
            
            return
            
        }
        
        navigationController?.pushViewController(nextPage, animated: true)
        nextPage.type = sectionTitle[indexPath.section-1]
        nextPage.weightId = weightDiaryArray[indexPath.section-1][indexPath.row].id
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if let id = weightDiaryArray[indexPath.section-1][indexPath.row].id{
                let cond =  "\(WEIGHTDIARY_ID) = \(id)"
                weightMaster.diaryType = .weightDiary
                weightMaster.deleteDiary(cond: cond)
                weightMaster.deleteImage(imageName:weightDiaryArray[indexPath.section-1][indexPath.row].imageName)
                weightDiaryArray[indexPath.section-1].remove(at:indexPath.row)
                weightTableView.reloadSections(IndexSet(integer:indexPath.section), with: .automatic)
            }
        }
        
        
    }
}

