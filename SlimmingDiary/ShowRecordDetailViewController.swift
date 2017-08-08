//
//  ShowRecordViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/31.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Firebase

class ShowRecordDetailViewController: UIViewController {
    
    var diarys = [OneDiaryRecord]()
    var shareDiary:ShareDiary?
    var user:UserData?
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleImageContainerViewHeight: NSLayoutConstraint!
    var sectionsIsExpend = [Bool]()
    
    
    @IBOutlet weak var recordsDetailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if shareDiary?.userId == ProfileManager.standard.userUid{
            let btn = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashDiary))
              navigationItem.rightBarButtonItems = [btn]
        }
        
        
        recordsDetailTableView.contentInset = UIEdgeInsets(top:titleImageContainerViewHeight.constant,
                                                           left: 0, bottom: 0, right: 0)
        
        
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.bounds.height/2
        userPhotoImageView.layer.borderColor = UIColor.white.cgColor
        userPhotoImageView.layer.borderWidth = 1
        
        
        
        
        guard let myShareDiary = shareDiary,
            let diaryId = myShareDiary.diaryId,
            let myUser = user else{
                return
        }
        navigationItem.title = myShareDiary.title
        titleImageView.loadImageCacheWithURL(urlString:myShareDiary.titleImageURL!)
        detailLabel.text = "\(myShareDiary.beginDate!) / \(myShareDiary.day!) day"
        
        
        userNameLabel.text = myUser.name
        if let userImageUrl = myUser.imageURL{
            
            userPhotoImageView.loadImageCacheWithURL(urlString:userImageUrl)
            
        }else{
            
            userPhotoImageView.image = UIImage(named:"man")
        }
        
        
        
        
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        recordsDetailTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        let toastView = NickToastUIView(supView: self.recordsDetailTableView, type:.download)
        
       
        Database.database().reference().child("diary-content").child(diaryId).observe(.childAdded, with: { (DataSnapshot) in
            
            
            if let test = DataSnapshot.value as? [String:AnyObject]{
                print(test)
            }
            
            
            
            self.diarys = [OneDiaryRecord]()
            guard let diaryDictArray =  DataSnapshot.value as? [[String:AnyObject]] else{
                return
            }
            
            for diary in diaryDictArray{
                self.sectionsIsExpend.append(true)
                let foodItems = diary["foodItmes"] as?[[String:String]]
                let sportItems = diary["sportItems"] as?[[String:String]]
                let text = diary["text"] as? String
                guard let date = diary["date"] as? String else{return}
                
                let da = OneDiaryRecord(food:self.dictArrayTurnDiaryItem(dict: foodItems),
                                        sport:self.dictArrayTurnDiaryItem(dict: sportItems),
                                        text: text, date:date)
                self.diarys.append(da)
                
                
            }
            
            DispatchQueue.main.async {
                toastView.removefromView()
                self.recordsDetailTableView.reloadData()
            }
            
            
        }){ (error) in
            
                 toastView.removefromView()
                 print(error.localizedDescription)
        
        }
        
        
        
        recordsDetailTableView.estimatedRowHeight = 100
        recordsDetailTableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    func trashDiary(){
        
        guard let myShareDiary = shareDiary,
            let diaryId = myShareDiary.diaryId
            else{
                return
        }
        
        Database.database().reference().child("diarys").child(diaryId).removeValue { (error, DatabaseReference) in
              Database.database().reference().child("diary-content").child(diaryId).removeValue()
              self.navigationController?.popViewController(animated: true)
        }
       
    }
    
    func dictArrayTurnDiaryItem(dict:[[String:String]]?)->[DiaryItem]?{
        
        
        guard let mydict = dict else{
            return nil
        }
        
        var items = [DiaryItem]()
        
        for item in mydict {
            
            let diary = DiaryItem(image: nil,
                                  title:item["title"]!,
                                  detail: item["detail"]!)
            
            diary.imageURL = item["imageURL"]
            items.append(diary)
            
        }
        return items
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func sectionIsExpend(sender:UIButton){
        let section = sender.tag - 1000
        
        if sectionsIsExpend[section]{
            sectionsIsExpend[section] = false
        } else {
            sectionsIsExpend[section] = true
        }
        
        recordsDetailTableView.reloadSections(IndexSet(integer:section), with: .automatic)
        
//        move 1point to touch off scrollViewDidScroll
        let point = recordsDetailTableView.contentOffset
        recordsDetailTableView.setContentOffset( CGPoint(x: point.x, y: point.y+1), animated: false)
        
    }
    
    
}

extension ShowRecordDetailViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return diarys.count
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sectionsIsExpend[section]{
            var calRow = 0
            let sectionDay = diarys[section]
            if sectionDay.food != nil{calRow+=1}
            if sectionDay.sport != nil{calRow+=1}
            if sectionDay.text != nil{calRow+=1}
            
            
            
            return calRow
            
        }else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        var calRow:Int = 0
        var foodRow:Int = 0
        
        
        if diarys[indexPath.section].food == nil{
            calRow += 1
            foodRow = -1
            
        }
        if diarys[indexPath.section].sport == nil{
            calRow += 1
            
        }
        
        
        
        let sportRow:Int = 1 - calRow
        let textRow:Int = 2 - calRow
        
        
        
        
        if indexPath.row == textRow{
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"ReadTextViewTableViewCell",for: indexPath) as! ReadTextViewTableViewCell
            
            cell.textView.text = diarys[indexPath.section].text
            
            return cell
            
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadCollectionTableViewCell", for: indexPath) as! ReadCollectionTableViewCell
        
        cell.VC = self
        
        
        
        if indexPath.row == foodRow {
            
            cell.diaryImageType = .food
            cell.data = diarys[indexPath.section].food!
            
            
        }else if indexPath.row == sportRow {
            
            cell.diaryImageType = .sport
            cell.data = diarys[indexPath.section].sport!
            
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
        headerCell.contentView.layer.cornerRadius = 0
        headerCell.titleLabel.text = "DAY\(section+1)    \(diarys[section].date)"
        headerCell.expendBtn.addTarget(self, action: #selector(sectionIsExpend), for: .touchUpInside)
        headerCell.expendBtn.tag = 1000 + section
        
        return headerCell.contentView
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    
}

extension ShowRecordDetailViewController:UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        titleImageContainerViewHeight.constant = offsetY < 0.0 ? -offsetY : 0.0
        view.layoutIfNeeded()
        
        
    }
    
    
    
    
    
    
    
    
    
}
