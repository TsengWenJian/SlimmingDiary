//
//  EnterInformationViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/8.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class EnterInformationViewController: UIViewController {
    
    
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var weightBtn: UIButton!
    @IBOutlet weak var heightBtn: UIButton!
    @IBOutlet weak var birthdayBtn: UIButton!
    @IBOutlet weak var targetBtn: UIButton!
    @IBOutlet var containerBtnView: [UIView]!
    
    
    @IBOutlet weak var weightProgress: NickProgress2UIView!
    let manager = ProfileManager.standard
    let bodyManager = BodyInformationManager.standard
    var datePickerVC:DatePickerViewController?
    
    
    
    var numberOfRows:Int = 0
    var numberOfComponents:Int = 2
    var setSelectRowOfbegin:Double = 1.0
    
    var gender:Int?{
        didSet{
            if let myGender = gender{
                self.genderBtn.setTitle(manager.genderArray[myGender],for: .normal)
            }
        }
    }
    
    var height:Double?
    var weight:Double?
    var birthday:String?
    var targetWeight:Double?
    var lifeStyle:Int? = 0
    var currentTouchBtn:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        weightProgress.setSubTitleText(text: "--")
        datePickerVC = storyboard?.instantiateViewController(withIdentifier: "DatePickerViewController") as? DatePickerViewController
        datePickerVC?.delegate = self
        PickerViewController.shared.delegate = self
        
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func goToHomePage(){
        
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "FirstPage") {
            
            UIApplication.shared.keyWindow?.rootViewController = viewController
            self.dismiss(animated: false, completion: nil)
            
        }
        
    }
    
    
    
    
    
    @IBAction func inputDoneAction(_ sender: Any) {
        
        
        if  let myLifeStyle = lifeStyle,
            let myHeight = height,
            let myWeight = weight,
            let myBirthby = birthday ,
            let myGender = gender,
            let myTargetWeight = targetWeight{
            
            manager.setUserGender(myGender)
            manager.setUserHeight(myHeight)
            manager.setUserWeight(myWeight)
            manager.setUserlifeStyle(myLifeStyle)
            manager.setUserTargetWeight(myTargetWeight)
            manager.setUserOriginWeight(myWeight)
            manager.setUserBirthday(myBirthby)
            manager.setTargetStep(10000)
            manager.setUserIsInputDone(true)
            
            
            let calManager = CalenderManager.standard
            WeightMaster.standard.diaryType = .weightDiary
            
            // insert first weight to  WeightDiary table
            let addRecord = WeightDiary(id:nil,
                                        date:calManager.currentDateString(),
                                        time:calManager.getCurrentTime(),
                                        type:"體重",
                                        value:myWeight,
                                        imageName: nil)
            
            WeightMaster.standard.insertWeightDiary(addRecord)
            
            
            goToHomePage()
            
            return
            
        }
        
        
        let alert = UIAlertController(error:"請填寫完整哦")
        present(alert, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func inputDataBtnAction(_ sender: UIButton) {
        
        let btn = sender.tag-100
        currentTouchBtn = btn
        
        switch btn {
            
        case 0:
            numberOfRows = 200
            
            if let mytarget = targetWeight{
                setSelectRowOfbegin = mytarget
            }else{
                
                setSelectRowOfbegin = 60
            }
            
            PickerViewController.shared.displayDialog(present: self)
            
        case 1:
            let alert = UIAlertController(title: "請選擇性別", message:"", preferredStyle:.actionSheet)
            
            let boy = UIAlertAction(title:manager.genderArray[0], style: .default, handler: { (UIAlertAction) in
                self.gender = 0
                self.setWeightProgressData()
            })
            
            
            let  girl = UIAlertAction(title:manager.genderArray[1], style: .default, handler: { (UIAlertAction) in
                self.gender = 1
                self.setWeightProgressData()
            })
            
            let  cancel = UIAlertAction(title:"取消", style:.cancel, handler:nil)
            
            
            alert.addAction(boy)
            alert.addAction(girl)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
            
            
            break
        case 2:
            
            
            datePickerVC?.displayPickViewDialog(present: self)
            break
        case 3:
            
            numberOfRows = 300
            
            if let myHeight = height{
                
                
                setSelectRowOfbegin = myHeight
            }else{
                setSelectRowOfbegin = 160
                
            }
            
          PickerViewController.shared.displayDialog(present: self)
            
            break
        case 4:
            
            numberOfRows = 200
            if let myWeight = weight{
                setSelectRowOfbegin = myWeight
            }else{
                setSelectRowOfbegin = 60
                
            }
            
           PickerViewController.shared.displayDialog(present: self)
            break
        default:
            
            break
        }
        
        
        
    }
    
    
}
//MARK: - DatePickerDelegate
extension EnterInformationViewController:DatePickerDelegate{
    func getSelectDate(date: Date) {
        
        let dateString =   CalenderManager.standard.dateToString(date)
        birthdayBtn.setTitle(dateString,for: .normal)
        birthday = dateString
    }
}

extension EnterInformationViewController:PickerViewDelegate{
    
    func getSelectRow(data:Double){
        
        let  selectData = String(format:"%0.1f",data)
        
        switch currentTouchBtn {
        case 0:
            
            targetWeight = data
            targetBtn.setTitle("目標體重:\(selectData)",for: .normal)
        case 3:
            
            height = data
            heightBtn.setTitle(selectData,for: .normal)
        case 4:
            
            weight = data
            weightBtn.setTitle(selectData,for: .normal)
            
        default:
            break
        }
        setWeightProgressData()
        
    }
    
    
    
    func setWeightProgressData(){
        
        
        
        guard let calHeight = height,
            let calWeight = weight,
            let calGender = gender else{
                return
        }
        
        bodyManager.setBodyData(calHeight,calWeight,calGender)
        let bmi  = String(format:"%0.1f",bodyManager.getBmi())
        
        weightProgress.setTitleText(text:bodyManager.getWeightType().rawValue)
        weightProgress.setTitleColor(bodyManager.getWeightTypeColor())
        weightProgress.setDetailText(text:"理想體重:\(bodyManager.getIdealWeight())kg")
        weightProgress.setSubTitleText(text:"BMI:\(bmi)")
        weightProgress.resetProgress(progress:bodyManager.getBmi())
        
        
    }
    
}

//MARK: - UIPickerViewDelegate,UIPickerViewDataSource
extension EnterInformationViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        return manager.liftStyleArray.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return manager.liftStyleArray[row]
        
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        lifeStyle = row
        
        
    }
}



