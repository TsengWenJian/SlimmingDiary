//
//  LoginViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/22.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var nameTextFieldTop: NSLayoutConstraint!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var passWordTextFiled: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var choiceLoginSegmented: UISegmentedControl!
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var containerTextFieldsView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    let manager = ProfileManager.standard
    let serviceManager = DataService.standard
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerTextFieldsView.setShadowView(5,0.2, CGSize.zero)
        loginBtn.layer.cornerRadius = 5
        fbLoginBtn.layer.cornerRadius = 5
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
    }
    
    func singInWithEmail(email:String,password:String){
        
        if serviceManager.isConnectDBURL == false{
            showAlertWithError(message:NO_CONNECTINTENTER)
            return
        }
        
        let toast  = NickToastUIView(supView:view, type:.logIn)
          serviceManager.singInWithEmail(email: email, password: password) { (error) in
            
            if let err = error {
                toast.removefromView()
                self.showAlertWithError(message:err.localizedDescription)
                
                return
            }
            
            self.serviceManager.downlondUserDataWithLogin(done: { (dataDict) in
                
                
                guard let dict = dataDict else{
                    return
                }
                
                var photoURL:URL?
                
                if let imageURLString = dict["imageURL"] as? String{
                    photoURL = URL(string:imageURLString)
                    
                }
                
                
                self.setDataWithUserDefault(name:dict["name"] as? String,
                                            imageURL:photoURL,toast:toast)
                
            })
        }
        
    }
    
    func register(name:String,email:String,password:String){
        
        if serviceManager.isConnectDBURL == false{
            showAlertWithError(message: NO_CONNECTINTENTER)
            return
        }
        
        let toast  = NickToastUIView(supView: view, type: .logIn)
        
        serviceManager.createAccount(name: name, email: email, password: password) { (error) in
            
            
            
            if let  err = error {
                
                toast.removefromView()
                self.showAlertWithError(message:err.localizedDescription)
                return
            }
            
            self.serviceManager.uploadUserDataToDB(userName: name, imageURL: nil, done: { (error) in
                
                
                
                if let err = error{
                    toast.removefromView()
                    self.showAlertWithError(message:err.localizedDescription)
                    
                    return
                    
                }
                
                self.setDataWithUserDefault(name:name,imageURL:nil,toast: toast)
            })
            
        }
    }
    
    
    @IBAction func fbBtnAction(_ sender: Any) {
        
        if serviceManager.isConnectDBURL == false{
            showAlertWithError(message: NO_CONNECTINTENTER)
            return
        }

        
        
        let toast = NickToastUIView(supView: self.view, type: .logIn)
        serviceManager.longInWithFB(VC: self) { (error) in
            
            if let err = error{
                toast.removefromView()
                self.showAlertWithError(message: err.localizedDescription)
                return
            }
            
            let user = self.serviceManager.currentUser
            self.setDataWithUserDefault(name:user?.displayName,
                                        imageURL:user?.photoURL, toast: toast)
        }
        
    }

    
    func showAlertWithError(message:String){
        let alert = UIAlertController(error:message)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func setDataWithUserDefault(name:String?,imageURL:URL?,toast:NickToastUIView){
        
        
        
        //check is real login
        guard let user = serviceManager.currentUser else{
            
            return
        }
        
        
        self.manager.setUid(user.uid)
        self.manager.setUserName(name)
        self.manager.setUserEmail(user.email)
        self.serviceManager.isLogin = true
        
        if let url = imageURL {
            
            //Save image into caches
            let photoName = "Profile_\(user.uid)"
            self.manager.setPhotName(photoName)
            serviceManager.downloadImageSaveWithCaches(url:url,imageName:photoName,done: { (error) in
                
                
                DispatchQueue.main.async {
                    toast.removefromView()
                    self.navigationController?.popViewController(animated: true)
                    
                }
            })
            
        }else{
            
            DispatchQueue.main.async {
                toast.removefromView()
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        
    }
    
    
    
    @IBAction func loginBtnAction(_ sender: Any) {
        
        
        guard let email = emailTextField.text,
            let password = passWordTextFiled.text else{
                
                return
        }
        
        // login
        if choiceLoginSegmented.selectedSegmentIndex == 1{
            
            singInWithEmail(email:email,password:password)
            
            
        }else{
            
            let name = nameTextField.text
            
            
            if   name == "" ||  name == nil{
                showAlertWithError(message:"The name is empty")
                
                return
            }
            
            
            guard let myName = name else{
                return
            }
        
            register(name:myName,email:email,password:password)
            
        }
    }
    
    
    @IBAction func chocieSegmentAction(_ sender: UISegmentedControl) {
        
        
        var nameTop:CGFloat
        var isHidden:Bool
        if sender.selectedSegmentIndex == 1{
            
            isHidden = true
            nameTop = -nameTextField.frame.height - 21
            nameTextField.alpha = 0
            fbLoginBtn.isHidden = false
            
            
        }else{
            nameTop = 0
            isHidden = false
            nameTextField.alpha = 1
            fbLoginBtn.isHidden = true
        }
        
        UIView.animate(withDuration:0.2, delay: 0, options:[.curveEaseInOut], animations: {
            self.nameTextFieldTop.constant = nameTop
            self.view.layoutIfNeeded()
        }, completion: { (Bool) in
            
            self.nameTextField.isHidden = isHidden
            
        })
    }
}
//MAKE: -UITextFieldDelegate
extension LoginViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    
}






