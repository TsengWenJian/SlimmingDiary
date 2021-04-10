//
//  AddWeightViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/17.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class AddWeightViewController: UIViewController {
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var addPhotoTableView: UITableView!

    var type = WeightDiaryType.weight

    var detailArray = ["體重", "加入"] {
        didSet {
            addPhotoTableView.reloadData()
        }
    }

    var titleArray = ["體重", "進展照片"]
    var selectImage: UIImage?
    var weight: Double = 0
    var actionType: ActionType = .insert
    var weightId: Int?

    let profileManager = ProfileManager.standard
    let weightMaster = WeightMaster.standard
    let pickerVC = PickerViewController.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        titleArray[0] = type.rawValue
        detailArray[0] = "\(weight)"
        pickerVC.delegate = self
        pickerVC.numberOfRows = 300
        pickerVC.numberOfComponents = 2
        pickerVC.selectRowOfbegin = 1.0
    }

    // MARK: - Function

    @objc func cancelAction(sender _: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc func confirmAction(sender _: UIButton) {
        var imageName: String?

        if let myImage = selectImage {
            let hashString = "WeightProgress_\(myImage.hash)"
            myImage.writeToFile(imageName: hashString, search: .documentDirectory)
            imageName = hashString
        }

        weightMaster.diaryType = .weightDiary

        if actionType == .update {
            if let id = weightId {
                let cond = "\(WEIGHTDIARY_ID) = '\(id)'"

                weightMaster.updataDiary(cond: cond,
                                         rowInfo: [WEIGHTDIARY_PHOTO: "'\(imageName ?? "No_Image")'",
                                                   WEIGHTDIARY_VALUE: "'\(weight)'"])
            }

        } else {
            let calender = CalenderManager.standard

            if calender.displayDateString() == calender.currentDateString() || calender.isAfterCurrentDay(date: calender.displayDate) {
                if titleArray[0] == "體重" {
                    profileManager.setUserWeight(weight)
                }
            }

            let diary = WeightDiary(id: nil,
                                    date: calender.displayDateString(),
                                    time: calender.getCurrentTime(),
                                    type: titleArray[0],
                                    value: weight,
                                    imageName: imageName)

            weightMaster.insertWeightDiary(diary)
        }

        dismiss(animated: true, completion: nil)
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
}

// MARK: - UIImagePickerControllerDelegate,UINavigationControllerDelegate

extension AddWeightViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectImage = photo
        }
        if let myImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectImage = myImage
        }
        selectImage = selectImage?.resizeImage(maxLength: 1024)
        photoImageView.image = selectImage
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource

extension AddWeightViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "AddWeightHeaderTableViewCell") as! AddWeightHeaderTableViewCell

        var title: String
        title = actionType == .insert ? "新增紀錄" : "修改記錄"
        headerCell.TitleLabel.text = title
        headerCell.cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        headerCell.confirmBtn.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)

        return headerCell.contentView
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return detailArray.count
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let detail = Double(detailArray[0]) {
                pickerVC.selectRowOfbegin = detail
            }

            pickerVC.displayDialog(present: self)
        }

        if indexPath.row == 1 {
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
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
        cell.textLabel?.text = titleArray[indexPath.row]
        cell.detailTextLabel?.text = detailArray[indexPath.row]

        return cell
    }
}

extension AddWeightViewController: PickerViewDelegate {
    func getSelectRow(data: Double) {
        weight = data
        detailArray[0] = "\(data)"
    }
}
