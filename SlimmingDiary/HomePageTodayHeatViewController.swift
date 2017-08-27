//
//  HomePageTodayHeatViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/10.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class HomePageTodayHeatViewController: UIViewController,UITextViewDelegate{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var TodayHeatView: UIView!
    @IBOutlet weak var foodCalorieLabel: UILabel!
    @IBOutlet weak var resultCalorieLabel: UILabel!
    @IBOutlet weak var sportCalorieLabel: UILabel!
    @IBOutlet weak var basicCalorieLabel: UILabel!

    let bodyManager = BodyInformationManager.standard
    let profileManager = ProfileManager.standard
    let foodManager = FoodMaster.standard
    let sportMaster = SportMaster.standard
    let textView = UITextView()
    let rangeTextLabel = UILabel()
    let embraveDefault = "請輸入激勵語..."
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let offsety:CGFloat = 214
        scrollView.contentSize = CGSize(width:view.frame.width,height:offsety*2-50)
        
        
        let shadowView = UIView()
        shadowView.frame = CGRect(x:0,y:offsety-50,width:view.frame.width,height:offsety)
        shadowView.backgroundColor = UIColor.black
        shadowView.alpha = 0.7
        
        textView.delegate = self
        
        let embraveText = profileManager.userEmbraveText
        
        if embraveText == nil  {
            textView.text = embraveDefault
            
        }else{
            
            textView.text = embraveText
        }
        
        
        textView.frame = CGRect(x:10,y:offsety-45,
                                width:shadowView.frame.size.width-10,
                                height:shadowView.frame.height)

        textView.textColor = UIColor.white
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize:18)
        
        
        rangeTextLabel.frame = CGRect(x:0, y:shadowView.frame.maxY-30,
                                      width: view.frame.width-10,
                                      height:20)
        rangeTextLabel.textAlignment = .right
        rangeTextLabel.text = "\(textView.text.characters.count)/120"
        rangeTextLabel.textColor = UIColor.white
        
        
        
        scrollView.addSubview(shadowView)
        scrollView.addSubview(textView)
        scrollView.addSubview(rangeTextLabel)
        
        
        let doneToolbar: UIToolbar = UIToolbar(frame:CGRect(x:0,
                                                             y:0,
                                                             width:view.frame.width,
                                                             height: 50))
        doneToolbar.barStyle = .default
        doneToolbar.backgroundColor = UIColor.white
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem:UIBarButtonSystemItem.flexibleSpace,
                                        target:nil,
                                        action: nil)
        
        
        let doneBtn: UIBarButtonItem  = UIBarButtonItem(title:"確定",
                                                        style:UIBarButtonItemStyle.done,
                                                        target:self,
                                                        action:#selector(doneBtnAction))
        
        
        var items = [UIBarButtonItem]()
        
        items.append(flexSpace)
        items.append(doneBtn)
        doneToolbar.items = items
        textView.inputAccessoryView = doneToolbar
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        bodyManager.setBodyData(profileManager.userHeight,
                                profileManager.userWeight,
                                profileManager.userGender)
        
        
        let basic = Int(bodyManager.getDailyCaloriesRequired())
        let food = Int(getTodayFoodCalorie())
        let sport = Int(getTodaySportCaloree())
        
        
        basicCalorieLabel.text = "\(basic)"
        foodCalorieLabel.text = "\(food)"
        sportCalorieLabel.text = "\(sport)"
        resultCalorieLabel.text = "\(basic - food)"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func getTodaySportCaloree()->Double{
        
        let cond = "Sport_Diary.\(SPORTYDIARY_DETAILID)=\(SPORTDETAIL_ID) and \(SPORTYDIARY_DATE) = '\(CalenderManager.standard.currentDateString())'"
        
        
        sportMaster.diaryType = .sportDiaryAndDetail
        let sportDetail = sportMaster.getSportDetails(.diaryData, minute: nil, cond: cond, order: nil)
        
        var calorieSum:Double = 0
        for sport in sportDetail{
            
            calorieSum += sport.calories
            
        }

        return calorieSum
        
    }

    
    func doneBtnAction() {
        textView.resignFirstResponder()
        profileManager.setUserEmbrave(textView.text)
        
        
    }
    
    func getTodayFoodCalorie()->Double{
        
        let cond = "Food_Diary.\(FOODDIARY_DETAILID)=\(FOODDETAIL_Id) and \(FOODDIARY_DATE) = '\(CalenderManager.standard.currentDateString())'"
        foodManager.diaryType = .foodDiaryAndDetail
        let foodDetail = foodManager.getFoodDetails(.diaryData, amount: nil, weight: nil, cond: cond, order: nil)
        var calorieSum:Double = 0
        for food in foodDetail{
            
            calorieSum += food.calorie
            
        }
        return calorieSum
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.frame.height-50), animated: true)
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == embraveDefault{
            textView.text = ""
        }
        
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty{
            textView.text = embraveDefault
        }
    }
    
    
    //range 即將被取代文字  text將輸入的文字
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let countOfWords = text.characters.count + textView.text.characters.count - range.length
        
    
        if countOfWords > 120{
            
            profileManager.setUserEmbrave(textView.text)

            return false
            
        }
        
        rangeTextLabel.text = "\(countOfWords)/120"
        
        return true
    }
}
