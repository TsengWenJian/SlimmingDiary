//
//  PersonalFilesManager.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/15.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation



class ProfileManager {
    
    
    static let standard = ProfileManager()
    
    let liftStyleArray = ["靜態或坐的工作","站立活動較多的工作","重度使用體力之工作"]
    let genderArray = ["女姓","男性"]
    let presonalTitle = ["性別","身高","體重","目標體重","生日","生活型態"]
    
    
    var isInputDone:Bool{
        return  UserDefaults.standard.bool(forKey:"isInuptDone")
    }
    
    
    var userHeight:Double{
        return  UserDefaults.standard.double(forKey: "height")
        
    }
    
    var userWeight:Double{
        return UserDefaults.standard.double(forKey: "weight")
    }
    
    var userBirthday:String?{
        return UserDefaults.standard.string(forKey: "birthday")
    }
    
    var userLifeStyle:Int{
        return UserDefaults.standard.integer(forKey: "lifeStyle")
    }
    
    var userGender:Int{
        return UserDefaults.standard.integer(forKey: "gender")
        
    }
    
    var userTargetWeight:Double{
        return  UserDefaults.standard.double(forKey: "targetWeight")
        
    }
    
    
    var userOriginWeight:Double{
        return  UserDefaults.standard.double(forKey: "originWeight")
    }
    
    var userEmbraveText:String?{
        return  UserDefaults.standard.string(forKey:"embraveText")
    }
    
    
    
    var userUid:String?{
        return  UserDefaults.standard.string(forKey:"uid")
    }
    
    
    
    var userName:String?{
        return  UserDefaults.standard.string(forKey:"name")
    }
    var userPhotoName:String?{
        
        return UserDefaults.standard.string(forKey:"photo")
    }
    var userEmail:String?{
        
        
        return UserDefaults.standard.string(forKey:"email")
        
    }
    
    
    
    
    
    //MARK : - Function setUserDefault
    
    func setUserEmail(_ email:String?){
        
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.synchronize()
        
        
    }

    
    
    func setPhotName(_ path:String?){
        
        UserDefaults.standard.set(path, forKey: "photo")
        UserDefaults.standard.synchronize()
        
        
    }
    
    
    
    func setUserName(_ name:String?){
        
        UserDefaults.standard.set(name, forKey: "name")
        UserDefaults.standard.synchronize()
    }
    
    func setUid(_ uid:String?){
        
        UserDefaults.standard.set(uid, forKey: "uid")
        UserDefaults.standard.synchronize()
    }
    
    
    func setUserHeight(_ height:Double){
        
        UserDefaults.standard.set(height, forKey: "height")
        UserDefaults.standard.synchronize()
    }
    
    func setUserWeight(_ weight:Double){
        
        UserDefaults.standard.set(weight, forKey: "weight")
        UserDefaults.standard.synchronize()
    }
    
    func setUserBirthday(_ birthday:String){
        
        UserDefaults.standard.set(birthday, forKey: "birthday")
        UserDefaults.standard.synchronize()
    }
    
    func setUserTargetWeight(_ targetWeight:Double){
        
        UserDefaults.standard.set(targetWeight, forKey: "targetWeight")
        UserDefaults.standard.synchronize()
    }
    
    func setUserOriginWeight(_ originWeight:Double){
        UserDefaults.standard.set(originWeight, forKey: "originWeight")
        UserDefaults.standard.synchronize()
    }
    
    func setUserlifeStyle(_ lifeStyle:Int){
        
        UserDefaults.standard.set(lifeStyle, forKey: "lifeStyle")
        UserDefaults.standard.synchronize()
    }
    
    func setUserGender(_ gender:Int){
        
        UserDefaults.standard.set(gender, forKey: "gender")
        UserDefaults.standard.synchronize()
    }
    
    func setUserIsInputDone(_ done:Bool){
        
        UserDefaults.standard.set(done,forKey:"isInuptDone")
        UserDefaults.standard.synchronize()
    }
    
    
    func setUserEmbrave(_ text:String){
        
        UserDefaults.standard.set(text,forKey:"embraveText")
        UserDefaults.standard.synchronize()
        
        
    }
    
    
    
    
    
    func getUserData()->[String]{
        
        var userArray = [String]()
        userArray.append(genderArray[userGender])
        userArray.append(String(userHeight))
        userArray.append(String(userWeight))
        userArray.append(String(userTargetWeight))
        
        if let bir = userBirthday{
            
            userArray.append(bir)
        }else{
             userArray.append("2001-01-01")
        }
        
        userArray.append(liftStyleArray[userLifeStyle])
        userArray.append(String(userHeight))
        
        return userArray
        
        
    }
    
    func setUserData(data:[String]){
        
        
        guard  let gender = genderArray.index(of: data[0]),
               let height = Double(data[1]),
               let weight = Double(data[2]),
               let targetWeight = Double(data[3]),
               let liftStyle = liftStyleArray.index(of: data[5])else{
            return
        }
        
        
        setUserGender(gender)
        setUserHeight(height)
        setUserWeight(weight)
        setUserTargetWeight(targetWeight)
        setUserBirthday(data[4])
        setUserlifeStyle(liftStyle)
        

    }
    
    
    
    
    func setUserServiceDataNill(){
        setUserEmail(nil)
        setUid(nil)
        setPhotName(nil)
        setUserName(nil)
    }
 }
