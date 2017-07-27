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
    var dinnerTime:String?
    var choiceArray = [foodDetails](){
        didSet{
            choiceFoodTableView.reloadData()
        }
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
                cond = "collection = '1'"
                
                
            case 1:
                master.diaryType = .foodDetail
                cond = "food_classification = '自訂'"
                addCustomBtn.isHidden = false
                tableViewButtomConstraint.constant = addCustomBtn.frame.height
                
                
            case 2:
                master.diaryType = .foodDiaryAndDetail
                let calender = CalenderManager()
                var newDateComponent = DateComponents()
                newDateComponent.day = -7
                let  calculatedDate = Calendar.current.date(byAdding:newDateComponent, to: Date())
                let d = calender.dateToString(calculatedDate!)
                cond = "foodDiary.food_id=foodDetails_id and date >= '\(d)' group by food_id"
                order =  "date desc"
                
            default:
                break
                
                
            }
            
            
            if currentButton < 3{
                
                choiceArray =  master.getFoodDetails(.defaultData,
                                                     amount:nil,
                                                     weight:nil,
                                                     cond:cond,
                                                     order:order)
            }
            
            choiceFoodTableView.reloadData()
            
        }
    }
    
    var lastPage = 0
    var viewIsframe:Bool = false
    let master = foodMaster.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        master.foodDiaryArrary.removeAll()
        master.switchIsOn.removeAll()
        
        navigationItem.title = "搜尋食物"
        let plusSum = UIBarButtonItem(title:"加入", style: .done, target: self, action: #selector( insertFoodDiary))
        
        navigationItem.rightBarButtonItems = [plusSum]
        
        buttonView.layer.shadowColor = UIColor.black.cgColor
        buttonView.layer.shadowOpacity = 0.2
        buttonView.layer.shadowOffset = CGSize(width:0, height:1)
        
        let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
        choiceFoodTableView.register(nib, forCellReuseIdentifier: "searchCell")
        
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
        let int = currentButton
        currentButton = int
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
        UIView.animate(withDuration: 0.15) {
            self.sliderViewLeading.constant = offset
            self.view.layoutIfNeeded()
            
        }
        
        
    }
    
    
    @IBAction func addCustomBtnAction(_ sender: Any) {
        let nestPage = storyboard?.instantiateViewController(withIdentifier: "AddFoodViewController") as! AddFoodViewController
        
        navigationController?.pushViewController(nestPage, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - Fucction
    func setNavBtnTitle(){
        
        navigationItem.rightBarButtonItems?[0].title = "加入(\(master.switchIsOn.count))"
        
    }
    
    func insertFoodDiary(){
        
        master.diaryType = .foodDiary
        
        for diary in  master.foodDiaryArrary{
            
            
            
            
            master.insertDiary(rowInfo:[
                "date":"'\(diary.date)'",
                "time_interval":"'\(diary.dinnerTime)'",
                "food_id":"\(diary.foodId)",
                "amount":"\(diary.amount)",
                "weight":"\(diary.weight)",
                ])
            
            
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    
    func switchStats(sender:UIButton){
        
        let point = sender.convert(CGPoint.zero, to: choiceFoodTableView)
        
        
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
            
            setNavBtnTitle()
            
        }else{
            
            guard let index = master.switchIsOn.index(of:cellFoodId) else{
                return
            }
            master.switchIsOn.remove(at:index)
            
            
            for (index,value) in  master.foodDiaryArrary.enumerated(){
                if value.foodId == cell.id{
                    master.foodDiaryArrary.remove(at:index)
                    
                }
                
                sender.isSelected = false
                setNavBtnTitle()
            }
        }
        
    }
    
    
}


//MARK: - UITableViewDelegate,UITableViewDataSource
extension ChoiceFoodViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return choiceArray.count
        
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let searchCell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as!SearchTableViewCell
        
        let foodDetails = choiceArray[indexPath.row]
        
        searchCell.titleLabel.text = foodDetails.sampleName
        searchCell.switchButton.addTarget(self, action: #selector(switchStats),for: .touchUpInside)
        searchCell.id = choiceArray[indexPath.row].foodDetailId
        searchCell.bodyLabel.text = "1\(foodDetails.foodUnit)(\(foodDetails.weight)克)"
        
        
        if master.switchIsOn.contains(choiceArray[indexPath.row].foodDetailId){
            
            searchCell.switchButton.isSelected = true
            
        }else{
            
            
            searchCell.switchButton.isSelected = false
            
        }
        
        return searchCell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let nextPage = storyboard?.instantiateViewController(withIdentifier:"FoodDetailViewController") as! FoodDetailViewController
        nextPage.foodId = choiceArray[indexPath.row].foodDetailId
        nextPage.dinnerTime = dinnerTime
        nextPage.lastPageVC = .insert
        navigationController?.pushViewController(nextPage, animated: true)
        
        
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
        let cond = "sample_name like'%"+searchText+"%'"
        master.diaryType = .foodDetail
        choiceArray = master.getFoodDetails(.defaultData,
                                            amount:nil,
                                            weight:nil,
                                            cond:cond,
                                            order: nil)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if viewIsframe{
            viewIsframe = false
            changeViewOrigin(isUp:viewIsframe)
            currentButton = lastPage
        }
        
        searchBar.resignFirstResponder()
        searchBar.text = nil
        searchBar.showsCancelButton = false
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty{
            choiceArray.removeAll()
            
        }
        
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        searchBar.showsCancelButton = true
        choiceArray.removeAll()
        if !viewIsframe{
            viewIsframe = true
            changeViewOrigin(isUp:viewIsframe)
            lastPage = currentButton
            currentButton = 3
            
        }
        
        return true
    }
    
    
    func changeViewOrigin(isUp:Bool){
        
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

