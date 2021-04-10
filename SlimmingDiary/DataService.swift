//
//  DataService.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/24.
//  Copyright © 2017年 Nick. All rights reserved.
//

import FBSDKLoginKit
import Firebase
import Foundation

typealias Done = (Error?) -> Void
typealias DoneUserData = ([String: AnyObject]?) -> Void
typealias DoneUploadProfileImage = (String?, Error?) -> Void
let fireBaseDBURL = "https://simmingdiary-75e3b.firebaseio.com"
let notConnectInterent = "無法取的網際網路"
var reachability = Reachability(hostName: fireBaseDBURL)

enum ServiceDBKey {
    static let diaryBeginDate = "beginDate"
    static let diaryDay = "day"
    static let diaryID = "diaryId"
    static let diaryOpen = "open"
    static let diaryTimeStamp = "timestamp"
    static let diaryTitle = "title"
    static let diaryImageURL = "titleImageURL"
    static let diaryUserID = "userId"

    static let foodItmes = "foodItmes"
    static let sportItems = "sportItems"
    static let text = "text"
    static let date = "date"
    static let itemTitle = "title"
    static let itemDetail = "detail"
    static let itemImageURL = "imageURL"

    static let userName = "name"
    static let userImageURL = "imageURL"
    static let userEmail = "email"
}

class DataService {
    static let standard = DataService()

    var isConnectDBURL: Bool {
        guard let reach = reachability else {
            return false
        }
        return reach.checkInternetFunction()
    }

    var currentUser: User? {
        return Auth.auth().currentUser
    }

    var isLogin: Bool = { Auth.auth().currentUser == nil ? false : true }() {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loginStatus"),
                                            object: nil)
        }
    }

    var userUid: String? {
        return currentUser?.uid
    }

    var dbBasicURL: DatabaseReference {
        return Database.database().reference()
    }

    var dbUserURL: DatabaseReference {
        return dbBasicURL.child("users")
    }

    var dbDiarysURL: DatabaseReference {
        return dbBasicURL.child("diarys")
    }

    var dbDiaryContentURL: DatabaseReference {
        return dbBasicURL.child("diary-content")
    }

    var dbUserDiaryURL: DatabaseReference {
        return dbBasicURL.child("user-diary")
    }

    var storageProfileImageURL: StorageReference {
        return Storage.storage().reference().child("profile_images")
    }

    var storageImagesURL: StorageReference {
        return Storage.storage().reference().child("images")
    }

    var storageTitleImagesURL: StorageReference {
        return Storage.storage().reference().child("titleImage")
    }

    func userLogOut() {
        if let uid = userUid {
            dbUserDiaryURL.child(uid).removeAllObservers()
        }
        try? Auth.auth().signOut()
        FBSDKLoginManager().logOut()
        isLogin = false
    }

    func createAccount(name _: String, email: String, password: String, done: @escaping Done) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in

            if error != nil {
                SHLog(message: error.debugDescription)
            }
            done(error)
        }
    }

    func singInWithEmail(email: String, password: String, done: @escaping Done) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in

            if error != nil {
                SHLog(message: error.debugDescription)
            }
            done(error)
        }
    }

    func longInWithFB(VC: UIViewController, done: @escaping Done) {
        let fbLoginManager = FBSDKLoginManager()

        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: VC) { _, fbErr in

            if let myFbErr = fbErr {
                done(myFbErr)

                return
            }

            guard let accessToken = FBSDKAccessToken.current() else {
                SHLog(message: "Fail get access token")
                done(NSError(domain: "", code: 0, userInfo: nil))
                return
            }

            // 製作Firebase憑證：
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)

            Auth.auth().signIn(with: credential, completion: { user, signErr in

                if let mySignErr = signErr {
                    done(mySignErr)
                }

                let user = self.currentUser
                let userPhotoURLStr = user?.photoURL?.absoluteString

                self.uploadUserDataToDB(userName: user?.displayName, imageURL: userPhotoURLStr) { uploadErr in

                    if let myUploadErr = uploadErr {
                        done(myUploadErr)
                    }

                    done(nil)
                }

            })
        }
    }

    func downlondUserDataWithLogin(done: @escaping DoneUserData) {
        guard let uid = userUid else {
            return
        }

        dbUserURL.child(uid).observeSingleEvent(of: .value, with: { Snapshot in

            if let dict = Snapshot.value as? [String: AnyObject] {
                done(dict)

            } else {
                done(nil)
            }
        })
    }

    func uploadUserDataToDB(userName: String?, imageURL: String?, done: @escaping Done) {
        guard let auth = Auth.auth().currentUser else {
            done(nil)
            return
        }

        guard let email = auth.email else {
            done(nil)
            return
        }

        var name: String = "請輸入暱稱"
        if userName != nil {
            name = userName!
        }

        var dict = [ServiceDBKey.userEmail: email, ServiceDBKey.userName: name]

        if let url = imageURL {
            dict[ServiceDBKey.userImageURL] = url
        }

        dbUserURL.child(auth.uid).updateChildValues(dict) { error, _ in

            if error != nil {
                SHLog(message: error.debugDescription)
            }
            done(error)
        }
    }

    func uploadProfileImage(data: Data, done: @escaping DoneUploadProfileImage) {
        guard let uid = userUid else {
            return
        }
        let time = Date().timeIntervalSince1970
        let finalImageName = "\(Int(time))_\(uid)"

        storageProfileImageURL.child("\(finalImageName).jpg").putData(data, metadata: nil) { storageMetadata, error in

            if error != nil {
                SHLog(message: error.debugDescription)
            }
            done(storageMetadata?.downloadURL()?.absoluteString, error)
        }
    }

    func downloadImageSaveWithCaches(URLStr: String, imageName: String, done: @escaping Done) {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first

        guard let fullFileImageName = cachesURL?.appendingPathComponent(imageName),
              let URL = URL(string: URLStr)
        else {
            SHLog(message: "create ImageName URL error")

            return
        }

        let config = URLSessionConfiguration.ephemeral
        let task = URLSession(configuration: config).dataTask(with: URL) { data, _, error in

            if error != nil {
                done(error)
                return
            }

            guard let imageData = data else {
                return
            }

            do {
                try imageData.write(to: fullFileImageName, options: .atomic)

            } catch {
                SHLog(message: "Fail Image write into caches")
            }

            done(nil)
        }

        task.resume()
    }
}
