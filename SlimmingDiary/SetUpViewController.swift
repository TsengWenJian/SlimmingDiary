//
//  SetUpViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/23.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
class SetUpViewController: UIViewController {
    
    var titleArray = ["五星鼓勵","建議與問題回報","編輯個人資料","清除緩存"]
    var cachesSize:Double = 0
    
    @IBOutlet weak var setUpTableView: UITableView!
    let manager = ProfileManager.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionCaches(action:.search)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        actionCaches(action:.search)
        setUpTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func  loginOrlogut(sender:UIButton){
        
        if manager.userUid == nil{
            
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            navigationController?.pushViewController(nextPage, animated: true)
            
            
            
        }else{
            
            DataService.standard.userLogOut()
            manager.setUserServiceDataNill()
            
        }
        
        setUpTableView.reloadData()
        
    }
    
    func actionCaches(action:ActionType){
        
        
        guard let cachPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else{
            return
        }
        
        let fileArray = FileManager.default.subpaths(atPath:cachPath.path)
        var allSize:Double = 0
        
        guard let fileNameArray = fileArray else{
            return
        }
        
        for name in fileNameArray{
            
            if name.contains("Cache_"){
                
                
                
                let url = cachPath.appendingPathComponent(name)
                
                if action == .delete{
                    
                    if let _ = try? FileManager.default.removeItem(at:url){
                        
                        
                    }
                }else{
                    
                    
                    if let folder = try? FileManager.default.attributesOfItem(atPath:url.path){
                        
                        allSize += folder[.size] as! Double
                        
                    }
                }
                
                
            }
        }
        
        cachesSize = (allSize/1024/1024)
        
    }
    
    
    
    
}

//MARK: - UITableViewDataSource,UITableViewDelegate
extension SetUpViewController:UITableViewDataSource,UITableViewDelegate{
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if section == 1{
            return titleArray.count
        }
        
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        if section == 0 {
            return 1
        }
        
        
        return 20
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        
        if indexPath.section == 0{
            return 100
        }else if indexPath.section == 2{
            return 60
        }
        
        return 44
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTableViewCell", for: indexPath) as! ProfileHeaderTableViewCell
            
            
            if manager.userUid == nil{
                
                cell.userNameTextField.text = "尚未登入"
                cell.emailLabel.text = ""
                
                
            }else{
                
                cell.userNameTextField.text = manager.userName
                cell.emailLabel.text = manager.userEmail
                
                
            }
            
            cell.userPhoto.image = UIImage().checkUserPhoto()
            
            return cell
            
            
            
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoginBtnTableViewCell", for: indexPath) as! LoginBtnTableViewCell
            
            
            
            var btnTitle:String
            btnTitle = manager.userUid == nil ? "登入":"登出"
            cell.loginBtn.setTitle(btnTitle, for: .normal)
            cell.loginBtn.addTarget(self, action: #selector(loginOrlogut), for:.touchUpInside)
            
            return cell
        }
        
        
        if indexPath.row <= 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.textLabel?.text = titleArray[indexPath.row]
    
            return cell
            
        }else{
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell",for:indexPath)
            cell.textLabel?.text = titleArray[indexPath.row]
            cell.detailTextLabel?.text = "\(cachesSize.roundTo(places:1))MB"
            
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 1{
            
            if indexPath.row == 2{
                let nextPage = storyboard?.instantiateViewController(withIdentifier: "PersonalFilesViewController") as!PersonalFilesViewController
                navigationController?.pushViewController(nextPage, animated: true)
                
            }else if indexPath.row == 3{
                
                let alert = UIAlertController(title: "清除", message: "確定要清除緩存？", preferredStyle:.alert)
            
                let action = UIAlertAction(title: "確定", style:.default, handler: { (UIAlertAction) in
                    
                    self.actionCaches(action:.delete)
                    self.setUpTableView.reloadData()
                    
                })
              
                let cancel = UIAlertAction(title:"取消", style: .cancel, handler: nil)
                alert.addAction(action)
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
                
                
            }
            
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        
    }
    
}


