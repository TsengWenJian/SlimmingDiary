//
//  ChoiceFoodViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/19.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ChoiceFoodViewController: UIViewController {
    @IBOutlet var btnViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewButtomConstraint: NSLayoutConstraint!
    @IBOutlet var sliderViewLeading: NSLayoutConstraint!

    @IBOutlet var containBtnView: UIView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var addCustomBtn: UIButton!
    @IBOutlet var choiceFoodTableView: UITableView!
    @IBOutlet var recentlyButton: UIButton!
    @IBOutlet var commonButton: UIButton!
    @IBOutlet var buttonSliderView: UIView!
    @IBOutlet var customBotton: UIButton!
    @IBOutlet var searchBar: UISearchBar!

    var sumLabel = UILabel()
    var defaultRowInSection = 1

    // when actionType is update use
    typealias selectDone = (Bool) -> Void
    var selectItemsDone: selectDone?

    var actionType: ActionType?
    var diaryType: DiaryImageType = .food
    var dinnerTime: String?

    var foodItems = [foodDetails]() {
        didSet { choiceFoodTableView.reloadData() }
    }

    var sportItems = [sportDetail]() {
        didSet { choiceFoodTableView.reloadData() }
    }

    var currentBtn: Int = 0 {
        didSet {
            currentBtnChanged(currentBtn)
        }
    }

    var lastPage = 0
    var isSerached: Bool = false
    let foodMaster = FoodMaster.standard
    let sportMaster = SportMaster.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        let diaryTypeStr = diaryType == .food ? "食物" : "運動"
        navigationItem.title = "搜尋\(diaryTypeStr)"
        searchBar.placeholder = "請輸入\(diaryTypeStr)名稱"

        let plusSum = UIBarButtonItem(title: "加入", style: .done, target: self, action: #selector(insertDiary))

        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        customView.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        let sum = UIBarButtonItem(customView: customView)
        navigationItem.rightBarButtonItems = [sum, plusSum]
        sumLabel.textAlignment = .center
        sumLabel.frame = customView.bounds
        sumLabel.textColor = UIColor.white
        sumLabel.font = UIFont.systemFont(ofSize: 12)
        customView.layer.cornerRadius = 10
        customView.addSubview(sumLabel)

        let nib = UINib(nibName: "SearchTableViewCell", bundle: nil)
        choiceFoodTableView.register(nib, forCellReuseIdentifier: "searchCell")
        buttonSliderView.layer.cornerRadius = 1
    }

    override func viewWillAppear(_: Bool) {
        let last = currentBtn
        currentBtn = last
        setNavSelectSum()
    }

    func currentBtnChanged(_ number: Int) {
        var cond: String?
        var order: String?
        addCustomBtn.isHidden = true
        tableViewButtomConstraint.constant = 0

        switch number {
        case 0:

            foodMaster.diaryType = .foodDetail
            sportMaster.diaryType = .sportDetail
            cond = diaryType == .food ? "\(FOODDETAIL_COLLECTION) = '1'" : "\(SPORTDETAIL_COLLECTION) = '1'"

        case 1:

            foodMaster.diaryType = .foodDetail
            sportMaster.diaryType = .sportDetail
            addCustomBtn.isHidden = false
            tableViewButtomConstraint.constant = addCustomBtn.frame.height
            cond = diaryType == .food ?"\(FOODDETAIL_CLASSIFICATION) = '自訂'" : "\(SPORTDETAIL_CLASSIFICATION) = '自訂'"

        case 2:

            foodMaster.diaryType = .foodDiaryAndDetail
            sportMaster.diaryType = .sportDiaryAndDetail

            let calender = CalenderManager()
            var newDateComponent = DateComponents()
            newDateComponent.day = -7
            let offset = TimeZone.current.secondsFromGMT()
            let date = Date(timeInterval: TimeInterval(offset), since: Date())

            if let calculatedDate = Calendar.current.date(byAdding: newDateComponent, to: date) {
                let calDateString = calender.dateToString(calculatedDate)

                if diaryType == .food {
                    cond = "Food_Diary.\(FOODDIARY_DETAILID)=\(FOODDETAIL_Id) and \(FOODDIARY_DATE) >= '\(calDateString)' group by \(FOODDIARY_DETAILID)"

                    order = "\(FOODDIARY_DATE) desc"

                } else {
                    cond = "Sport_Diary.\(SPORTYDIARY_DETAILID)=\(SPORTDETAIL_ID) and \(SPORTYDIARY_DATE) >= '\(calDateString)' group by \(SPORTYDIARY_DETAILID)"

                    order = "\(SPORTYDIARY_DATE) desc"
                }
            }

        default:

            break
        }

        if currentBtn < 3 {
            if diaryType == .food {
                foodItems = foodMaster.getFoodDetails(.defaultData, amount: nil,
                                                      weight: nil, cond: cond, order: order)
            } else {
                sportItems = sportMaster.getSportDetails(.defaultData, minute: nil,
                                                         cond: cond, order: order)
            }
        }

        choiceFoodTableView.reloadData()
    }

    // MARK: - IBAction

    @IBAction func choicePageButton(_ sender: UIButton) {
        commonButton.isSelected = false
        recentlyButton.isSelected = false
        customBotton.isSelected = false

        let currentPage = sender.tag

        if currentPage == 100 {
            currentBtn = 0
            commonButton.isSelected = true

        } else if currentPage == 101 {
            currentBtn = 1
            customBotton.isSelected = true

        } else {
            currentBtn = 2
            recentlyButton.isSelected = true
        }

        let offset = view.frame.width / 3.0 * CGFloat(currentBtn)
        UIView.animate(withDuration: 0.1) {
            self.sliderViewLeading.constant = offset
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func addCustomBtnAction(_: Any) {
        if diaryType == .food {
            let nestPage = storyboard?.instantiateViewController(withIdentifier: "AddFoodViewController") as! AddFoodViewController

            navigationController?.pushViewController(nestPage, animated: true)

        } else {
            let nestPage = storyboard?.instantiateViewController(withIdentifier: "AddSportTableViewController") as! AddSportTableViewController

            navigationController?.pushViewController(nestPage, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Fucction

    func setNavSelectSum() {
        let count = diaryType == .food ? foodMaster.switchIsOnIDs.count : sportMaster.switchIsOnIDs.count
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.duration = 0.1
        scale.fromValue = 1
        scale.toValue = 1.6
        scale.autoreverses = true
        sumLabel.text = "\(count)"
        navigationItem.rightBarButtonItems?[0].customView?.layer.add(scale, forKey: nil)
    }

    deinit {
        foodMaster.removeFoodDiarysAndSwitch()
        sportMaster.removeSportDiarysAndSwitchIsOn()
    }

    @objc func insertDiary() {
        if actionType == .update {
            selectItemsDone!(true)

        } else {
            if diaryType == .food {
                for diary in foodMaster.foodDiarys {
                    foodMaster.insertFoodDiary(diary: diary)
                }

            } else {
                for diary in sportMaster.sportDiarys {
                    sportMaster.insertWeightDiary(diary: diary)
                }
            }
        }

        navigationController?.popViewController(animated: true)
    }

    @objc func switchStats(sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: choiceFoodTableView)

        guard let indexPath = choiceFoodTableView.indexPathForRow(at: point),
              let cell = choiceFoodTableView.cellForRow(at: indexPath) as? SearchTableViewCell,
              let cellId = cell.id
        else {
            return
        }

        if diaryType == .food {
            guard let myDinnerTime = dinnerTime else {
                return
            }

            if !sender.isSelected {
                foodMaster.switchIsOnIDs.append(cellId)
                let food = foodDiary(dinnerTime: myDinnerTime,
                                     amount: foodItems[indexPath.row].amount,
                                     weight: foodItems[indexPath.row].weight,
                                     foodId: cellId)

                foodMaster.foodDiarys.append(food)
                sender.isSelected = true

            } else {
                guard let index = foodMaster.switchIsOnIDs.index(of: cellId) else {
                    return
                }

                foodMaster.switchIsOnIDs.remove(at: index)
                sender.isSelected = false
                foodMaster.foodDiarys.remove(at: index)
            }

        } else {
            if !sender.isSelected {
                sportMaster.switchIsOnIDs.append(cellId)
                let sport = sportDiary(minute: 30, sportId: cellId, calories: sportItems[indexPath.row].calories)
                sportMaster.sportDiarys.append(sport)
                sender.isSelected = true

            } else {
                guard let index = sportMaster.switchIsOnIDs.index(of: cellId) else {
                    return
                }

                sportMaster.switchIsOnIDs.remove(at: index)
                sportMaster.sportDiarys.remove(at: index)
                sender.isSelected = false
            }
        }
        setNavSelectSum()
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource

extension ChoiceFoodViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        if diaryType == .food {
            if foodItems.count == 0, !isSerached {
                defaultRowInSection = 1

                return defaultRowInSection

            } else {
                defaultRowInSection = 0
            }

            return foodItems.count

        } else {
            if sportItems.count == 0, !isSerached {
                defaultRowInSection = 1

                return defaultRowInSection

            } else {
                defaultRowInSection = 0
            }

            return sportItems.count
        }
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        if defaultRowInSection == 1 {
            return 300
        }

        return 50
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if defaultRowInSection == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchDefaultTableViewCell", for: indexPath) as! SearchDefaultTableViewCell

            var defaultImageName: String
            var defaultTitle: String

            if currentBtn == 0 {
                defaultImageName = "searchStar"
                defaultTitle = "點擊 Star 的都會在這裡"

            } else if currentBtn == 1 {
                defaultImageName = "searchAdd"
                defaultTitle = "來增加些新項目吧！"

            } else {
                defaultImageName = "search"
                defaultTitle = "用名稱來搜尋，增加些紀錄吧！"
            }

            cell.defaultImageView.image = UIImage(named: defaultImageName)
            cell.titleLabel.text = defaultTitle

            return cell
        }

        let searchCell = tableView.dequeueReusableCell(withIdentifier: "searchCell") as! SearchTableViewCell
        if diaryType == .food {
            let foodDetails = foodItems[indexPath.row]
            searchCell.titleLabel.text = foodDetails.sampleName
            searchCell.switchButton.addTarget(self, action: #selector(switchStats), for: .touchUpInside)
            searchCell.id = foodItems[indexPath.row].foodDetailId
            searchCell.bodyLabel.text = "1\(foodDetails.foodUnit)(\(Int(foodDetails.weight))克)"

            if foodMaster.switchIsOnIDs.contains(foodItems[indexPath.row].foodDetailId) {
                searchCell.switchButton.isSelected = true

            } else {
                searchCell.switchButton.isSelected = false
            }

            return searchCell

        } else {
            let sportDetail = sportItems[indexPath.row]
            searchCell.titleLabel.text = sportDetail.sampleName
            searchCell.switchButton.addTarget(self, action: #selector(switchStats), for: .touchUpInside)
            searchCell.id = sportDetail.detailId
            searchCell.bodyLabel.text = "\(sportDetail.minute)分 \(sportDetail.calories) 卡"

            if sportMaster.switchIsOnIDs.contains(sportItems[indexPath.row].detailId) {
                searchCell.switchButton.isSelected = true

            } else {
                searchCell.switchButton.isSelected = false
            }

            return searchCell
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if defaultRowInSection == 1 {
            return
        }

        if diaryType == .food {
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "FoodDetailViewController") as! FoodDetailViewController
            nextPage.foodId = foodItems[indexPath.row].foodDetailId
            nextPage.dinnerTime = dinnerTime
            nextPage.actionType = .insert
            navigationController?.pushViewController(nextPage, animated: true)

        } else {
            let nextpage = storyboard?.instantiateViewController(withIdentifier: "SportDetailViewController") as! SportDetailViewController

            nextpage.actionType = .insert

            nextpage.detail = sportItems[indexPath.row]
            navigationController?.pushViewController(nextpage, animated: true)
        }
    }

    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        if defaultRowInSection == 1 {
            return false
        }

        if currentBtn == 1 {
            return true
        }

        return false
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if defaultRowInSection == 1 {
                return
            }

            if currentBtn == 1 {
                if diaryType == .food {
                    let id = foodItems[indexPath.row].foodDetailId
                    let cond = "\(FOODDETAIL_Id) = \(id)"
                    foodMaster.diaryType = .foodDetail
                    foodMaster.updataDiary(cond: cond,
                                           rowInfo: [FOODDETAIL_CLASSIFICATION: "'其他'"])
                    foodItems.remove(at: indexPath.row)

                } else {
                    let id = sportItems[indexPath.row].detailId
                    let cond = "\(SPORTDETAIL_ID) = \(id)"
                    sportMaster.diaryType = .sportDetail
                    sportItems.remove(at: indexPath.row)
                    sportMaster.updataDiary(cond: cond,
                                            rowInfo: [SPORTDETAIL_CLASSIFICATION: "'其他'"])
                }
            }

            tableView.reloadData()

        } else if editingStyle == .insert {}
    }
}

// MARK: - UISearchBarDelegate

extension ChoiceFoodViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else {
            return
        }

        searchBar.resignFirstResponder()

        if diaryType == .food {
            let cond = "\(FOODDETAIL_SAMPLENAME) like'%" + searchText + "%'"
            foodMaster.diaryType = .foodDetail
            foodItems = foodMaster.getFoodDetails(.defaultData,
                                                  amount: nil,
                                                  weight: nil,
                                                  cond: cond,
                                                  order: nil)

        } else {
            let cond = "\(SPORTDETAIL_SAMPLENAME) like'%" + searchText + "%'"
            sportMaster.diaryType = .sportDetail
            sportItems = sportMaster.getSportDetails(.defaultData, minute: nil, cond: cond, order: nil)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        defaultRowInSection = 1
        if isSerached {
            isSerached = false
            changeBtnViewTop(isUp: isSerached)
            currentBtn = lastPage
        }

        searchBar.resignFirstResponder()
        searchBar.text = nil
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            foodItems.removeAll()
            sportItems.removeAll()
        }
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        defaultRowInSection = 0
        searchBar.setShowsCancelButton(true, animated: true)
        foodItems.removeAll()
        sportItems.removeAll()

        if !isSerached {
            isSerached = true
            changeBtnViewTop(isUp: isSerached)
            lastPage = currentBtn
            currentBtn = 3
        }

        return true
    }

    func changeBtnViewTop(isUp: Bool) {
        let buttonHight = buttonView.frame.height

        UIView.animate(withDuration: 0.3) {
            if isUp {
                self.btnViewTopConstraint.constant = -buttonHight

            } else {
                self.btnViewTopConstraint.constant = 0
            }

            self.view.layoutIfNeeded()
        }
    }
}
