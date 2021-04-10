//
//  AddSportTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/6.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class AddSportTableViewController: UITableViewController {
    let titleArray = ["名稱", "多久(分鐘)", "消耗卡路里"]
    var detailArray = ["", "", ""]
    var currentTouchRow = 0
    var sportName: String?
    let pickVC = PickerViewController.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        let insertItem = UIBarButtonItem(title: "加入", style: .done, target: self, action: #selector(addSport))
        navigationItem.rightBarButtonItems = [insertItem]

        navigationItem.title = "新運動"
        pickVC.delegate = self
        pickVC.numberOfRows = 2000
        pickVC.numberOfComponents = 2
        pickVC.selectRowOfbegin = 0
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        view.endEditing(true)
    }

    @objc func addSport() {
        var isWriteDone: Bool = true

        for detail in detailArray {
            if detail.isEmpty || sportName == nil {
                isWriteDone = false
                break
            }
        }

        if isWriteDone {
            let master = SportMaster.standard

            guard let cal = Double(detailArray[2]),
                  let minute = Double(detailArray[1])
            else {
                return
            }
            let emts = cal * (60 / minute) / ProfileManager.standard.userWeight
            master.diaryType = .sportDetail
            master.insertDiary(rowInfo: [SPORTDETAIL_CLASSIFICATION: "'自訂'",
                                         SPORTDETAIL_SAMPLENAME: "'\(detailArray[0])'",
                                         SPORTDETAIL_EMTS: "'\(emts.roundTo(places: 1))'"])

            navigationController?.popViewController(animated: true)

            return
        }

        let alert = UIAlertController(error: "請填寫完整哦")
        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titleArray.count
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTouchRow = indexPath.row

        if indexPath.row == 0 {
            return
        }

        if indexPath.row == 1 {
            pickVC.selectRowOfbegin = 30
            pickVC.numberOfComponents = 1

        } else if indexPath.row == 2 {
            pickVC.numberOfComponents = 2
            pickVC.selectRowOfbegin = 200
        }

        PickerViewController.shared.displayDialog(present: self)
        view.endEditing(true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! AddTextFieldTableViewCell

            cell.titleLabel.text = titleArray[indexPath.row]
            cell.rightTextField.addTarget(self, action: #selector(textChange(_:)), for: .editingChanged)

            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            cell.textLabel?.text = titleArray[indexPath.row]
            cell.detailTextLabel?.text = detailArray[indexPath.row] == "" ?"必填" : detailArray[indexPath.row]
            return cell
        }
    }

    @objc func textChange(_ sender: UITextField) {
        sportName = sender.text

        if let text = sender.text {
            detailArray[0] = text
        }
    }
}

// MARK: - PickerViewDelegate

extension AddSportTableViewController: PickerViewDelegate {
    func getSelectRow(data: Double) {
        if currentTouchRow == 1 {
            detailArray[currentTouchRow] = "\(Int(data))"
        } else {
            detailArray[currentTouchRow] = String(format: "%.1f", data)
        }

        tableView.reloadData()
    }
}
