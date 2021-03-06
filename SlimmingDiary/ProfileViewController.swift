//
//  PersonalFilesViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/15.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    var userData = [String]() {
        didSet {
            profileTableView.reloadData()
        }
    }

    @IBOutlet var profileTableView: UITableView!

    var userPhoto: UIImage? = {
        UIImage().checkUserPhoto()
    }() {
        didSet { userPhotoIschanage = true }
    }

    var userName: String? = {
        ProfileManager.standard.userName
    }()

    var userNameTextfield: UITextField?
    let manager = ProfileManager.standard
    let serviceManager = DataService.standard
    var datePickerVC: DatePickerViewController?
    let pickerVC = PickerViewController.shared
    var currentTouchRow = 0

    var userPhotoIschanage = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let editBaritem = UIBarButtonItem(title: "存檔", style: .plain, target: self, action: #selector(editUserData))
        navigationItem.rightBarButtonItem = editBaritem

        datePickerVC = storyboard?.instantiateViewController(withIdentifier: "DatePickerViewController") as? DatePickerViewController
        datePickerVC?.delegate = self

        userData = manager.getUserData()
        pickerVC.delegate = self
        pickerVC.numberOfRows = 0
        pickerVC.numberOfComponents = 2
        pickerVC.selectRowOfbegin = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func showAlertError(error: String?) {
        let alert = UIAlertController(error: error)
        present(alert, animated: true, completion: nil)
    }

    @objc func editUserData(sender _: UIBarButtonItem) {
        // save basic body data into userDefault
        manager.setUserData(data: userData)

        // is not log in
        if serviceManager.currentUser == nil {
            navigationController?.popViewController(animated: true)

            return
        }

        userNameTextfield?.resignFirstResponder()
        let name = userNameTextfield?.text
        if name == "" || name == nil {
            showAlertError(error: "請輸入名子")

            return
        }

        // usePhoto and name is not change don't upload to service
        if !userPhotoIschanage, name == manager.userName {
            navigationController?.popViewController(animated: true)

            return
        }

        // upload userPhoto to storage and update name and photoUrl to firDB
        if let finalPhoto = userPhoto,
           let uploadData = UIImageJPEGRepresentation(finalPhoto, 0.8)
        {
            let toast = NickToastUIView()

            if let navView = navigationController?.view {
                toast.showView(supView: navView, type: .update)
            }

            if serviceManager.isConnectDBURL == false {
                showAlertError(error: notConnectInterent)
                toast.removefromView()
                return
            }

            serviceManager.uploadProfileImage(data: uploadData) { photoURL, error in

                if error != nil {
                    toast.removefromView()
                    self.showAlertError(error: error?.localizedDescription)
                    return
                }

                self.serviceManager.uploadUserDataToDB(userName: name, imageURL: photoURL, done: { error in

                    toast.removefromView()

                    if error != nil {
                        self.showAlertError(error: error?.localizedDescription)
                        return
                    }

                    guard let uid = self.manager.userUid else {
                        return
                    }

                    self.manager.setPhotName("Profile_\(uid)")
                    self.manager.setUserName(name)
                    finalPhoto.writeToFile(imageName: "Profile_\(uid)", search: .cachesDirectory)
                    self.navigationController?.popViewController(animated: true)

                })
            }
        }
    }

    func showGenderDialog() {
        let alert = UIAlertController(title: "請選擇性別", message: "", preferredStyle: .actionSheet)

        let boy = UIAlertAction(title: manager.genders[0], style: .default, handler: { _ in

            self.userData[self.currentTouchRow] = self.manager.genders[0]
        })

        let girl = UIAlertAction(title: manager.genders[1], style: .default, handler: { _ in
            self.userData[self.currentTouchRow] = self.manager.genders[1]

        })

        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(boy)
        alert.addAction(girl)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    func showLifeStyleDialog() {
        let alert = UIAlertController(title: "請選擇生活型態", message: "", preferredStyle: .actionSheet)

        let light = UIAlertAction(title: manager.liftStyles[0], style: .default, handler: { _ in

            self.userData[self.currentTouchRow] = self.manager.liftStyles[0]

        })

        let middle = UIAlertAction(title: manager.liftStyles[1], style: .default, handler: { _ in
            self.userData[self.currentTouchRow] = self.manager.liftStyles[1]

        })

        let heavy = UIAlertAction(title: manager.liftStyles[2], style: .default, handler: { _ in
            self.userData[self.currentTouchRow] = self.manager.liftStyles[2]
        })

        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alert.addAction(light)
        alert.addAction(middle)
        alert.addAction(heavy)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    @IBAction func imagePickerTapAction(_: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == false {
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.image"]
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate,UINavigationControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var image = UIImage()

        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = photo
        }

        if let myImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = myImage
        }

        picker.dismiss(animated: true, completion: nil)
        userPhoto = image.resizeImage(maxLength: 200)
        userName = userNameTextfield?.text
        profileTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource,UITableViewDelegate

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return manager.presonalTitles.count
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        if manager.userUid == nil {
            return 1
        }
        return 100
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection _: Int) -> UIView? {
        if manager.userUid == nil {
            return nil
        }

        let headerCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTableViewCell") as! ProfileHeaderTableViewCell

        headerCell.userNameTextField.text = userName
        headerCell.userPhoto.image = userPhoto
        userNameTextfield = headerCell.userNameTextField
        userNameTextfield?.delegate = self
        return headerCell.contentView
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetail", for: indexPath)
        cell.textLabel?.text = manager.presonalTitles[indexPath.row]
        cell.detailTextLabel?.text = userData[indexPath.row]

        return cell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        pickerVC.numberOfComponents = 2
        currentTouchRow = indexPath.row

        if indexPath.row == 0 {
            showGenderDialog()

        } else if indexPath.row > 0, indexPath.row <= 3 {
            pickerVC.numberOfRows = 300

            if let begin = Double(userData[indexPath.row]) {
                pickerVC.selectRowOfbegin = begin

                pickerVC.displayDialog(present: self)
            }

        } else if indexPath.row == 4 {
            datePickerVC?.displayPickViewDialog(present: self)

        } else if indexPath.row == 5 {
            showLifeStyleDialog()

        } else {
            pickerVC.numberOfComponents = 1
            pickerVC.numberOfRows = 100_000
            if let begin = Double(userData[indexPath.row]) {
                pickerVC.selectRowOfbegin = begin
                pickerVC.displayDialog(present: self)
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
}

// MARK: - DatePickerDelegate

extension ProfileViewController: DatePickerDelegate {
    func getSelectDate(date: Date) {
        let dateString = CalenderManager.standard.dateToString(date)

        userData[currentTouchRow] = dateString
    }
}

// MARK: - PickerViewDelegate

extension ProfileViewController: PickerViewDelegate {
    func getSelectRow(data: Double) {
        // today step
        if currentTouchRow == 6 {
            userData[currentTouchRow] = "\(Int(data))"
            return
        }
        userData[currentTouchRow] = "\(data)"
    }
}
