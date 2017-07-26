//
//  WeightMaster.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/18.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation

struct WeightDiary {
    let id:Int?
    let date:String
    let time:String
    let type:String
    let value:Double
    let photo:String?
    
}







enum WeightDiaryType:String {
    case weight = "體重"
    case bodyFat = "體脂"
}
class WeightMaster: DiaryManager {
    
    static let standard = WeightMaster()
    
    

    
    func getWeightDiary(cond:String?,order:String?)->[WeightDiary]{
        
        
    
        
        var array = [WeightDiary]()
        
        let cachesURL = FileManager.default.urls(for:.cachesDirectory, in: .userDomainMask).first
        
        
        
        for diary in getDiaryData(cond: cond, order: order){
            
            var fullFileImageName:String
            
            
            
            

            
            if diary["Weight_Photo"] as? String == "No_Image"{
                
                fullFileImageName = "No_Image"
                
            }else{
                fullFileImageName = diary["Weight_Photo"] as! String
                
                
            }
            
           
            
            
            
            let weDiary = WeightDiary(id:diary["Weight_Id"] as? Int,
                                      date:diary["Weight_Date"] as! String,
                                      time:diary["Weight_Time"] as! String,
                                      type:diary["Weight_Type"] as! String,
                                      value:diary["Weight_Value"] as! Double,
                                      photo:fullFileImageName)
            
            
            
            array.append(weDiary)
            
            
        }
        return array
        
        
    }
    
    func insertWeightDiary(_ diary:WeightDiary){
        
        
        
        insertDiary(rowInfo: ["Weight_Date":"'\(diary.date)'",
            "Weight_Time":"'\(diary.time)'",
            "Weight_Type":"'\(diary.type)'",
            "Weight_Value":"'\(diary.value)'"
            ,"Weight_Photo":"'\(diary.photo ?? "No_Image")'"])
        
    }

    func getLasetWeightValue(_ type:WeightDiaryType)->Double?{
        
        diaryType = .weightDiary
        var cond:String
        let order = "Weight_Id desc limit 1"
        let day = CalenderManager.standard.displayDateString()
        cond = "Weight_Type = '\(type.rawValue)' and Weight_Date = '\(day)'"
        
        
        
        if  let value = getWeightDiary(cond: cond, order: order).first?.value{
            
            print(value)
            print("======")
            return value
            
        }
        
        let cond2 = "Weight_Type = '\(type.rawValue)'"
        let order2 = "Weight_Date desc ,Weight_Id desc limit 1"
        if  let bodyFatValue = getWeightDiary(cond: cond2, order: order2).first?.value{
            
            return bodyFatValue
            
        }
        
        
        return nil
    }
    
}





