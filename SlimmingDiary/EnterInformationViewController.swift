//
//  EnterInformationViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/8.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class EnterInformationViewController: UIViewController {
    @IBOutlet var genderBtn: UIButton!
    @IBOutlet var weightBtn: UIButton!
    @IBOutlet var heightBtn: UIButton!
    @IBOutlet var birthdayBtn: UIButton!
    @IBOutlet var targetBtn: UIButton!
    @IBOutlet var containerBtnView: [UIView]!

    @IBOutlet var weightProgress: NickProgress2UIView!
    let profileManager = ProfileManager.standard
    let bodyManager = BodyInformationManager.standard
    var datePickerVC: DatePickerViewController?
    let pickerVC = PickerViewController.shared

    var gender: Int? {
        didSet {
            if let myGender = gender {
                genderBtn.setTitle(profileManager.genders[myGender], for: .normal)
            }
        }
    }

    var height: Double?
    var weight: Double?
    var birthday: String?
    var targetWeight: Double?
    var lifeStyle: Int? = 0
    var currentTouchBtn: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        weightProgress.setSubTitleText(text: "--")
        datePickerVC = storyboard?.instantiateViewController(withIdentifier: "DatePickerViewController") as? DatePickerViewController
        datePickerVC?.delegate = self
        pickerVC.delegate = self
        pickerVC.numberOfRows = 0
        pickerVC.numberOfComponents = 2
        pickerVC.selectRowOfbegin = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func goToHomePage() {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "FirstPage") {
            UIApplication.shared.keyWindow?.rootViewController = viewController
            dismiss(animated: false, completion: nil)
        }
    }

    @IBAction func inputDoneAction(_: Any) {
        if let myLifeStyle = lifeStyle,
           let myHeight = height,
           let myWeight = weight,
           let myBirthby = birthday,
           let myGender = gender,
           let myTargetWeight = targetWeight
        {
            profileManager.setUserGender(myGender)
            profileManager.setUserHeight(myHeight)
            profileManager.setUserWeight(myWeight)
            profileManager.setUserlifeStyle(myLifeStyle)
            profileManager.setUserTargetWeight(myTargetWeight)
            profileManager.setUserOriginWeight(myWeight)
            profileManager.setUserBirthday(myBirthby)
            profileManager.setTargetStep(10000)
            profileManager.setUserIsInputDone(true)

            let calManager = CalenderManager.standard
            WeightMaster.standard.diaryType = .weightDiary

            // insert first weight to  WeightDiary table
            let addRecord = WeightDiary(id: nil,
                                        date: calManager.currentDateString(),
                                        time: calManager.getCurrentTime(),
                                        type: "體重",
                                        value: myWeight,
                                        imageName: nil)

            WeightMaster.standard.insertWeightDiary(addRecord)

            goToHomePage()

            return
        }

        let alert = UIAlertController(error: "請填寫完整哦")
        present(alert, animated: true, completion: nil)
    }

    @IBAction func inputDataBtnAction(_ sender: UIButton) {
        let btn = sender.tag - 100
        currentTouchBtn = btn

        switch btn {
        case 0:
            pickerVC.numberOfRows = 200

            if let mytarget = targetWeight {
                pickerVC.selectRowOfbegin = mytarget
            } else {
                pickerVC.selectRowOfbegin = 60
            }

            pickerVC.displayDialog(present: self)

        case 1:
            let alert = UIAlertController(title: "請選擇性別", message: "", preferredStyle: .actionSheet)

            let boy = UIAlertAction(title: profileManager.genders[0], style: .default, handler: { _ in
                self.gender = 0
                self.setWeightProgressData()
            })

            let girl = UIAlertAction(title: profileManager.genders[1], style: .default, handler: { _ in
                self.gender = 1
                self.setWeightProgressData()
            })

            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)

            alert.addAction(boy)
            alert.addAction(girl)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)

        case 2:

            datePickerVC?.displayPickViewDialog(present: self)
        case 3:

            pickerVC.numberOfRows = 300

            if let myHeight = height {
                pickerVC.selectRowOfbegin = myHeight
            } else {
                pickerVC.selectRowOfbegin = 160
            }

            pickerVC.displayDialog(present: self)

        case 4:

            pickerVC.numberOfRows = 200
            if let myWeight = weight {
                pickerVC.selectRowOfbegin = myWeight
            } else {
                pickerVC.selectRowOfbegin = 60
            }

            pickerVC.displayDialog(present: self)
        default:

            break
        }
    }
}

// MARK: - DatePickerDelegate

extension EnterInformationViewController: DatePickerDelegate {
    func getSelectDate(date: Date) {
        let dateString = CalenderManager.standard.dateToString(date)
        birthdayBtn.setTitle(dateString, for: .normal)
        birthday = dateString
    }
}

extension EnterInformationViewController: PickerViewDelegate {
    func getSelectRow(data: Double) {
        let selectData = String(format: "%0.1f", data)

        switch currentTouchBtn {
        case 0:

            targetWeight = data
            targetBtn.setTitle("目標體重:\(selectData)", for: .normal)
        case 3:

            height = data
            heightBtn.setTitle(selectData, for: .normal)
        case 4:

            weight = data
            weightBtn.setTitle(selectData, for: .normal)

        default:
            break
        }
        setWeightProgressData()
    }

    func setWeightProgressData() {
        guard let calHeight = height,
              let calWeight = weight,
              let calGender = gender
        else {
            return
        }

        bodyManager.setBodyData(calHeight, calWeight, calGender)
        let bmi = String(format: "%0.1f", bodyManager.getBmi())

        weightProgress.setTitleText(text: bodyManager.getWeightType().rawValue)
        weightProgress.setTitleColor(bodyManager.getWeightTypeColor())
        weightProgress.setDetailText(text: "理想體重:\(bodyManager.getIdealWeight())kg")
        weightProgress.setSubTitleText(text: "BMI:\(bmi)")
        weightProgress.resetProgress(progress: bodyManager.getBmi())
    }
}

// MARK: - UIPickerViewDelegate,UIPickerViewDataSource

extension EnterInformationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return profileManager.liftStyles.count
    }

    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return profileManager.liftStyles[row]
    }

    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        lifeStyle = row
    }
}
