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
    
    var titleArray = ["五星鼓勵","建議與問題回報","編輯個人資料"]
    
    @IBOutlet weak var setUpTableView: UITableView!
    let manager = ProfileManager.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func  loginOrlogut(sender:UIButton){
        
        if sender.title(for: .normal) == "登入"{
            
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            navigationController?.pushViewController(nextPage, animated: true)
            
            
            
        }else{
            
          DataService.standard.userLogOut()
          manager.setUserServiceDataNill()
        }
        
        setUpTableView.reloadData()
        
    }
    

    
}
extension SetUpViewController:UITableViewDataSource,UITableViewDelegate{
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if section == 0 || section == 2{
            return 1
        }
        
        return titleArray.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        if section == 1 || section == 2{
            return 20
        }
        
        
        return 1
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
                
                
                
                
                cell.userPhoto.image = UIImage().checkUserPhoto()
                cell.userNameTextField.text = "尚未登入"
                cell.emailLabel.text = ""
                
                
                
            }else{
                
                
            cell.userPhoto.image = UIImage().checkUserPhoto()
            cell.userNameTextField.text = manager.userName
            cell.emailLabel.text = manager.userEmail
              
                
            }
            
          return cell
            
            
            
        }else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoginBtnTableViewCell", for: indexPath) as! LoginBtnTableViewCell
            
            var btnTitle:String
            
            
            if manager.userUid == nil{
                btnTitle = "登入"
                
                
            }else{
                
                btnTitle = "登出"
                
            }
            
            
            cell.loginBtn.setTitle(btnTitle, for: .normal)
            cell.loginBtn.addTarget(self, action: #selector(loginOrlogut), for:.touchUpInside)
            
            
            return cell
            
            
        }
        
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
          cell.textLabel?.text = titleArray[indexPath.row]
    
        
         return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 1{
            
            
            
            if indexPath.row == 2{
                let nextPage = storyboard?.instantiateViewController(withIdentifier: "PersonalFilesViewController") as!PersonalFilesViewController
                navigationController?.pushViewController(nextPage, animated: true)
                
                
                
            }
            
        
            
        }
      tableView.deselectRow(at: indexPath, animated: false)
        
        
    }
    
}


