//
//  SetUpViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/23.
//  Copyright © 2017年 Nick. All rights reserved.
//

import FBSDKLoginKit
import Firebase
import MessageUI
import UIKit

class SetUpViewController: UIViewController {
    var titleArray = ["建議與問題回報", "編輯個人資料", "清除緩存"]
    var cachesSize: Double = 0

    @IBOutlet var setUpTableView: UITableView!
    let profileManager = ProfileManager.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        actionCaches(action: .search)
    }

    override func viewWillAppear(_: Bool) {
        actionCaches(action: .search)
        setUpTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @objc func loginOrlogut(sender _: UIButton) {
        if profileManager.userUid == nil {
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            navigationController?.pushViewController(nextPage, animated: true)

        } else {
            DataService.standard.userLogOut()
            profileManager.setUserServiceDataNill()
        }

        setUpTableView.reloadData()
    }

    func actionCaches(action: ActionType) {
        guard let cachPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return
        }

        let fileArray = FileManager.default.subpaths(atPath: cachPath.path)
        var allSize: Double = 0

        guard let fileNameArray = fileArray else {
            return
        }

        for name in fileNameArray {
            if name.contains("Cache_") {
                let url = cachPath.appendingPathComponent(name)

                if action == .delete {
                    if let _ = try? FileManager.default.removeItem(at: url) {}
                } else {
                    if let folder = try? FileManager.default.attributesOfItem(atPath: url.path) {
                        allSize += folder[.size] as! Double
                    }
                }
            }
        }

        cachesSize = (allSize / 1024 / 1024)
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension SetUpViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith _: MFMailComposeResult, error _: Error?)
    {
        controller.dismiss(animated: true, completion: nil)
    }

    func configureMessage() -> MFMailComposeViewController {
        let messageVC = MFMailComposeViewController()
        messageVC.mailComposeDelegate = self
        messageVC.setSubject("App問題回報")
        messageVC.setToRecipients(["tsengwenjian@gmail.com"])
        messageVC.setMessageBody("iPhone機型：\niOS:版本號：\n回報問題：", isHTML: false)
        return messageVC
    }
}

// MARK: - UITableViewDataSource,UITableViewDelegate

extension SetUpViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in _: UITableView) -> Int {
        return 3
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return titleArray.count
        }

        return 1
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 1
        }

        return 20
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100
        } else if indexPath.section == 2 {
            return 60
        }

        return 44
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let profileCell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTableViewCell", for: indexPath) as! ProfileHeaderTableViewCell

            if profileManager.userUid == nil {
                profileCell.userNameTextField.text = "尚未登入"
                profileCell.emailLabel.text = "Log in"

            } else {
                profileCell.userNameTextField.text = profileManager.userName
                profileCell.emailLabel.text = profileManager.userEmail
            }

            profileCell.userPhoto.image = UIImage().checkUserPhoto()

            return profileCell

        } else if indexPath.section == 2 {
            let loginCell = tableView.dequeueReusableCell(withIdentifier: "LoginBtnTableViewCell", for: indexPath) as! LoginBtnTableViewCell

            var btnTitle: String
            btnTitle = DataService.standard.userUid == nil ? "登入" : "登出"
            loginCell.loginBtn.setTitle(btnTitle, for: .normal)
            loginCell.loginBtn.addTarget(self, action: #selector(loginOrlogut), for: .touchUpInside)

            return loginCell
        }

        if indexPath.row <= 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
            cell.textLabel?.text = titleArray[indexPath.row]

            return cell

        } else {
            let rightCell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            rightCell.textLabel?.text = titleArray[indexPath.row]
            rightCell.detailTextLabel?.text = "\(cachesSize.roundTo(places: 1))MB"

            return rightCell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if profileManager.userUid == nil {
                let nextPage = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                navigationController?.pushViewController(nextPage, animated: true)
            }

        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let emailVC = configureMessage()
                if MFMailComposeViewController.canSendMail() {
                    present(emailVC, animated: true, completion: nil)
                }
            } else if indexPath.row == 1 {
                let nextPage = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
                navigationController?.pushViewController(nextPage, animated: true)

            } else if indexPath.row == 2 {
                let alert = UIAlertController(title: "清除", message: "確定要清除緩存？", preferredStyle: .alert)

                let action = UIAlertAction(title: "確定", style: .default, handler: { _ in

                    self.actionCaches(action: .delete)
                    self.setUpTableView.reloadData()

                })

                let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                alert.addAction(action)
                alert.addAction(cancel)
                present(alert, animated: true, completion: nil)
            }
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }
}
