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
    let toast  = NickToastUIView()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerTextFieldsView.setShadowView(5,0.2, CGSize.zero)
        loginBtn.layer.cornerRadius = 5
        fbLoginBtn.layer.cornerRadius = 5
        
        if Thread.isMainThread {
            print("isMainThread - isMainThread")
            
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
    }
    
    func singInWithEmail(email:String,password:String){
        
        if serviceManager.isConnectDBURL == false{
            showAlertWithError(message:notConnectInterent)
            return
        }
        
        toast.showView(supView:view,type:.logIn)
        serviceManager.singInWithEmail(email: email, password: password) { (error) in
            
            if let err = error {
                self.toast.removefromView()
                self.showAlertWithError(message:err.localizedDescription)
                
                return
            }
            
            self.serviceManager.downlondUserDataWithLogin{ (dataDict) in
                
                
                guard let dict = dataDict else{
                    return
                }
                
                self.setDataWithUserDefault(name:dict["name"] as? String,
                                            imageURLStr: dict["imageURL"] as? String)
                
            }
        }
        
    }
    
    func register(name:String,email:String,password:String){
        
        if serviceManager.isConnectDBURL == false{
            showAlertWithError(message: notConnectInterent)
            return
        }
        
        toast.showView(supView: view, type: .logIn)
        
        serviceManager.createAccount(name: name, email: email, password: password) { (error) in
            
            
            if let  err = error {
                
                self.toast.removefromView()
                self.showAlertWithError(message:err.localizedDescription)
                return
            }
            
            self.serviceManager.uploadUserDataToDB(userName: name, imageURL: nil){ (error) in
                
                
                
                if let err = error{
                    self.toast.removefromView()
                    self.showAlertWithError(message:err.localizedDescription)
                    
                    return
                    
                }
                
                self.setDataWithUserDefault(name:name,imageURLStr:nil)
            }
            
        }
    }
    
    
    @IBAction func fbBtnAction(_ sender: Any) {
        
        if serviceManager.isConnectDBURL == false{
            showAlertWithError(message: notConnectInterent)
            return
        }
        
        
        
        toast.showView(supView: self.view,type: .logIn)
        serviceManager.longInWithFB(VC:self) { (error) in
            
            if let err = error{
                self.toast.removefromView()
                self.showAlertWithError(message: err.localizedDescription)
                return
            }
            
            
            let user = self.serviceManager.currentUser
            self.setDataWithUserDefault(name:user?.displayName,
                                        imageURLStr:user?.photoURL?.absoluteString)
        }
        
    }
    
    
    func showAlertWithError(message:String){
        let alert = UIAlertController(error:message)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func setDataWithUserDefault(name:String?,imageURLStr:String?){
        
        
        guard let user = serviceManager.currentUser else{
            
            return
        }
        
        self.manager.setUid(user.uid)
        self.manager.setUserName(name)
        self.manager.setUserEmail(user.email)
        self.serviceManager.isLogin = true
        
        if let url = imageURLStr {
            
            //Save image into caches
            let photoName = "Profile_\(user.uid)"
            self.manager.setPhotName(photoName)
            serviceManager.downloadImageSaveWithCaches(URLStr:url,imageName:photoName){ (error) in
                
                DispatchQueue.main.async {
                    self.toast.removefromView()
                    self.navigationController?.popViewController(animated: true)
                    
                }
            }
            
        }else{
            
            DispatchQueue.main.async {
                self.toast.removefromView()
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
            
            
            
            
            if let myName = nameTextField.text,
                !myName.isEmpty {
                
                register(name:myName,email:email,password:password)
                
            }else{
                
                
                showAlertWithError(message:"The name is empty")
                
            }
            
            
            
        }
    }
    
    
    @IBAction func chocieSegmentAction(_ sender: UISegmentedControl) {
        
        
        var nameTop:CGFloat
        var isHidden:Bool
        if sender.selectedSegmentIndex == 1{
            
            isHidden = true
            nameTop = -nameTextField.frame.height - 20
            nameTextField.alpha = 0
            
            
            
        }else{
            nameTop = 0
            isHidden = false
            nameTextField.alpha = 1
            
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






