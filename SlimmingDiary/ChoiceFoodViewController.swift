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
    var sumLabel = UILabel()
    
    
    
    
    // when actionType is update use
    typealias selectDone = (Bool)->()
    var selectItemsDone:selectDone?
    
    
    
    var actionType:ActionType?
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
                
                
                foodMaster.diaryType = .foodDetail
                sportMaster.diaryType = .sportDetail
                cond = diaryType == .food ? "\(FOODDETAIL_COLLECTION) = '1'":"\(SPORTDETAIL_COLLECTION) = '1'"
                
            case 1:
                
                foodMaster.diaryType = .foodDetail
                sportMaster.diaryType = .sportDetail
                addCustomBtn.isHidden = false
                tableViewButtomConstraint.constant = addCustomBtn.frame.height
                cond = diaryType == .food ?"\(FOODDETAIL_CLASSIFICATION) = '自訂'":"\(SPORTDETAIL_CLASSIFICATION) = '自訂'"
                
                
            case 2:
                
                foodMaster.diaryType = .foodDiaryAndDetail
                sportMaster.diaryType = .sportDiaryAndDetail
                
                
                let calender = CalenderManager()
                var newDateComponent = DateComponents()
                newDateComponent.day = -7
                let offset = TimeZone.current.secondsFromGMT()
                let date = Date(timeInterval:TimeInterval(offset), since:Date())
                if  let  calculatedDate = Calendar.current.date(byAdding:newDateComponent,to:date){
                    let calDateString = calender.dateToString(calculatedDate)
                    
                    
                    if diaryType == .food{
                        
                        cond = "Food_Diary.\(FOODDIARY_DETAILID)=\(FOODDETAIL_Id) and \(FOODDIARY_DATE) >= '\(calDateString)' group by \(FOODDIARY_DETAILID)"
                        order =  "\(FOODDIARY_DATE) desc"
                        
                    }else{
                        cond = "Sport_Diary.\(SPORTYDIARY_DETAILID)=\(SPORTDETAIL_ID) and \(SPORTYDIARY_DATE) >= '\(calDateString)' group by \(SPORTYDIARY_DETAILID)"
                        
                        order =  "\(SPORTYDIARY_DATE) desc"
                    }
                }
                
            default:
                
                break
                
                
            }
            
            if currentButton < 3{
                if diaryType == .food{
                    
                    choiceArray =  foodMaster.getFoodDetails(.defaultData,amount:nil,
                                                             weight:nil,cond:cond,order:order)
                }else{
                    
                    sportItemsArray = sportMaster.getSportDetails(.defaultData,minute:nil,
                                                                  cond:cond,order:order)
                }
            }
            
            choiceFoodTableView.reloadData()
            
        }
    }
    
    var lastPage = 0
    var isSerach:Bool = false
    let foodMaster = FoodMaster.standard
    let sportMaster = SportMaster.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        navigationItem.title = diaryType == .food ? "搜尋食物":"搜尋運動"
        
        
        let plusSum = UIBarButtonItem(title:"加入", style: .done, target: self, action: #selector(insertDiary))
        
        
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        customView.backgroundColor = coral
        let p = UIBarButtonItem(customView:customView)
        navigationItem.rightBarButtonItems = [p,plusSum]
        sumLabel.textAlignment = .center
        sumLabel.frame = customView.bounds
        sumLabel.textColor = UIColor.white
        sumLabel.font = UIFont.systemFont(ofSize: 12)
        customView.layer.cornerRadius = 10
        customView.addSubview(sumLabel)
        
        
        
        let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
        choiceFoodTableView.register(nib, forCellReuseIdentifier: "searchCell")
        buttonSliderView.layer.cornerRadius = 1
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        let last =  currentButton
        currentButton = last
        setNavSelectSum()
        
    }
    
    //MARK: - IBAction
    @IBAction func choicePageButton(_ sender: UIButton) {
        
        
        commonButton.isSelected = false
        recentlyButton.isSelected = false
        customBotton.isSelected = false
        
        let currentPage = sender.tag
        
        if currentPage == 100 {
            
            currentButton = 0
            commonButton.isSelected = true
            
        }else if currentPage == 101 {
            
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
    func setNavSelectSum(){
        
        let count = diaryType == .food ? foodMaster.switchIsOn.count:sportMaster.switchIsOn.count
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.duration = 0.1
        scale.fromValue = 1
        scale.toValue = 1.6
        scale.autoreverses = true
        sumLabel.text = "\(count)"
        navigationItem.rightBarButtonItems?[0].customView?.layer.add(scale, forKey: nil)
        
        
    }
    
    
    deinit {
        
        
        foodMaster.removeFoodDiarysAndSwitch()
        sportMaster.removeSportDiarysAndSwitchIsOn()

    }
    
    func insertDiary(){
        
        
        if actionType == .update{
            
            
            selectItemsDone!(true)
            
            
            
        }else{
            
            if diaryType == .food{
                
                for diary in  foodMaster.foodDiaryArrary{
                    
                    foodMaster.insertFoodDiary(diary: diary)
                    
                }
                
            }else{
                
                for diary in sportMaster.sportDiaryArrary{
                    
                    sportMaster.insertWeightDiary(diary:diary)
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
                
                
                foodMaster.switchIsOn.append(cellFoodId)
                let  food = foodDiary(dinnerTime:myDinnerTime,
                                      amount:choiceArray[(indexPath.row)].amount,
                                      weight:choiceArray[indexPath.row].weight,
                                      foodId:cellFoodId)
                foodMaster.foodDiaryArrary.append(food)
                sender.isSelected = true
                
                
                
            }else{
                
                guard let index = foodMaster.switchIsOn.index(of:cellFoodId) else{
                    return
                }
                foodMaster.switchIsOn.remove(at:index)
                sender.isSelected = false
                foodMaster.foodDiaryArrary.remove(at:index)
                
            }
            
            
        }else{
            
            guard let indexPath = choiceFoodTableView.indexPathForRow(at: point),
                let cell = choiceFoodTableView.cellForRow(at:indexPath) as? SearchTableViewCell,
                let cellId = cell.id else{
                    
                    return
            }
            
            
            
            if !sender.isSelected{
                
                
                sportMaster.switchIsOn.append(cellId)
                let sport = sportDiary(minute:30,sportId:cellId,calories:sportItemsArray[indexPath.row].calories)
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
        setNavSelectSum()
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
            
            
            if foodMaster.switchIsOn.contains(choiceArray[indexPath.row].foodDetailId){
                
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
            
            nextpage.actionType = .insert
            
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
                
                if diaryType == .food{
                    
                    let id = choiceArray[indexPath.row].foodDetailId
                    let cond =  "\(FOODDETAIL_Id) = \(id)"
                    foodMaster.diaryType = .foodDetail
                    foodMaster.updataDiary(cond: cond,
                                           rowInfo: [FOODDETAIL_CLASSIFICATION:"'其他'"])
                    choiceArray.remove(at:indexPath.row)
                    
                }else{
                    
                    let id = sportItemsArray[indexPath.row].detailId
                    let cond =  "\(SPORTDETAIL_ID) = \(id)"
                    sportMaster.diaryType = .sportDetail
                    sportItemsArray.remove(at: indexPath.row)
                    sportMaster.updataDiary(cond: cond,
                                            rowInfo: [SPORTDETAIL_CLASSIFICATION:"'其他'"])
                    
                }
                
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
            let cond = "\(FOODDETAIL_SAMPLENAME) like'%"+searchText+"%'"
            foodMaster.diaryType = .foodDetail
            choiceArray = foodMaster.getFoodDetails(.defaultData,
                                                    amount:nil,
                                                    weight:nil,
                                                    cond:cond,
                                                    order: nil)
            
        }else{
            
            let cond = "\(SPORTDETAIL_SAMPLENAME) like'%"+searchText+"%'"
            sportMaster.diaryType = .sportDetail
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

