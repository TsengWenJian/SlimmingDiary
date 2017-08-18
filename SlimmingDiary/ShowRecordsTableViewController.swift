//
//  ShowRecordsTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/31.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Firebase




class ShowRecordsTableViewController: UITableViewController {
    
    var recordArray = [ShareDiary]()
    var userDict = [String:UserData]()
    var servicManager =  DataService.standard
    var selfDiary = [ShareDiary]()
    var currentPage = 0{
        didSet{tableView.reloadData()}
    }
    
    var profileManager = ProfileManager.standard
    var toastView = NickToastUIView()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if servicManager.isConnectDBURL{
            
            toastView = NickToastUIView(supView:view, type: .download)
            
            if servicManager.isLogin{
                
                getUserDiary()
                
            }
            getPublicDiary()
            
        }
        
        //tableView.refreshControl?.addTarget(self,action: #selector(refresh), for: .valueChanged)
        
        
        NotificationCenter.default.addObserver(self,selector: #selector(loginStatusIsChange),name: NSNotification.Name(rawValue: "loginStatus"), object: nil)
        
        
    }
    
    func loginStatusIsChange(){
        
        
        
        
        servicManager.dbDiarysURL.child("public").removeAllObservers()
        servicManager.dbUserDiaryURL.child(profileManager.userUid!).removeAllObservers()
        selfDiary.removeAll()
        recordArray.removeAll()
        userDict.removeAll()
        tableView.reloadData()
        
        if servicManager.isConnectDBURL{
            
            if servicManager.isLogin{
                
                getUserDiary()
                
            }
            
            getPublicDiary()
            
        }
        
    }
    
    
    
    
    func getPublicDiary(){
        
        

        servicManager.dbDiarysURL.child("public").observe(.childAdded, with: { (DataSnapshot) in
            
            
            guard let dict = DataSnapshot.value as? [String:AnyObject] else{
                return
            }
        
            let record = ShareDiary()
            record.setValuesForKeys(dict)
            self.recordArray.append(record)
            
           
            
            guard let userId = record.userId else{
                return
            }
            
            self.recordArray = self.sortWithTimestamp(array:self.recordArray)
            
            //download author image and name
            self.servicManager.dbUserURL.child(userId).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                
                
                self.toastView.removefromView()
        
                guard let dict2 = dataSnapshot.value as? [String:AnyObject] else{
                    return
                }
                
                let user = UserData()
                user.name = dict2["name"] as? String
                user.imageURL = dict2["imageURL"] as? String
                self.userDict[userId] = user
                
                
                if self.currentPage == 0{
                    
                    DispatchQueue.main.async {
                        
                        self.tableView.reloadData()
                        
                    }
                    
                }
                
            })
            
        })
        
        
        
        
        servicManager.dbDiarysURL.child("public").observe(.childRemoved, with: { (gataSnapshot) in
            
            guard let dict = gataSnapshot.value as? [String:AnyObject] else{
                return
            }
            
            
            let index =  self.recordArray.index(where: { (ShareDiary) -> Bool in
                
                if ShareDiary.diaryId == dict["diaryId"] as? String{
                    return true
                }
                return false
            })
            
            
            
            self.recordArray.remove(at: index!)
            self.tableView.reloadData()
            
        })

        
    }
    
    
    
    func getUserDiary(){
        
        guard let userid = servicManager.userUid else{
            
            return
        }
        
        
        servicManager.dbUserDiaryURL.child(userid).observe(.childRemoved, with: { (removeData) in
            
            guard let dict = removeData.value as? [String:AnyObject] else{
                return
            }
            
            if  let index =  self.selfDiary.index(where: { (ShareDiary) -> Bool in
                
                if ShareDiary.diaryId == dict["diaryId"] as? String{
                    return true
                }
                return false
                
            }){
                self.selfDiary.remove(at: index)
                
            }
            
            self.tableView.reloadData()
            
        })
        
        
        
        
        servicManager.dbUserDiaryURL.child(userid).observe(.childAdded, with: { (dataSnapshot) in
            
            
            guard let dict2 = dataSnapshot.value as? [String:AnyObject] else{
                return
            }
            
            
            let record = ShareDiary()
            record.setValuesForKeys(dict2)
            self.selfDiary.append(record)
            
            self.selfDiary = self.sortWithTimestamp(array:self.selfDiary)
            
            
            if self.currentPage == 1{
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            
        })
        
    }
    
    
    func sortWithTimestamp(array:[ShareDiary])->[ShareDiary]{
        
        let myDiary =  array.sorted{ (record1, record2)  in
            
            guard let time1 = record1.timestamp?.intValue,
                let time2 = record2.timestamp?.intValue else{
                    return false
            }
            
            return time1 > time2
        }
        
        return myDiary
        
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return currentPage == 0 ? 1 : 2
        
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if currentPage == 1 && indexPath.section == 0{
            return 100
        }
        
        
        return 220
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if currentPage == 0{
            
            return recordArray.count
            
        }else{
            
            if section == 0{
                return 1
            }
            
            return selfDiary.count
            
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let recordRow:ShareDiary
        if currentPage == 0 {
            
            recordRow = recordArray[indexPath.row]
            
            
        }else{// currentPage = 1
            
            
            if indexPath.section == 0 && indexPath.row == 0{
                
                let profileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTableViewCell") as! ProfileHeaderTableViewCell
                profileCell.userPhoto.image = UIImage().checkUserPhoto()
                
                if servicManager.isLogin{
                    profileCell.userNameTextField.text = ProfileManager.standard.userName
                    profileCell.emailLabel.text = "\(selfDiary.count) diary"
                    
                }else{
                    profileCell.userNameTextField.text = "尚未登入"
                    profileCell.emailLabel.text = "Log in"
                    
                    
                }
                
                
                return profileCell
                
                
            }
            
            recordRow = selfDiary[indexPath.row]
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowRecordsTableViewCell", for: indexPath) as! ShowRecordsTableViewCell
        
        cell.userPhotoImageView.isHidden = false
        
        if currentPage == 1{
            
            if recordRow.open == "private" {
                
                
                cell.userPhotoImageView.image = UIImage(named: "full_lock")
            }else{
                
                
                cell.userPhotoImageView.isHidden = true
            }
            
            cell.userPhotoImageView.layer.borderWidth = 0
            cell.userPhotoImageView.layer.cornerRadius = 0
            
            
        }else{
            cell.userPhotoImageView.layer.borderWidth = 1
            cell.userPhotoImageView.layer.cornerRadius = 22.5
            
            if  let id = recordRow.userId,
                let userData = userDict[id]{
                
                if let  myImage = userData.imageURL{
                    
                    cell.userPhotoImageView.loadImageCacheWithURL(urlString:myImage)
                    
                }else{
                    
                    cell.userPhotoImageView.image = UIImage(named: "man")
                }
                
                cell.userNameLabel.text = userData.name!
                
            }
            
            
            
            
        }
        let isHidden = currentPage == 1 ? true : false
        cell.userNameLabel.isHidden = isHidden
        cell.titleImageView.loadWithURL(urlString: recordRow.titleImageURL!)
        cell.titleLabel.text = recordRow.title!
        cell.detailLabel.text = "\(recordRow.beginDate!) / \(recordRow.day!) day"
        
        
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 1:10
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "ShowRecordDetailViewController") as! ShowRecordDetailViewController
        
        if currentPage == 0{
            
            nextPage.shareDiary = recordArray[indexPath.row]
            if let userId = recordArray[indexPath.row].userId{
                nextPage.user = userDict[userId]
                
            }
            navigationController?.pushViewController(nextPage, animated: true)
            
        }else{
            
            if indexPath.section == 0{
                
                var nexPage:UIViewController
                if servicManager.currentUser == nil{
                    
                    nexPage = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    
                    
                    
                }else{
                    
                    nexPage = storyboard?.instantiateViewController(withIdentifier: "PersonalFilesViewController") as! PersonalFilesViewController
                    
                }
                navigationController?.pushViewController(nexPage, animated: true)
                
                
            }else{
                
                nextPage.shareDiary = selfDiary[indexPath.row]
                nextPage.user = userDict[ProfileManager.standard.userUid!]
                
                
                navigationController?.pushViewController(nextPage, animated: true)
                
                
                
            }
            
        }
    }
    
}
