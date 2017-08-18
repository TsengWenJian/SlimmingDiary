//
//  ShowRecordViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/31.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class ShowRecordDetailViewController: UIViewController {
    
    var diarys = [OneDiaryRecord]()
    var shareDiary:ShareDiary?
    var user:UserData?
    
    
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var titleImageView:AdvanceImageView!
    @IBOutlet weak var titleImageContainerViewHeight: NSLayoutConstraint!
    var sectionsIsExpend = [Bool]()
    var serviceManager = DataService.standard
    var shareManager = shareDiaryManager.standard
    
    
    
    @IBOutlet weak var recordsDetailTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        recordsDetailTableView.contentInset = UIEdgeInsets(top:titleImageContainerViewHeight.constant,
                                                           left:0,bottom:0,right:0)
        
        
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.bounds.height/2
        userPhotoImageView.layer.borderColor = UIColor.white.cgColor
        userPhotoImageView.layer.borderWidth = 1
        
        recordsDetailTableView.estimatedRowHeight = 100
        recordsDetailTableView.rowHeight = UITableViewAutomaticDimension

        
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        recordsDetailTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        
        if serviceManager.isConnectDBURL == false{
            return
        }
        
        guard let myShareDiary = shareDiary,
            let diaryId = myShareDiary.diaryId else{
                return
        }
        
    
        
        navigationItem.title = myShareDiary.title
        titleImageView.loadWithURL(urlString: myShareDiary.titleImageURL!)
        detailLabel.text = "\(myShareDiary.beginDate!) / \(myShareDiary.day!) day"
       
    
        if shareDiary?.userId == ProfileManager.standard.userUid{
            
            let btn = UIBarButtonItem(barButtonSystemItem:.trash,target: self, action:#selector(trashDiary))
            let editImage = UIImage(named: "edit")
            let edit = UIBarButtonItem(image:editImage, style: .plain, target: self, action:#selector(editDiary))
            
            navigationItem.rightBarButtonItems = [btn,edit]
            userNameLabel.text = "你自己"
            
            userPhotoImageView.image = UIImage(imageName: ProfileManager.standard.userPhotoName, search: .cachesDirectory)
            
            
        }else{
            
           
            if let myUser = user{
                
                   userNameLabel.text = myUser.name
 
                if let userImageUrl = myUser.imageURL{
                    
                    userPhotoImageView.loadImageCacheWithURL(urlString:userImageUrl)
                    
                }else{
                    
                    userPhotoImageView.image = UIImage(named:"man")
                }
        
            }
        }
        
        
        
        shareManager.getShareDiaryContent(diaryID: diaryId) { (error, result) in
            
            if let err = error{
                print(err.localizedDescription)
                return
            }
            self.diarys = result
            self.setSectionExpend(sum:result.count)
            DispatchQueue.main.async {
                self.recordsDetailTableView.reloadData()
            }
        }
    
    }
    func editDiary(){
        let nextPage = storyboard?.instantiateViewController(withIdentifier:"MakeShareDiaryTableViewController") as! MakeShareDiaryTableViewController
        
           nextPage.diarys = diarys
           nextPage.actionType = .update
           nextPage.titleDiary = shareDiary!
           let back = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
           navigationItem.backBarButtonItem = back
           navigationController?.pushViewController(nextPage, animated: true)
        
    }
    func setSectionExpend(sum:Int){
        
        for _ in 0..<sum{
            sectionsIsExpend.append(true)
        }
        
    }

    func trashDiary(){
        
        let alert = UIAlertController(title: "刪除", message: "確定刪除這篇日記?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "確定", style: .default) { (UIAlertAction) in
            
            
            guard let myShareDiary = self.shareDiary,
                let diaryId = myShareDiary.diaryId,
                let open = myShareDiary.open,
                let userId = myShareDiary.userId else{
                    
                    return
            }
            
            
            self.serviceManager.dbDiarysURL.child(open).child(diaryId).removeValue { (error, DatabaseReference) in
                
                if let err = error{
                    print(err.localizedDescription)
                    return
                }
                self.serviceManager.dbDiaryContentURL.child(diaryId).removeValue()
                self.serviceManager.dbUserDiaryURL.child(userId).child(diaryId).removeValue()
                self.navigationController?.popViewController(animated: true)
                
            }
        
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    
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
        
        sectionsIsExpend[section] = !sectionsIsExpend[section]
        recordsDetailTableView.reloadSections(IndexSet(integer:section), with: .automatic)
        
        // move 1point to touch off scrollViewDidScroll
        let point = recordsDetailTableView.contentOffset
        recordsDetailTableView.setContentOffset( CGPoint(x: point.x, y: point.y+1), animated: false)
        
    }
}
//MARK: - UITableViewDelegate,UITableViewDataSource
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
//MARK: - UIScrollViewDelegate
extension ShowRecordDetailViewController:UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        titleImageContainerViewHeight.constant = offsetY < 0.0 ? -offsetY : 0.0
        view.layoutIfNeeded()
        
        
    }
    
}
