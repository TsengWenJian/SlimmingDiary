//
//  FoodDetailViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class FoodDetailViewController: UIViewController {
    @IBOutlet var collectBtn: UIButton!

    var actionType: ActionType = .insert
    var foodTitles = [String]()
    var foodDatas = [String]()
    var foodUnits = [String]()
    var foodDiaryId: Int = 0
    var foodId: Int?
    var dinnerTime: String?
    var pickVC = PickerViewController.shared

    var correntRow: Int = 0
    var selectImage: UIImage? {
        didSet { foodDetailsTableView.reloadData() }
    }

    let foodMaster = FoodMaster.standard

    @IBOutlet var foodDetailsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        foodDatas = foodMaster.getFoodDataArray(actionType,
                                                foodDiaryId: foodDiaryId,
                                                foodId: foodId,
                                                amount: nil,
                                                weight: nil)

        foodTitles = foodMaster.foodDetailTitles
        foodUnits = foodMaster.foodDetailUnits

        if foodMaster.isCollection == 1 {
            collectBtn.isSelected = true
        }

        selectImage = foodMaster.foodDetailImage

        navigationItem.title = "食物資料"

        let save = UIBarButtonItem(title: actionType.rawValue, style: .done, target: self, action: #selector(saveFood))
        navigationItem.rightBarButtonItems = [save]

        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        foodDetailsTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")

        pickVC.delegate = self
        pickVC.numberOfRows = 0
        pickVC.numberOfComponents = 0
        pickVC.selectRowOfbegin = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func saveFood() {
        if actionType == ActionType.insert {
            guard let myAmount = Double(foodDatas[1]),
                  let myWeight = Double(foodDatas[2]),
                  let myFoodId = foodId,
                  let myDinnerTime = dinnerTime
            else {
                return
            }

            var diary = foodDiary(dinnerTime: myDinnerTime,
                                  amount: myAmount,
                                  weight: myWeight,
                                  foodId: myFoodId)

            diary.image = selectImage

            if let index = foodMaster.switchIsOnIDs.index(of: myFoodId) {
                foodMaster.switchIsOnIDs.remove(at: index)
                foodMaster.foodDiarys.remove(at: index)
            }

            foodMaster.switchIsOnIDs.append(myFoodId)
            foodMaster.foodDiarys.append(diary)

        } else {
            let cond = "\(FOODDIARY_ID)=\(foodDiaryId)"
            var dict = [String: String]()

            dict = ["\(FOODDIARY_AMOUNT)": "\(foodDatas[1])",
                    "\(FOODDIARY_WEIGHT)": "\(foodDatas[2])"]

            if let image = selectImage {
                let selectImageHash = "food_\(image.hash)"
                dict[FOODDIARY_IMAGENAME] = "'\(selectImageHash)'"
                image.writeToFile(imageName: selectImageHash, search: .documentDirectory)
            }

            foodMaster.diaryType = .foodDiary
            foodMaster.updataDiary(cond: cond, rowInfo: dict)
        }

        navigationController?.popViewController(animated: true)
    }

    @IBAction func collectBtnAction(_: Any) {
        var iscollect: Int
        foodMaster.diaryType = .foodDetail
        if collectBtn.isSelected {
            iscollect = 0
            collectBtn.isSelected = false

        } else {
            iscollect = 1
            collectBtn.isSelected = true
        }

        foodMaster.updataDiary(cond: "\(FOODDETAIL_Id) =\(foodId!) ",
                               rowInfo: ["\(FOODDETAIL_COLLECTION)": "'\(iscollect)'"])
    }

    func launchImagePickerWithSourceType(type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) == false {
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.delegate = self

        if type == .camera {
            picker.mediaTypes = ["public.image"]

        } else {
            picker.allowsEditing = true
        }
        present(picker, animated: true, completion: nil)
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let alertVC = UIAlertController(title: "選擇照片", message: "", preferredStyle: .actionSheet)

            let camera = UIAlertAction(title: "拍照", style: .default, handler: { _ in
                self.launchImagePickerWithSourceType(type: .camera)
            })

            let library = UIAlertAction(title: "相簿", style: .default, handler: { _ in
                self.launchImagePickerWithSourceType(type: .photoLibrary)
            })

            let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)

            alertVC.addAction(camera)
            alertVC.addAction(library)
            alertVC.addAction(cancel)
            present(alertVC, animated: true, completion: nil)

        } else if indexPath.section == 1 {
            correntRow = indexPath.row

            if indexPath.row < 2 {
                if indexPath.row == 0 {
                    pickVC.numberOfRows = 30
                    pickVC.numberOfComponents = 2

                } else {
                    pickVC.numberOfRows = 2000
                    pickVC.numberOfComponents = 1
                }

                if let baginValue = Double(foodDatas[indexPath.row + 1]) {
                    pickVC.selectRowOfbegin = baginValue
                }

                pickVC.displayDialog(present: self)
            }
        }
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource

extension FoodDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderTableViewCell
        headerCell.contentView.layer.cornerRadius = 0
        headerCell.rightLabel.text = ""

        if section == 1 {
            headerCell.titleLabel.text = dinnerTime
            headerCell.totalCalorieLebel.text = foodDatas[0]
            return headerCell

        } else if section == 2 {
            headerCell.titleLabel.text = "營養標示"
            return headerCell
        }

        return nil
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1
        }
        return 44
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180
        }

        if indexPath.row == 2, indexPath.section == 1 {
            return 180
        }
        return 44
    }

    func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1
        }
        return 20
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 3
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1

        } else if section == 1 {
            return 3

        } else {
            return foodTitles.count - 3
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailImageTableViewCell", for: indexPath) as! DetailImageTableViewCell

            if selectImage != nil {
                cell.selectImageView.image = selectImage
            }

            return cell

        } else if indexPath.section == 1 {
            if indexPath.row <= 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! FoodDetailTableViewCell
                cell.title.text = foodTitles[indexPath.row + 1]
                cell.dataLabel.text = foodDatas[indexPath.row + 1]
                cell.unit.text = foodUnits[indexPath.row + 1]

                return cell

            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailProgressCell") as! DetailProgressCell

                var total = foodMaster.total

                if total.isNaN {
                    total = 1
                }

                if let protein = Double(foodDatas[4]),
                   let fat = Double(foodDatas[5]),
                   let carbohydrates = Double(foodDatas[8])
                {
                    let pro = myProgress(progess: ceil((protein / total) * 100), color: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1))
                    let pro2 = myProgress(progess: ceil((fat / total) * 100), color: #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1))
                    let pro3 = myProgress(progess: ceil((carbohydrates / total) * 100), color: #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1))

                    cell.circleProgressRate.setTitleLabelText(text: foodDatas[3], size: 25)
                    cell.circleProgressRate.setSubTitleLabelText(text: "kcal", size: 18)
                    cell.circleProgressRate.setProgress(pros: [pro, pro2, pro3])

                    cell.proteinLabel.text = "蛋白質 " + calProportion(value: protein) + "%"
                    cell.fatLabel.text = "脂肪 " + calProportion(value: fat) + "%"
                    cell.carbohydrateLabel.text = "碳水化合物 " + calProportion(value: carbohydrates) + "%"
                }
                return cell
            }

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rightDetailCell")
            var data = foodDatas[indexPath.row + 3]

            if data == "0.0" {
                data = "-"
            }
            cell?.detailTextLabel?.text = data + foodUnits[indexPath.row + 3]
            cell?.textLabel?.text = foodTitles[indexPath.row + 3]

            return cell!
        }
    }

    func calProportion(value: Double) -> String {
        let total = foodMaster.total
        let dataStr = String(format: "%.0f", round((value / total) * 100))
        return dataStr == "nan" ?"0" : dataStr
    }
}

extension FoodDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        selectImage = UIImage()

        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectImage = photo
        }
        if let myImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectImage = myImage
        }

        selectImage = selectImage?.resizeImage(maxLength: 1024)

        dismiss(animated: true, completion: nil)
    }
}

// MARK: - PickerViewDelegate

extension FoodDetailViewController: PickerViewDelegate {
    func getSelectRow(data: Double) {
        if correntRow == 0 {
            foodDatas[1] = "\(data)"

        } else {
            foodDatas[2] = "\(data)"
        }

        guard let amount = Double(foodDatas[1]),
              let weight = Double(foodDatas[2])
        else {
            return
        }

        foodDatas = foodMaster.getFoodDataArray(actionType,
                                                foodDiaryId: foodDiaryId,
                                                foodId: foodId,
                                                amount: amount,
                                                weight: weight)
        foodDetailsTableView.reloadData()
    }
}
