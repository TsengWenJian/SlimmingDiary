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
     var data:[OneDiaryRecord]?
    
    let titleArray = ["飲食","運動"]
    let detailArray = ["",""]

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
            
            
            self.data = [OneDiaryRecord]()
            let diary =  DataSnapshot.value as![[String:AnyObject]]
            
            for i in diary{
                
                let food = i["foodItmes"] as![[String:String]]
                let sport = i["sportItems"] as![[String:String]]
                let text = i["text"] as! String
                
                let da = OneDiaryRecord(food:   self.diaryItem(dict: food), sport:   self.diaryItem(dict: sport), text: text)
                self.data?.append(da)
                
                
            }
            
            DispatchQueue.main.async {
                toastView.removefromView()
                self.recordsDetailTableView.reloadData()
            }
            
            
        })
        
        
        
        recordsDetailTableView.estimatedRowHeight = 100
        recordsDetailTableView.rowHeight = UITableViewAutomaticDimension
        

    }
    
    
    func diaryItem(dict:[[String:String]])->[DiaryItem]{
        
        var items = [DiaryItem]()
        for item in dict {
            
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
        
        return data == nil ? 0:(data?.count)!
        
        
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        
        if indexPath.row == 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReadTextViewTableViewCell", for: indexPath) as! ReadTextViewTableViewCell
             cell.textView.text = data?[indexPath.section].text
            
            return cell
            
        }
        
        
        
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadCollectionTableViewCell", for: indexPath) as! ReadCollectionTableViewCell
        
        cell.titleLabel.text = titleArray[indexPath.row]
        
        
        
        if indexPath.row == 0{
            
            
            
            let text:String = calSumCalorie(items:data?[indexPath.section].food)
            cell.detailLabel.text = "攝取\(text)大卡"
            cell.data = (data?[indexPath.section].food)!
            cell.diaryImageType = .food
        }
        
        
        
        if indexPath.row == 1{
            cell.diaryImageType = .sport
            
            let text:String = calSumCalorie(items:data?[indexPath.section].sport)
            cell.detailLabel.text = "消耗 \(text)大卡"
            cell.data = (data?[indexPath.section].sport!)!
        }
        
        
//        cell.VC = self
        
        
        
        return cell
    }
    
    
    func calSumCalorie(items:[DiaryItem]?)->String{
        
        var sum:Double = 0
        guard let myItems = items else {
            return "0"
        }
        
        for i in myItems{
            sum += Double(i.detail)!
            
        }
        
        return String(format: "%1.f", sum)
        
    }
    
    
    
    
 
        
        
    
    
//     func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//    
    
    
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
