//
//  ChoiceFoodViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/19.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ChoiceFoodViewController: UIViewController{
    
    @IBOutlet weak var btnViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewButtomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sliderViewLeading: NSLayoutConstraint!
    
    
    
    
    @IBOutlet weak var containBtnView: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var addCustomBtn: UIButton!
    @IBOutlet weak var choiceFoodTableView: UITableView!
    @IBOutlet weak var recentlyButton: UIButton!
    @IBOutlet weak var commonButton: UIButton!
    @IBOutlet weak var buttonSliderView: UIView!
    @IBOutlet weak var customBotton: UIButton!
    
    
    
    
    // when actionType is update use
    typealias selectDone = (Bool)->()
    var selectFoodDone:selectDone?
    
    
    
    
    var lastPageVC:ActionType?
    var diaryType:DiaryImageType = .food
    var dinnerTime:String?
    
    var choiceArray = [foodDetails](){
        didSet{choiceFoodTableView.reloadData()}
        
    }
    
    
    var sportItemsArray = [sportDetail](){
        didSet{ choiceFoodTableView.reloadData()}
        
    }
    
    
    
    
    var currentButton:Int = 0 {
        
        didSet{
            var cond:String?
            var order:String?
            addCustomBtn.isHidden = true
            tableViewButtomConstraint.constant = 0
            
            
            
            
            switch currentButton {
                
            case 0:
                
                
                master.diaryType = .foodDetail
                sportMaster.diaryType = .sportDetail
                cond = "collection = '1'"
                
                if diaryType == .food{
                    
                    cond = "collection = '1'"
                    
                }else{
                    cond = "SportDetail_Collection = '1'"
                    
                }
                
                
            case 1:
                master.diaryType = .foodDetail
                sportMaster.diaryType = .sportDetail
                addCustomBtn.isHidden = false
                tableViewButtomConstraint.constant = addCustomBtn.frame.height
                
                
                
                if diaryType == .food{
                    
                    cond = "food_classification = '自訂'"
                    
                }else{
                    cond = "SportDetail_Classification = '自訂'"
                    
                }
                
                
            case 2:
                
                master.diaryType = .foodDiaryAndDetail
                
                sportMaster.diaryType = .sportDiaryAndDetail
                
                
                let calender = CalenderManager()
                var newDateComponent = DateComponents()
                newDateComponent.day = -7
                let  calculatedDate = Calendar.current.date(byAdding:newDateComponent, to: Date())
                let d = calender.dateToString(calculatedDate!)
                
                
                if diaryType == .food{
                    
                    cond = "Food_Diary.food_id=foodDetails_id and date >= '\(d)' group by food_id"
                    order =  "date desc"
                    
                }else{
                    cond = "Sport_Diary.SportDiary_DetailId=SportDetail_Id and SportDiary_Date >= '\(d)' group by SportDiary_DetailId"
                    order =  "SportDiary_Date desc"
                }
                
                
            default:
                break
                
                
            }
            if currentButton < 3{
                if diaryType == .food{
                    
                    
                    
                    
                    choiceArray =  master.getFoodDetails(.defaultData,
                                                         amount:nil,
                                                         weight:nil,
                                                         cond:cond,
                                                         order:order)
                    
                }else{
                    
                    sportItemsArray = sportMaster.getSportDetails(.defaultData,
                                                                  minute:nil,
                                                                  cond:cond,
                                                                  order:order)
                    
                    
                    
                }
                
                
            }
            
            choiceFoodTableView.reloadData()
            
        }
    }
    
    var lastPage = 0
    var isSerach:Bool = false
    let master = foodMaster.standard
    let sportMaster = SportMaster.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        master.foodDiaryArrary.removeAll()
        master.switchIsOn.removeAll()
        sportMaster.sportDiaryArrary.removeAll()
        sportMaster.switchIsOn.removeAll()
        
        
        if diaryType == .food{
            navigationItem.title = "搜尋食物"
        }else{
            
            
            navigationItem.title = "搜尋運動"
            
        }
        
        let plusSum = UIBarButtonItem(title:"加入", style: .done, target: self, action: #selector( insertFoodDiary))
        
        navigationItem.rightBarButtonItems = [plusSum]
        
        
        let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
        choiceFoodTableView.register(nib, forCellReuseIdentifier: "searchCell")
        buttonSliderView.layer.cornerRadius = 1
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        let last =  currentButton
        currentButton = last
        
        
        for i in sportMaster.sportDiaryArrary{
            print(i)
        }
        
        setNavBtnTitle()
        
        
    }
    
    //MARK: - IBAction
    @IBAction func choicePageButton(_ sender: UIButton) {
        let buttonTitle = sender.titleLabel?.text
        
        commonButton.isSelected = false
        recentlyButton.isSelected = false
        customBotton.isSelected = false
        
        
        if buttonTitle == "常用"{
            currentButton = 0
            commonButton.isSelected = true
            
        }else if buttonTitle == "自訂"{
            
            currentButton = 1
            customBotton.isSelected = true
            
            
        }else{
            currentButton = 2
            recentlyButton.isSelected = true
            
        }
        
        let offset = self.view.frame.width / 3.0 * CGFloat(currentButton)
        UIView.animate(withDuration: 0.1) {
            self.sliderViewLeading.constant = offset
            self.view.layoutIfNeeded()
            
        }
        
        
    }
    
    
    @IBAction func addCustomBtnAction(_ sender: Any) {
        
        
        if diaryType == .food{
            let nestPage = storyboard?.instantiateViewController(withIdentifier: "AddFoodViewController") as! AddFoodViewController
            
            navigationController?.pushViewController(nestPage, animated: true)
            
        }else{
            
            
            let nestPage = storyboard?.instantiateViewController(withIdentifier: "AddSportTableViewController") as! AddSportTableViewController
            
            navigationController?.pushViewController(nestPage, animated: true)
            
            
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Fucction
    func setNavBtnTitle(){
        
        
        if diaryType == .food{
            navigationItem.rightBarButtonItems?[0].title = "加入(\(master.switchIsOn.count))"
        }else{
            
            
            navigationItem.rightBarButtonItems?[0].title = "加入(\(sportMaster.switchIsOn.count))"
            
        }
        
        
    }
    
    
    
    
    func insertFoodDiary(){
        
        
        
        
        
        if lastPageVC == .update{
            
            
            selectFoodDone!(true)
            
        }else{
            
            
            if diaryType == .food{
                
                for diary in  master.foodDiaryArrary{
                    
                    master.diaryType = .foodDiary
                    
                    var dict = [String:String]()
                    
                    dict = [
                        "date":"'\(diary.date)'",
                        "time_interval":"'\(diary.dinnerTime)'",
                        "food_id":"\(diary.foodId)",
                        "amount":"\(diary.amount)",
                        "weight":"\(diary.weight)",
                    ]
                    
                    if let image = diary.image {
                       
                         let imageName = "food_\(image.hash)"
                         image.writeToFile(imageName: imageName, search: .documentDirectory)
                         dict["FoodDiary_ImageName"] = "'\(imageName)'"
                        
                    }
                    
                    master.insertDiary(rowInfo:dict)
                }
                
            }else{
                
                for diary in sportMaster.sportDiaryArrary{
                    
                    sportMaster.diaryType = .sportDiary
                    
                    
                    var dict = ["SportDiary_Date":"'\(diary.date)'",
                        "SportDiary_Minute":"'\(diary.minute)'",
                        "SportDiary_DetailId":"'\(diary.sportId)'",
                        "SportDiary_Calorie":"'\(diary.calories)'"]
                    
                    
                    
                    if let photo = diary.image{
                        let finalImageName = "sport_\(photo.hash)"
                        photo.writeToFile(imageName:finalImageName, search: .documentDirectory)
                        dict["SportDiary_ImageName"] = "'\(finalImageName)'"
                        
                        
                    }
                    
                    
                    sportMaster.insertDiary(rowInfo:dict)
                }
                
            }
            

        }
        
        
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
    
    func switchStats(sender:UIButton){
        
        let point = sender.convert(CGPoint.zero, to: choiceFoodTableView)
        
        if diaryType == .food {
            
            
            guard let myDinnerTime = dinnerTime,
                let indexPath = choiceFoodTableView.indexPathForRow(at: point),
                let cell = choiceFoodTableView.cellForRow(at:indexPath) as? SearchTableViewCell,
                let cellFoodId = cell.id else{
                    
                    return
            }
            
            
            
            if !sender.isSelected{
                
                
                master.switchIsOn.append(cellFoodId)
                let  food = foodDiary(dinnerTime:myDinnerTime,
                                      amount:choiceArray[(indexPath.row)].amount,
                                      weight:choiceArray[indexPath.row].weight,
                                      foodId:cellFoodId)
                master.foodDiaryArrary.append(food)
                sender.isSelected = true
                
                
                
            }else{
                
                guard let index = master.switchIsOn.index(of:cellFoodId) else{
                    return
                }
                master.switchIsOn.remove(at:index)
                sender.isSelected = false
                master.foodDiaryArrary.remove(at:index)
                
            }
            
            
        }else{
            
            
            
            
            
            guard let indexPath = choiceFoodTableView.indexPathForRow(at: point),
                let cell = choiceFoodTableView.cellForRow(at:indexPath) as? SearchTableViewCell,
                let cellId = cell.id else{
                    
                    return
            }
            
            
            
            if !sender.isSelected{
                
                
                sportMaster.switchIsOn.append(cellId)
                let  sport = sportDiary(minute:30,sportId:cellId,calories:sportItemsArray[indexPath.row].calories)
                sportMaster.sportDiaryArrary.append(sport)
                sender.isSelected = true
                
                
                
            }else{
                
                guard let index = sportMaster.switchIsOn.index(of:cellId) else{
                    return
                }
                sportMaster.switchIsOn.remove(at:index)
                sportMaster.sportDiaryArrary.remove(at:index)
                sender.isSelected = false
                
                
                
                
            }
            
        }
        setNavBtnTitle()
    }
    
}


//MARK: - UITableViewDelegate,UITableViewDataSource
extension ChoiceFoodViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if diaryType == .food{
            
            
            
            return choiceArray.count
            
        }else{
            
            
            return sportItemsArray.count
            
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as!SearchTableViewCell
        
        
        
        if diaryType == .food{
            let foodDetails = choiceArray[indexPath.row]
            searchCell.titleLabel.text = foodDetails.sampleName
            searchCell.switchButton.addTarget(self, action: #selector(switchStats),for: .touchUpInside)
            searchCell.id = choiceArray[indexPath.row].foodDetailId
            searchCell.bodyLabel.text = "1\(foodDetails.foodUnit)(\(Int(foodDetails.weight))克)"
            
            
            if master.switchIsOn.contains(choiceArray[indexPath.row].foodDetailId){
                
                searchCell.switchButton.isSelected = true
                
            }else{
                
                
                searchCell.switchButton.isSelected = false
                
            }
            
            return searchCell
            
            
            
        }else{
            let sportDetail = sportItemsArray[indexPath.row]
            searchCell.titleLabel.text = sportDetail.sampleName
            searchCell.switchButton.addTarget(self, action: #selector(switchStats),for: .touchUpInside)
            searchCell.id = sportDetail.detailId
            searchCell.bodyLabel.text = "\(sportDetail.minute)分 \(sportDetail.calories) 卡"
            
            
            if sportMaster.switchIsOn.contains(sportItemsArray[indexPath.row].detailId){
                
                searchCell.switchButton.isSelected = true
                
            }else{
                
                
                searchCell.switchButton.isSelected = false
                
            }
            
            
            
            
            return searchCell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if diaryType == .food{
            let nextPage = storyboard?.instantiateViewController(withIdentifier:"FoodDetailViewController") as! FoodDetailViewController
            nextPage.foodId = choiceArray[indexPath.row].foodDetailId
            nextPage.dinnerTime = dinnerTime
            nextPage.lastPageVC = .insert
            navigationController?.pushViewController(nextPage, animated: true)
            
            
        }else{
            
            let nextpage = storyboard?.instantiateViewController(withIdentifier: "SportDetailViewController") as! SportDetailViewController
            
            nextpage.lastPageVC = .insert
            
            nextpage.detail = sportItemsArray[indexPath.row]
            navigationController?.pushViewController(nextpage, animated: true)
            
            
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if currentButton == 1{
            return true
        }
        
        return false
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if currentButton == 1{
                
                
                let id = choiceArray[indexPath.row].foodDetailId
                let cond =  "foodDetails_id = \(id)"
                master.diaryType = .foodDetail
                
                master.deleteDiary(cond: cond)
                choiceArray.remove(at:indexPath.row)
                
                
                
                
                
                
            }
            
            tableView.reloadData()
            
        } else if editingStyle == .insert {
            
        }
        
    }
    
    
}





//MARK: -UISearchBarDelegate
extension ChoiceFoodViewController:UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else{
            return
        }
        
        
        searchBar.resignFirstResponder()
        
        
        if diaryType == .food{
            let cond = "sample_name like'%"+searchText+"%'"
            master.diaryType = .foodDetail
            choiceArray = master.getFoodDetails(.defaultData,
                                                amount:nil,
                                                weight:nil,
                                                cond:cond,
                                                order: nil)
            
        }else{
            
            let cond = "SportDetail_SampleName like'%"+searchText+"%'"
            master.diaryType = .sportDetail
            sportItemsArray = sportMaster.getSportDetails(.defaultData, minute: nil, cond: cond, order: nil)
            
            
            
            
            
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if isSerach{
            isSerach = false
            changeBtnViewTop(isUp:isSerach)
            currentButton = lastPage
        }
        
        searchBar.resignFirstResponder()
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated:true)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty{
            choiceArray.removeAll()
            sportItemsArray.removeAll()
            
        }
        
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        
        searchBar.setShowsCancelButton(true, animated:true)
        choiceArray.removeAll()
        sportItemsArray.removeAll()
        
        if !isSerach{
            isSerach = true
            changeBtnViewTop(isUp:isSerach)
            lastPage = currentButton
            currentButton = 3
            
        }
        
        return true
    }
    
    
    func changeBtnViewTop(isUp:Bool){
        
        let buttonHight = buttonView.frame.height
        
        UIView.animate(withDuration:0.3) {
            
            if isUp{
                
                self.btnViewTopConstraint.constant = -buttonHight
                
            }else{
                
                self.btnViewTopConstraint.constant = 0
            }
            
            self.view.layoutIfNeeded()
        }
    }
}

