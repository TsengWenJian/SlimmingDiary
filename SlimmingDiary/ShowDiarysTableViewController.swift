//
//  ShowRecordsTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/31.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Firebase




class ShowDiarysTableViewController: UITableViewController {
    
    var recordArray = [ShareDiary]()
    var userDict = [String:UserData]()
    var servicManager =  DataService.standard
    var selfDiary = [ShareDiary]()
    var currentPage = 0{
        didSet{
            
            tableView.reloadData()
            
            if currentPage == 0{
                
                let refreshControl = UIRefreshControl()
                tableView.refreshControl = refreshControl
                refreshControl.addTarget(self,action: #selector(refreshPublicDiarys),
                                         for: .valueChanged)
                
                
            }else{
                
                tableView.refreshControl = nil
                
            }
        }
    }
    
    var profileManager = ProfileManager.standard
    var toastView:NickToastUIView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self,action: #selector(refreshPublicDiarys),
                                 for: .valueChanged)
        
        
        if servicManager.isConnectDBURL{
           
            DispatchQueue.main.async {
                
                self.toastView = NickToastUIView()
                self.toastView?.showView(supView:self.tableView, type: .download)
            }
           
            
            if servicManager.isLogin{
                
                getUserDiary()
                
            }
            getPublicDiary()
            
        }
        
        NotificationCenter.default.addObserver(self,selector:#selector(loginStatusIsChange),name: NSNotification.Name(rawValue: "loginStatus"), object: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    @objc func refreshPublicDiarys(){
        
        if currentPage == 0{
            
            
            recordArray.removeAll()
            userDict.removeAll()
            tableView.reloadData()
            
            
            if servicManager.isConnectDBURL{
                
                getPublicDiary()
                
            }
            
        }
        
        tableView.refreshControl?.endRefreshing()
        
    }
    
    
    
    @objc func loginStatusIsChange(){
        
        
        servicManager.dbUserDiaryURL.removeAllObservers()
        selfDiary.removeAll()
        tableView.reloadData()
        
        if servicManager.isConnectDBURL{
            
            if servicManager.isLogin{
                
                getUserDiary()
                
            }
        }
    }
    
    
    
    
    func getPublicDiary(){
        
    
        servicManager.dbDiarysURL.child("public").queryLimited(toLast: 50).observeSingleEvent(of:.value, with: { (DataSnapshot) in
            
            
            guard let recordDict = DataSnapshot.value as? [String:AnyObject] else{
                self.toastView?.removefromView()
                return
            }
            
            for (index,diaryID) in recordDict.enumerated(){
                
                let record = ShareDiary()
                record.setValuesForKeys(diaryID.value as! [String : Any])
                self.recordArray.append(record)
                

                self.servicManager.dbUserURL.child(record.userId).observeSingleEvent(of:.value, with: {  (dataSnapshot) in
                    
                    guard let userDict = dataSnapshot.value as? [String:AnyObject] else{
                        self.toastView?.removefromView()
                        return
                    }
                    
                    let user = UserData()
                    user.name = userDict[ServiceDBKey.userName] as? String
                    user.imageURL = userDict[ServiceDBKey.userImageURL] as? String
                    self.userDict[record.userId] = user;
                    
                    
                    if self.currentPage == 0 {
                        
                        DispatchQueue.main.async {
                            
                            if index == recordDict.count-1{
                                
                                self.tableView.reloadData()
                                self.toastView?.removefromView()
                                
                            }
                            
                            
                        }
                    }
                })
                
            }
            
            
            
            self.recordArray = self.sortWithTimestamp(array: self.recordArray)
            
        })
    }
    
    
    
    func getUserDiary(){
        
        guard let userid = servicManager.userUid else{
            
            return
        }
        
        
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
                    if  self.toastView != nil{
                        self.toastView?.removefromView()
                    }
                }
                
            }
            
        })
        
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
                self.tableView.reloadData()
            }
            
            
            
        })
        
        
        
    }
    
    
    func sortWithTimestamp(array:[ShareDiary])->[ShareDiary]{
        
        let myDiary =  array.sorted{ (record1, record2)  in
            
            return Int(truncating: record1.timestamp) > Int(truncating: record2.timestamp)
        }
        
        return myDiary
        
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
            
            
            return section == 0 ? 1:selfDiary.count
            
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
            
            
            if let  myImageURL = userDict[recordRow.userId]?.imageURL{
                
                cell.userPhotoImageView.loadWithURL(urlString: myImageURL)
                
                
            }else{
                
                cell.userPhotoImageView.image = UIImage(named: "user")
            }
            
            cell.userNameLabel.text = userDict[recordRow.userId]?.name!
            
            
            
        }
        
        let isHidden = currentPage == 1 ? true : false
        cell.userNameLabel.isHidden = isHidden
        cell.titleImageView.loadWithURL(urlString: recordRow.titleImageURL)
        cell.titleLabel.text = recordRow.title
        cell.detailLabel.text = "\(recordRow.beginDate) / \(recordRow.day) day"
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 1:10
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "ShowDiarysDetailViewController") as! ShowDiarysDetailViewController
        
        if currentPage == 0{
            
            nextPage.shareDiary = recordArray[indexPath.row]
            
            nextPage.user = userDict[recordArray[indexPath.row].userId]
            
            
            navigationController?.pushViewController(nextPage, animated: true)
            
        }else{
            
            if indexPath.section == 0{
                
                var nexPage:UIViewController
                if servicManager.currentUser == nil{
                    
                    nexPage = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                    
                    
                    
                }else{
                    
                    nexPage = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                    
                }
                
                navigationController?.pushViewController(nexPage, animated: true)
                
                
            }else{
                
                nextPage.shareDiary = selfDiary[indexPath.row]
                
                if let uid = ProfileManager.standard.userUid{
                    nextPage.user = userDict[uid]
                }
                
                navigationController?.pushViewController(nextPage, animated: true)
                
                
                
            }
            
        }
    }
    
}
