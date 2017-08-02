//
//  ShowRecordsTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/31.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Firebase


class DiaryRecord:NSObject {
    var diayId:String?
    var title:String?
    var titleImageURL:String?
    var userId:String?
    var beginDate:String?
    var timestamp:String?
    var day:String?
    
    
    
}

class UserData: NSObject {
    
    var name:String?
    var imageURL:String?
    //    var email:String?
    
}


class ShowRecordsTableViewController: UITableViewController {
    var recordArray = [DiaryRecord]()
    var userDict = [String:UserData]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let toastView = NickToastUIView(supView:tableView, type: .download)
        
        
        Database.database().reference().child("diarys").observe(.childAdded, with: { (DataSnapshot) in
            
            if let dict = DataSnapshot.value as? [String:AnyObject] {
                
                let record = DiaryRecord()
                
                
                record.setValuesForKeys(dict)
                
                
                
                self.recordArray.append(record)
                
                
                guard let userId = record.userId else{
                    toastView.removefromView()
                    return
                }
                
                //download author image and name
                Database.database().reference().child("users").child(userId).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                    
                    
                    self.recordArray.sort(by: { (record1, record2) -> Bool in
                        
                        guard let time1 = Int(record1.timestamp!),
                            let time2 = Int(record2.timestamp!)else{
                                return false
                        }
                        
                        return time1 > time2
                    })
                    
                    if let dict2 = dataSnapshot.value as? [String:AnyObject] {
                        
                        let user = UserData()
                        
                        if let name = dict2["name"] as? String{
                            
                            user.name = name
                            
                        }
                        
                        if let imageUrl = dict2["imageURL"] as? String{
                            
                            user.imageURL = imageUrl
                            
                        }
                        self.userDict[userId] = user
                        
                        
                        DispatchQueue.main.async {
                            toastView.removefromView()
                            self.tableView.reloadData()
                        }
                        
                    }
                })
                
            }
            
        })
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recordArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowRecordsTableViewCell", for: indexPath) as! ShowRecordsTableViewCell
        
        let recordRow = recordArray[indexPath.row]
        
        
        
        
        cell.titleImageView.loadImageCacheWithURL(urlString:recordRow.titleImageURL!)
        cell.titleLabel.text = recordRow.title!
        cell.detailLabel.text = "\(recordRow.beginDate!) / \(recordRow.day!) day"
        
         if let id = recordRow.userId,
            let userData = userDict[id]{
            
            cell.userPhotoImageView.loadImageCacheWithURL(urlString:userData.imageURL!)
            cell.userNameLabel.text = userData.name!
            
            
            
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "ShowRecordDetailViewController") as! ShowRecordDetailViewController
        nextPage.diaryID = recordArray[indexPath.row].diayId
        navigationController?.pushViewController(nextPage, animated: true)
    }
    
}
