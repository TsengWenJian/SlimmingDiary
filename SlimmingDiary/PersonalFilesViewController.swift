//
//  PersonalFilesViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/15.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit


class PersonalFilesViewController: UIViewController {
    
    var userData = [String]() {
        didSet{
            personalFilesTableView.reloadData()
        }
    }
    
    @IBOutlet weak var personalFilesTableView: UITableView!
    
    var datePickerVC:DatePickerViewController!
    var pickerVC:PickerViewController!
    var userPhoto:UIImage? = {
        return UIImage().checkUserPhoto()
    }()
    
    
    var userNameTextfield:UITextField?
    
    let manager = ProfileManager.standard
    let serviceManager = DataService.standard
    
    var numberOfRows:Int = 0
    var numberOfComponents:Int = 2
    var setSelectRowOfbegin:Double = 1.0
    var currentTouchRow:Int = 0
    var userPhotoIschanage = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let editBaritem = UIBarButtonItem(title:"存檔", style:.plain, target:self, action:#selector(editUserData))
        navigationItem.rightBarButtonItem = editBaritem
        
        
        datePickerVC = storyboard?.instantiateViewController(withIdentifier: "DatePickerViewController") as! DatePickerViewController
        
        pickerVC = storyboard?.instantiateViewController(withIdentifier:"PickerViewController") as!
        PickerViewController
        
        datePickerVC.delegate = self
        pickerVC.delegate = self
        
        userData = manager.getUserData()
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func showAlertError(error:String?){
        
        
        let alert = UIAlertController(error:error)
        self.present(alert, animated: true, completion: nil)
        
    }
    

    
    func editUserData(sender:UIBarButtonItem){
        
        
        
       // is not log in
        self.manager.setUserData(data: userData)
        if manager.userUid == nil{
            self.navigationController?.popViewController(animated:true)

            return
        }

        
        userNameTextfield?.resignFirstResponder()
        let name = userNameTextfield?.text
        if name == "" || name == nil{
            showAlertError(error:"請輸入名子")
            
            return
        }
        
        
        
        //usePhoto and name is not change don't upload to service
        if !userPhotoIschanage && name == manager.userName{
            self.navigationController?.popViewController(animated:true)
            
            return
        }
        
        let uploadData = UIImageJPEGRepresentation(userPhoto!,1)
        
        
        let toast = NickToastUIView(supView: self.view, type:.Upload)
        
        serviceManager.uploadProfileImage(data:uploadData!) { (photoURL, error) in
            
            if error != nil{
                toast.removefromView()
                self.showAlertError(error:error?.localizedDescription)
                return
            }
            
            
            
            self.serviceManager.uploadUserDataToDB(userName:name,imageURL:photoURL,done: { (error) in
                
                toast.removefromView()
                
                if error != nil {
                    self.showAlertError(error:error?.localizedDescription)
                    return
                    
                }
                
                guard let uid = self.manager.userUid else{
                    return
                }
                
                self.manager.setPhotName("Profile_\(uid)")
                let cachesURL = FileManager.default.urls(for:.cachesDirectory, in: .userDomainMask).first
                let fullFileImageName = cachesURL?.appendingPathComponent("Profile_\(uid)")
                try?uploadData?.write(to: fullFileImageName!)
                self.manager.setUserName(name)
                self.navigationController?.popViewController(animated:true)
                
                
            })
            
        }
    }
    
    
    
    
    
    func showGenderDialog(){
        
        let alert = UIAlertController(title: "請選擇性別", message:"", preferredStyle:.actionSheet)
        
        let boy = UIAlertAction(title:manager.genderArray[0], style: .default, handler: { (UIAlertAction) in
            
            self.userData[self.currentTouchRow] = self.manager.genderArray[0]
        })
        
        
        let  girl = UIAlertAction(title:manager.genderArray[1], style: .default, handler: { (UIAlertAction) in
            self.userData[self.currentTouchRow] = self.manager.genderArray[1]
            
        })
        
        let  cancel = UIAlertAction(title:"取消", style:.cancel, handler:nil)
        
        
        alert.addAction(boy)
        alert.addAction(girl)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    func showLifeStyleDialog(){
        
        let alert = UIAlertController(title: "請選擇生活型態", message:"", preferredStyle:.actionSheet)
        
        let light = UIAlertAction(title:manager.liftStyleArray[0], style: .default, handler: { (UIAlertAction) in
            
            self.userData[self.currentTouchRow] = self.manager.liftStyleArray[0]
            
        })
        
        
        let  middle = UIAlertAction(title:manager.liftStyleArray[1], style: .default, handler: { (UIAlertAction) in
            self.userData[self.currentTouchRow] = self.manager.liftStyleArray[1]
            
        })
        
        let  heavy = UIAlertAction(title:manager.liftStyleArray[2], style: .default, handler: { (UIAlertAction) in
            self.userData[self.currentTouchRow] = self.manager.liftStyleArray[2]
        })
        
        let  cancel = UIAlertAction(title:"取消", style:.cancel, handler:nil)
        
        
        alert.addAction(light)
        alert.addAction(middle)
        alert.addAction(heavy)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func imagePickerTapAction(_ sender: Any) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false{
            
            return
            
        }
        
        
        let picker = UIImagePickerController()
        picker.sourceType =  .photoLibrary
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = true;
        picker.delegate = self
        present(picker, animated: true, completion: nil)
        
        
        
    }
    
}

extension PersonalFilesViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image = UIImage()
        
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage{
            image = photo
            
        }
        
        
        if let myImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = myImage
        }
        
        
        picker.dismiss(animated: true, completion: nil)
        userPhoto = image.resizeImage(maxLength:200)
        userPhotoIschanage = true
        personalFilesTableView.reloadData()
        
        
        
    }
    
}





extension PersonalFilesViewController:UITableViewDataSource,UITableViewDelegate{
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        return manager.presonalTitle.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        
        if manager.userUid == nil{
            return 1
        }
        return 100
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if manager.userUid == nil{
            return nil
        }
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTableViewCell") as! ProfileHeaderTableViewCell
        
        
        
        headerCell.userNameTextField.text = manager.userName
        headerCell.userPhoto.image = userPhoto
        userNameTextfield = headerCell.userNameTextField
        userNameTextfield?.delegate = self
        return headerCell.contentView
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetail", for: indexPath)
        cell.textLabel?.text = manager.presonalTitle[indexPath.row]
        cell.detailTextLabel?.text = userData[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currentTouchRow = indexPath.row
        if indexPath.row == 0{
            showGenderDialog()
            
        }else if indexPath.row > 0 && indexPath.row <= 3{
            
            numberOfRows = 300
            
            guard  let begin = Double(userData[indexPath.row]) else{
                return
            }
            
            setSelectRowOfbegin = begin
            pickerVC.displayPickViewDialog(present: self)
            
        }else if indexPath.row == 4 {
            
            datePickerVC.displayPickViewDialog(present: self)
            
        }else{
            
            showLifeStyleDialog()
            
        }
        
    }
    
}
extension PersonalFilesViewController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        
        
        
        
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    
    
}



extension PersonalFilesViewController:DatePickerDelegate{
    
    func getSelectDate(date: Date) {
        
        let dateString =  CalenderManager.standard.dateToString(date)
        
        
        
        userData[currentTouchRow] = dateString
        
    }
}

extension PersonalFilesViewController:PickerViewDelegate{
    
    func getSelectRow(data:Double){
        
        
        
        userData[currentTouchRow] = "\(data)"
        
        
        
    }
    
    
    
    
}


















