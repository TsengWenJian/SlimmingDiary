//
//  DiaryManager.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/21.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation


enum DiaryType:String {
    
    
    case foodDetail = "Food_Detail"
    case foodDiary = "Food_Diary"
    case sportDetail = "Sport_Detail"
    case sportDiary = "Sport_Diary"
    case sportDiaryAndDetail = "Sport_Diary,Sport_Detail"
    case foodDiaryAndDetail = "Food_Diary,Food_Detail"
    case weightDiary = "Weight_Diary"

}

enum DetailType {
    
    case diaryData
    case defaultData
    
    
}

enum ActionType:String{
    case update = "修改"
    case insert = "新增"
    case delete = "刪除"
    case search = "搜尋"
    
}

class DiaryManager{
    
    var diaryType:DiaryType = .foodDiary
    
    
    func getDiaryData(cond:String?,order:String?)->[[String:Any?]]{
        
        let db = SQLiteConnect()
        if let mydb = db{
            
            return mydb.fetch2(diaryType.rawValue, cond: cond,order:order)
        }
        return [[String:Any?]]()
        
        
    }
    func deleteDiary(cond:String?){
        let db = SQLiteConnect()
        if let mydb = db{
            let _ =  mydb.delete(diaryType.rawValue, cond: cond)
        }
        
        
    }
    
    func updataDiary(cond:String?,rowInfo:[String:String]){
        let db = SQLiteConnect()
        
        if let mydb = db{
            let _ =  mydb.update(diaryType.rawValue, cond:cond,rowInfo:rowInfo)
        }
        
        
    }
    
    func insertDiary(rowInfo:[String:String]){
        
        let db = SQLiteConnect()
        let _ = db?.insert(diaryType.rawValue,rowInfo:rowInfo)
        
    }
    
    func deleteImage(imageName:String?){
        
        guard let name = imageName else{
            return
        }
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        guard let imageURL = documentURL?.appendingPathComponent(name) else{
            return
        }
        
        let _ = try? FileManager.default.removeItem(at: imageURL)
        
    }
    
    
    
}

