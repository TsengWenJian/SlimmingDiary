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
    var selfDiary = [ShareDiary](){
        didSet{
            
            
        }
    }
    
    var currentPage = 0{
        didSet{tableView.reloadData()}
    }
    
    var profileManager = ProfileManager.standard
    
    var isLogin:Bool{
        
        return profileManager.userUid == nil ? false:true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isLogin{
            
            getUserDiary()
            
        }
        
        getOpenDiary()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(loginStatusIsChange),name: NSNotification.Name(rawValue: "loginStatus"), object: nil)
        
        
    }
    
    func loginStatusIsChange(){
        
        Database.database().reference().removeAllObservers()
        getUserDiary()
        
        
        
    }
    
    
    
    
    func getOpenDiary(){
        
        
        
        let toastView = NickToastUIView(supView:tableView, type: .download)
        servicManager.dbDiarysURL.queryOrdered(byChild:"open").queryEqual(toValue:"true").observe(.childAdded, with: { (DataSnapshot) in
            
            guard let dict = DataSnapshot.value as? [String:AnyObject] else{
                return
            }
            
            
            let record = ShareDiary()
            record.setValuesForKeys(dict)
            self.recordArray.append(record)
            
            
            guard let userId = record.userId else{
                toastView.removefromView()
                return
            }
            
            self.recordArray = self.sortWithTimestamp(array:self.recordArray)
            
            //download author image and name
            self.servicManager.dbUserURL.child(userId).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                
                toastView.removefromView()
                guard let dict2 = dataSnapshot.value as? [String:AnyObject] else{
                    return
                }
                
                let user = UserData()
                user.name = dict2["name"] as? String
                user.imageURL = dict2["imageURL"] as? String
                self.userDict[userId] = user
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                    
                }
                
                
                
            }){ (error) in
                
                toastView.removefromView()
            }
            
        }){ (error) in
            
            toastView.removefromView()
            
        }
        
    }
    
    
    
    func getUserDiary(){
        
        
        
        selfDiary.removeAll()
        tableView.reloadData()
        
        
        guard let userid = servicManager.userUid else{
            
            
            return
        }
        
        servicManager.dbDiarysURL.queryOrdered(byChild:"userId").queryEqual(toValue:userid).observe(.childAdded, with: { (dataSnapshot) in
            
            
            guard let dict = dataSnapshot.value as? [String:AnyObject] else{
                return
            }
            
            let record = ShareDiary()
            record.setValuesForKeys(dict)
            self.selfDiary.append(record)
            
            self.selfDiary = self.sortWithTimestamp(array:self.selfDiary)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }) { (error) in
            
            print(error)
            
        }
        
    }
    
    
    func sortWithTimestamp(array:[ShareDiary])->[ShareDiary]{
        
       let myDiary =  array.sorted(by: { (record1, record2) -> Bool in
            
            guard let time1 = record1.timestamp?.intValue,
                let time2 = record2.timestamp?.intValue else{
                    return false
            }
            
            return time1 > time2
        })

        return myDiary
        
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    
    
   //MARK: -
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
            
            
            
        }else{
            
            
            if indexPath.section == 0 && indexPath.row == 0{
                
                let profileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTableViewCell") as! ProfileHeaderTableViewCell
                profileCell.userPhoto.image = UIImage().checkUserPhoto()
                
                if isLogin{
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
        
        
        cell.titleImageView.loadImageCacheWithURL(urlString:recordRow.titleImageURL!)
        cell.titleLabel.text = recordRow.title!
        cell.detailLabel.text = "\(recordRow.beginDate!) / \(recordRow.day!) day"
        
        
        
        let isHidden = currentPage == 1 ? true : false
        
        
        cell.userPhotoImageView.isHidden = isHidden
        cell.userNameLabel.isHidden = isHidden
        
        
        if  let id = recordRow.userId,
            let userData = userDict[id]{
            
            if let  myImage = userData.imageURL{
                
                cell.userPhotoImageView.loadImageCacheWithURL(urlString:myImage)
                
            }else{
                
                cell.userPhotoImageView.image = UIImage(named: "man")
            }
            
            cell.userNameLabel.text = userData.name!
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 1:10
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "ShowRecordDetailViewController") as! ShowRecordDetailViewController
        
        if currentPage == 0{
            
            
            
            nextPage.shareDiary = recordArray[indexPath.row]
            nextPage.user = userDict[recordArray[indexPath.row].userId!]
            navigationController?.pushViewController(nextPage, animated: true)
            
        }else{
            
            if indexPath.section == 0{
                
                if servicManager.currentUser == nil{
                    
                let loginPage = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                navigationController?.pushViewController(loginPage, animated: true)
                    
                    
                }else{
                    
                let profilePage = storyboard?.instantiateViewController(withIdentifier: "PersonalFilesViewController") as! PersonalFilesViewController
                    
                    navigationController?.pushViewController(profilePage, animated: true)

                    
                    
                    
                }
                
                
            }else{
                
                nextPage.shareDiary = selfDiary[indexPath.row]
                nextPage.user = userDict[ProfileManager.standard.userUid!]
                navigationController?.pushViewController(nextPage, animated: true)
                
            }
            
        }
    }
    
}
