//
//  DataService.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/24.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit

typealias Done = (Error?)->()
typealias DoneUserData = ([String:AnyObject]?) ->()
typealias DoneUploadProfileImage = (String?,Error?)->()

class DataService {
    
    static  let standard = DataService()
    
    
    var currentUser:User?{
        return Auth.auth().currentUser
    }
    
    var userUid:String? {
        return currentUser?.uid
    }
    
    var dbBasicURL:DatabaseReference {
        return  Database.database().reference()
    }
    
    var dbUserURL:DatabaseReference {
        return dbBasicURL.child("users")
    }
    
    var storageProfileImageURL:StorageReference {
        return Storage.storage().reference().child("profile_images")
    }
    
    
    func userLogOut(){
        
        try? Auth.auth().signOut()
        FBSDKLoginManager().logOut()
        
    }
    
    
    func createAccount(name:String,email:String,password:String,done:@escaping Done){
        
        
        Auth.auth().createUser(withEmail:email, password:password) { (user, error) in
            
            if error != nil{
                print(error.debugDescription)
            }
            done(error)
            
            
        }
    }
    
    
    func singInWithEmail(email:String,password:String,done:@escaping Done){
        
        Auth.auth().signIn(withEmail:email, password:password) { (user, error) in
            
            if error != nil{
                print(error.debugDescription)
            }
            done(error)
            
        }
    }
    
    func longInWithFB(VC:UIViewController,done:@escaping Done){
        
        let fbLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: VC) { (result, error) in
            
            
            if let err = error {
                print(error.debugDescription)
                done(err)
                
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Fail get access token")
                done(nil)
                return
            }
            
            //製作Firebase憑證：
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            
            
            // Perform login by calling Firebase APIs
            self.singInWithCredential(cred:credential, done: { (error) in
                
                
                if let  err = error {
                    done(err)
                    return
                }
                
                
                let user = self.currentUser
                let userPhotoURL = user?.photoURL
                self.uploadUserDataToDB(userName:user?.displayName,
                                        imageURL:userPhotoURL?.absoluteString,
                                        done: { (error) in
                                            
                                            
                                            
                                            if let  err = error {
                                                
                                                done(err)
                                                
                                                return
                                            }
                                            
                                            done(nil)                                            
                })
            })
            
        }
    }
    
    
    func downlondUserDataWithLogin(done:@escaping DoneUserData){
        
        guard let uid = userUid else{
            return
        }
        
        dbUserURL.child(uid).observeSingleEvent(of:.value, with: { (Snapshot) in
            
            
            if let dict = Snapshot.value as? [String:AnyObject] {
                
                done(dict)
                
            }else{
                
                done(nil)
                
            }
        })
    }
    
    func singInWithCredential(cred:AuthCredential,done: @escaping Done){
        
        Auth.auth().signIn(with:cred, completion: { (user, error) in
            
            if error != nil{
                print(error.debugDescription)
            }
            done(error)
            
        })
        
        
    }
    
    
    
    func uploadUserDataToDB(userName:String?,imageURL:String?,done:@escaping Done){
        
        
        guard let auth = Auth.auth().currentUser else{
            done(nil)
            return
        }
        
        
        guard  let email = auth.email else{
            done(nil)
            return
        }
        
        
        var name:String = "請輸入暱稱"
        if  userName != nil {
            name = userName!
            
        }
        
        var dict = ["email":email,"name":name]
        
        if let url = imageURL{
            dict["imageURL"] = url
        }
        
        dbUserURL.child(auth.uid).updateChildValues(dict) { (error, databaseReference) in
            
            
            if error != nil{
                print(error.debugDescription)
            }
            done(error)
            
        }
    }
    
    
    func uploadProfileImage(data:Data,done:@escaping DoneUploadProfileImage){
        
        guard let uid = userUid else{
            return
        }
        
        storageProfileImageURL.child("\(uid).jpg").putData(data, metadata: nil) { (storageMetadata, error) in
            
            
            if error != nil{
                print(error.debugDescription)
            }
            done(storageMetadata?.downloadURL()?.absoluteString,error)
            
        }
    }
    
    func downloadImageSaveWithCaches(url:URL,imageName:String,done: @escaping Done){
        
        let cachesURL = FileManager.default.urls(for:.cachesDirectory, in: .userDomainMask).first
        
        guard let fullFileImageName = cachesURL?.appendingPathComponent(imageName) else{
            print("create ImageName URL error")
            return
        }
        
        let config = URLSessionConfiguration.ephemeral
        let task = URLSession(configuration: config).dataTask(with:url) { (data, response, error) in
            
            if error != nil{
                return
            }
            
            guard let imageData = data else{
                return
            }
            
            do {
                
                try imageData.write(to:fullFileImageName, options: .atomic)
                
                
            }catch{
                
                print("Fail Image write into caches")
                
            }
            
            done(error)
            
        }
        
        task.resume()
        
        
    }
    
}
