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
    let foodManager = foodMaster.standard
    let textView = UITextView()
    let rangeTextLabel = UILabel()
    let placeholderLabel = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let offsety:CGFloat = 150+64
        scrollView.contentSize = CGSize(width:view.frame.width,height:offsety*2-50)
        
        
        let shadowView = UIView()
        shadowView.frame = CGRect(x:0,y:offsety-50,width:view.frame.width,height:offsety)
        shadowView.backgroundColor = UIColor.black
        shadowView.alpha = 0.7
        
        textView.delegate = self
        
        
        
        
        let embraveText = profileManager.userEmbraveText
        
        if embraveText == nil || (embraveText?.isEmpty)! {
            
            
            placeholderLabel.text = "請輸入激勵語..."
            
        }else{
            
            textView.text = embraveText
            
            
        }
        
        
        
        placeholderLabel.frame.origin = CGPoint(x: 15, y:offsety-35)
        placeholderLabel.font = UIFont.systemFont(ofSize: 18)
        placeholderLabel.sizeToFit()
        placeholderLabel.textColor = UIColor.white
        
        
        textView.frame = CGRect(x: 10, y:offsety-45,
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
        scrollView.addSubview(placeholderLabel)
        
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x:0,
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
        
        
        basicCalorieLabel.text = "\(basic)"
        foodCalorieLabel.text = "\(food)"
        resultCalorieLabel.text = "\(basic - food)"
        
    }

    
    
    
    func doneBtnAction() {
        textView.resignFirstResponder()
        profileManager.setUserEmbrave(textView.text)
        
        
    }
    
    
    
    
    
    
    func getTodayFoodCalorie()->Double{
        
        let cond = "foodDiary.food_id=foodDetails_id and date = '\(CalenderManager.standard.dateToString(Date()))'"
        foodManager.diaryType = .foodDiaryAndDetail
        let foodDetail = foodManager.getFoodDetails(.diaryDate, amount: nil, weight: nil, cond: cond, order: nil)
        var calorieSum:Double = 0
        for food in foodDetail{
            
            calorieSum += food.calorie
            
        }
        
        return calorieSum
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.frame.height-50), animated: true)
        return true
    }
    
    
    //range 即將被取代文字  text將輸入的文字
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let countOfWords = text.characters.count + textView.text.characters.count - range.length
        
        
        
          
        if countOfWords > 0{
            
            placeholderLabel.isHidden = true
            
        }else{
            
            placeholderLabel.isHidden = false
            
        }
        
        if countOfWords > 120{
            
            profileManager.setUserEmbrave(textView.text)

            return false
            
            
        }
        
        
        
        rangeTextLabel.text = "\(countOfWords)/120"
        

        return true
    }

    
    
}
