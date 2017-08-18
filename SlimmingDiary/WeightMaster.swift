//
//  WeightMaster.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/18.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation

let WEIGHTDIARY_ID = "Weight_Id"
let WEIGHTDIARY_DATE = "Weight_Date"
let WEIGHTDIARY_TIME = "Weight_Time"
let WEIGHTDIARY_TYPE = "Weight_Type"
let WEIGHTDIARY_VALUE = "Weight_Value"
let WEIGHTDIARY_PHOTO = "Weight_Photo"


struct WeightDiary {
    let id:Int?
    let date:String
    let time:String
    let type:String
    let value:Double
    let imageName:String?
    
}


enum WeightDiaryType:String {
    case weight = "體重"
    case bodyFat = "體脂"
}


class WeightMaster: DiaryManager {
    
    static let standard = WeightMaster()
    
    
    
    
    func getWeightDiary(cond:String?,order:String?)->[WeightDiary]{
        
        
        
        
        var array = [WeightDiary]()
        
        for diary in getDiaryData(cond: cond, order: order){
            
            var fullFileImageName:String
            
            
            if diary[WEIGHTDIARY_PHOTO] as? String == "No_Image"{
                
                fullFileImageName = "No_Image"
                
            }else{
                fullFileImageName = diary[WEIGHTDIARY_PHOTO] as! String
                
                
            }
            
            
            let weDiary = WeightDiary(id:diary[WEIGHTDIARY_ID] as? Int,
                                      date:diary[WEIGHTDIARY_DATE] as! String,
                                      time:diary[WEIGHTDIARY_TIME] as! String,
                                      type:diary[WEIGHTDIARY_TYPE] as! String,
                                      value:diary[WEIGHTDIARY_VALUE] as! Double,
                                      imageName:fullFileImageName)
            
            
            
            array.append(weDiary)
            
            
        }
        return array
        
        
    }
    
    func insertWeightDiary(_ diary:WeightDiary){
        
        
        
        insertDiary(rowInfo: [WEIGHTDIARY_DATE:"'\(diary.date)'",
                              WEIGHTDIARY_TIME:"'\(diary.time)'",
                              WEIGHTDIARY_TYPE:"'\(diary.type)'",
                              WEIGHTDIARY_VALUE:"'\(diary.value)'",
                              WEIGHTDIARY_PHOTO:"'\(diary.imageName ?? "No_Image")'"])
        
    }
    
    func getLasetWeightValue(_ type:WeightDiaryType)->Double?{
        
        diaryType = .weightDiary
        var cond:String
        let order = "\(WEIGHTDIARY_ID) desc limit 1"
        let day = CalenderManager.standard.displayDateString()
        cond = "\(WEIGHTDIARY_TYPE) = '\(type.rawValue)' and \(WEIGHTDIARY_DATE) = '\(day)'"
        
        
        
        if  let value = getWeightDiary(cond: cond, order: order).first?.value{
            
            return value
            
        }
        
        let cond2 = "\(WEIGHTDIARY_TYPE) = '\(type.rawValue)'"
        let order2 = "\(WEIGHTDIARY_DATE) desc ,\(WEIGHTDIARY_ID) desc limit 1"
        if  let bodyFatValue = getWeightDiary(cond: cond2, order: order2).first?.value{
            
            return bodyFatValue
            
        }
        
        return nil
    }
    
}





