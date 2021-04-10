//
//  SearchViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/26.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet var searchTableView: UITableView!
    var timeInterval = ""
    let foodmaster = foodMaster.standard

    var searchArray = foodMaster(foodDetailCondition: nil).getFoodDetails(detailType: .defaultData, amount: nil, weight: nil, order: nil) {
        didSet {
            searchTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        foodmaster.foodDiaryArrary = []
        foodmaster.switchIsOn = []

        navigationItem.title = "搜尋食物"
        let plusSum = UIBarButtonItem(title: "加入", style: .done, target: self, action: #selector(plusFoodDiary))

        navigationItem.rightBarButtonItems = [plusSum]

        let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
        searchTableView.register(nib, forCellReuseIdentifier: "searchCell")
    }

    override func viewWillAppear(_: Bool) {
        searchTableView.reloadData()
        setPlusSum()
    }

    func setPlusSum() {
        navigationItem.rightBarButtonItems?[0].title = "加入(\(foodmaster.switchIsOn.count))"
    }

    func plusFoodDiary() {
        for diary in foodmaster.foodDiaryArrary {
            foodmaster.insertDiary(rowInfo: [
                "date": "'\(diary.date)'",
                "time_interval": "'\(diary.timeInterval)'",
                "food_id": "\(diary.foodId)",
                "amount": "\(diary.amount)",
                "weight": "\(diary.weight)",
            ])
        }

        navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return searchArray.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchCell = searchTableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchTableViewCell

        let foodDetails = searchArray[indexPath.row]

        searchCell.titleLabel.text = foodDetails.sampleName
        searchCell.switchButton.addTarget(self, action: #selector(switchStats), for: .touchUpInside)
        searchCell.id = searchArray[indexPath.row].foodDetailId
        searchCell.bodyLabel.text = "1份(\(foodDetails.weight)克)"

        if foodmaster.switchIsOn.contains(searchArray[indexPath.row].foodDetailId) {
            searchCell.switchButton.isSelected = true

        } else {
            searchCell.switchButton.isSelected = false
        }

        return searchCell
    }

    func switchStats(sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: searchTableView)

        guard let indexPath = searchTableView.indexPathForRow(at: point) else {
            return
        }

        let cell = searchTableView.cellForRow(at: indexPath) as! SearchTableViewCell

        guard let cellFoodId = cell.id else {
            return
        }

        let food = foodDiary(timeInterval: timeInterval,
                             amount: searchArray[indexPath.row].amount,
                             weight: searchArray[indexPath.row].weight,
                             foodId: cellFoodId)

        if !sender.isSelected {
            foodmaster.switchIsOn.append(cellFoodId)
            foodmaster.foodDiaryArrary.append(food)

            sender.isSelected = true

            setPlusSum()

        } else {
            let index = foodmaster.switchIsOn.index(of: cellFoodId)
            foodmaster.switchIsOn.remove(at: index!)
            for (index, value) in foodMaster.standard.foodDiaryArrary.enumerated() {
                if value.foodId == cell.id {
                    foodmaster.foodDiaryArrary.remove(at: index)
                }
            }
            sender.isSelected = false
            setPlusSum()
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }
        searchBar.resignFirstResponder()
        searchArray = foodMaster(diaryType: "foodDetail", condition: "sample_name like'%" + searchText + "%'").getFoodDetails(detailType: .defaultData, amount: nil, weight: nil, order: nil)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchArray = foodMaster(foodDetailCondition: nil).getFoodDetails(detailType: .defaultData, amount: nil, weight: nil, order: nil)
    }

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchArray = foodMaster(foodDetailCondition: nil).getFoodDetails(detailType: .defaultData, amount: nil, weight: nil, order: nil)
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "FoodDetailViewController") as! FoodDetailViewController
        nextPage.foodId = searchArray[indexPath.row].foodDetailId
        nextPage.timeInterval = timeInterval
        nextPage.viewController = "SearchViewController"

        navigationController?.pushViewController(nextPage, animated: true)
    }
}
