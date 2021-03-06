//
//  SpotsDiaryTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/11.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class SpotsDiaryViewController: UIViewController {
    @IBOutlet var spotsDiaryTableView: UITableView!

    var isExpanded: Bool = false
    var sportItems = [sportDetail]() {
        didSet { spotsDiaryTableView.reloadData() }
    }

    let sportMaster = SportMaster.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        spotsDiaryTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")

        let nibBody = UINib(nibName: "BodyTableViewCell", bundle: nil)
        spotsDiaryTableView.register(nibBody, forCellReuseIdentifier: "Cell")

        let nibFooter = UINib(nibName: "FooterTableViewCell", bundle: nil)
        spotsDiaryTableView.register(nibFooter, forCellReuseIdentifier: "footerCell")

        NotificationCenter.default.addObserver(self, selector: #selector(refreshSectionArray), name: NSNotification.Name(rawValue: "changeDiaryData"), object: nil)
    }

    @objc func refreshSectionArray() {
        if (parent?.parent as? MainDiaryViewController)?.currentPage != 1 {
            return
        }

        sportItems.removeAll()

        let displayDate = CalenderManager.standard.displayDateString()

        sportMaster.diaryType = .sportDiaryAndDetail
        let cond = "Sport_Diary.\(SPORTYDIARY_DETAILID)=\(SPORTDETAIL_ID) and \(SPORTYDIARY_DATE) = '\(displayDate)'"

        let items = sportMaster.getSportDetails(.diaryData, minute: nil, cond: cond, order: nil)
        sportItems = items
    }

    @objc func sectionIsExpend(sender _: UIButton) {
        isExpanded = !isExpanded
        spotsDiaryTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }

    @objc func plusSport(sender _: UIButton) {
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "ChoiceFoodViewController") as! ChoiceFoodViewController
        nextPage.diaryType = .sport
        navigationController?.pushViewController(nextPage, animated: true)
    }

    override func viewWillAppear(_: Bool) {
        refreshSectionArray()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource

extension SpotsDiaryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return isExpanded == true ?sportItems.count : 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BodyTableViewCell

        let item = sportItems[indexPath.row]
        cell.titleLabel.text = item.sampleName
        cell.bodyLabel.text = "\(item.minute)分"
        cell.rightLabel.text = "\(Int(item.calories))"

        let image = item.imageName == nil ? UIImage(named: "sport") : UIImage(imageName: item.imageName,
                                                                              search: .documentDirectory)
        cell.leftImageView.image = image

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderTableViewCell
        headerCell.titleLabel.text = "運動"

        headerCell.totalCalorieLebel.text = {
            var calorieSum: Double = 0

            for item in sportItems {
                calorieSum += item.calories
            }
            return calorieSum == 0.0 ?"" : "\(Int(calorieSum)) 大卡"
        }()

        headerCell.expendBtn.addTarget(self, action: #selector(sectionIsExpend), for: .touchUpInside)

        return headerCell.contentView
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 44
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection _: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableCell(withIdentifier: "footerCell") as! FooterTableViewCell
        footerCell.titleLabel.text = sportItems.count == 0 ?"尚未添加運動" : "\(sportItems.count) 項"
        footerCell.footerButton.addTarget(self, action: #selector(plusSport(sender:)), for: .touchUpInside)

        return footerCell.contentView
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        return 60
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "SportDetailViewController") as! SportDetailViewController
        nextPage.detail = sportItems[indexPath.row]
        nextPage.actionType = .update
        navigationController?.pushViewController(nextPage, animated: true)
    }

    func tableView(_: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let rowItem = sportItems[indexPath.row]
            let cond = "\(SPORTYDIARY_ID) = \(rowItem.diaryId)"
            sportMaster.diaryType = .sportDiary
            sportMaster.deleteDiary(cond: cond)
            sportMaster.deleteImage(imageName: rowItem.imageName)
            sportItems.remove(at: indexPath.row)
        }
    }
}
