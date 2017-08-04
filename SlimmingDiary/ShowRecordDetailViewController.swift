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
     var diaryID:String?
     var diarys = [OneDiaryRecord]()
    
   

    @IBOutlet weak var recordsDetailTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        guard let myDiaryID = diaryID else{
            return
        }
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        recordsDetailTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        let toastView = NickToastUIView(supView: self.recordsDetailTableView, type:.download)
       
        
        
        Database.database().reference().child("diary-content").child(myDiaryID).observe(.childAdded, with: { (DataSnapshot) in
            
            
            self.diarys = [OneDiaryRecord]()
            let diaryDictArray =  DataSnapshot.value as! [[String:AnyObject]]
            
            for diary in diaryDictArray{
                
                let foodItems = diary["foodItmes"] as?[[String:String]]
                let sportItems = diary["sportItems"] as?[[String:String]]
                let text = diary["text"] as? String
                
                let da = OneDiaryRecord(food:self.dictArrayTurnDiaryItem(dict: foodItems),
                                        sport:self.dictArrayTurnDiaryItem(dict: sportItems),
                                        text: text)
                self.diarys.append(da)
                
                
            }
            
            DispatchQueue.main.async {
                toastView.removefromView()
                self.recordsDetailTableView.reloadData()
            }
            
            
        })
        
        
        
        recordsDetailTableView.estimatedRowHeight = 100
        recordsDetailTableView.rowHeight = UITableViewAutomaticDimension
        

    }
    
    
    func dictArrayTurnDiaryItem(dict:[[String:String]]?)->[DiaryItem]?{
        
        
        guard let mydict = dict else{
            return nil
        }
        
        var items = [DiaryItem]()
        
        for item in mydict {
            
            let diary = DiaryItem(image: nil, title: item["title"]!, detail: item["detail"]!)
            diary.imageURL = item["imageURL"]
            
            items.append(diary)
        
        }
        return items
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ShowRecordDetailViewController:UITableViewDelegate,UITableViewDataSource{
    
     func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return diarys.count
        
        
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var calRow = 0
        let sectionDay = diarys[section]
        if sectionDay.food != nil{calRow+=1}
        if sectionDay.sport != nil{calRow+=1}
        if sectionDay.text != nil{calRow+=1}
        

        
        return calRow
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
        
        headerCell.titleLabel.text = "day\(section+1)"
        
        return headerCell
    }
    
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    
}
