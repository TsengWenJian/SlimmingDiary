//
//  SportMaster.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/5.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import UIKit


let SPORTYDIARY = "SportDiary"
let SPORTYDIARY_ID = "\(SPORTYDIARY)_Id"
let SPORTYDIARY_DATE = "\(SPORTYDIARY)_Date"
let SPORTYDIARY_MINUTE = "\(SPORTYDIARY)_Minute"
let SPORTYDIARY_DETAILID = "\(SPORTYDIARY)_DetailId"
let SPORTYDIARY_IMAGENAME = "\(SPORTYDIARY)_ImageName"
let SPORTYDIARY_CALORIE = "\(SPORTYDIARY)_Calorie"


let SPORTDETAIL = "SportDetail"
let SPORTDETAIL_ID = "\(SPORTDETAIL)_Id"
let SPORTDETAIL_CLASSIFICATION = "\(SPORTDETAIL)_Classification"
let SPORTDETAIL_SAMPLENAME = "\(SPORTDETAIL)_SampleName"
let SPORTDETAIL_EMTS = "\(SPORTDETAIL)_Emts"
let SPORTDETAIL_COLLECTION = "\(SPORTDETAIL)_Collection"




struct sportDiary{
    
    
    let date:String
    let minute:Int
    let sportId:Int
    var image:UIImage?
    let calories:Double
    
    
    init(minute:Int,sportId:Int,calories:Double){
        self.date = CalenderManager.standard.displayDateString()
        self.minute = minute
        self.sportId = sportId
        self.calories = calories
        
    }
    
}



struct sportDetail{
    
    let diaryId:Int
    let detailId:Int
    let minute:Int
    let classification:String
    let sampleName:String
    var calories:Double
    let emts:Double
    var imageName:String?
    var collection:Int?
    
    
    
    
    init(diaryId:Int,detailId:Int,minute:Int,classification:String,sampleName:String,imageName:String?,collection:Int?,emts:Double) {
        
        self.emts = emts
        self.diaryId = diaryId
        self.detailId = detailId
        self.minute = minute
        self.classification = classification
        self.sampleName = sampleName
        self.calories = (ProfileManager.standard.userWeight*emts/60*Double(minute)).roundTo(places: 1)
        self.imageName = imageName
        self.collection = collection
        
        
        
    }
    
    
    
}


class SportMaster:DiaryManager{
    
    
    static let standard = SportMaster()
    var sportDiarys = [sportDiary]()
    var switchIsOnIDs = [Int]()
    
    
    
   
    
    func removeSportDiarysAndSwitchIsOn(){
        sportDiarys.removeAll()
        switchIsOnIDs.removeAll()
        
    }
    
    
    func insertWeightDiary(diary:sportDiary){
        
        diaryType = .sportDiary
        var dict = [SPORTYDIARY_DATE:"'\(diary.date)'",
            SPORTYDIARY_MINUTE:"'\(diary.minute)'",
            SPORTYDIARY_DETAILID:"'\(diary.sportId)'",
            SPORTYDIARY_CALORIE:"'\(diary.calories)'"]
        
        if let photo = diary.image{
            let finalImageName = "sport_\(photo.hash)"
            photo.writeToFile(imageName:finalImageName, search: .documentDirectory)
            dict[SPORTYDIARY_IMAGENAME] = "'\(finalImageName)'"
            
            
        }
        
        
        insertDiary(rowInfo:dict)

        
        
        
    }
    
    func getTodaySportCaloree()->Double{
        
        let cond = "Sport_Diary.\(SPORTYDIARY_DETAILID)=\(SPORTDETAIL_ID) and \(SPORTYDIARY_DATE) = '\(CalenderManager.standard.currentDateString())'"
        
        
        diaryType = .sportDiaryAndDetail
        let sportDetail = getSportDetails(.diaryData, minute: nil, cond: cond, order: nil)
        
        var calorieSum:Double = 0
        for sport in sportDetail{
            
            calorieSum += sport.calories
            
        }
        
        return calorieSum
        
    }

    
    
    func getSportDetails(_ detailType:DetailType,
                         minute:Int?,
                         cond:String?,
                         order:String?)->[sportDetail]{
        
        var array = [sportDetail]()
        
        
        
        for sport in getDiaryData(cond:cond, order:order){
            
            
            var sportMinute:Int = 30
            var sportDiaryId = 0
            var calories:Double?
            
            
            switch detailType {
                
            case .diaryData:
                sportMinute = sport[SPORTYDIARY_MINUTE] as! Int
                sportDiaryId = sport[SPORTYDIARY_ID] as! Int
                
                if minute == nil{
                    calories = sport[SPORTYDIARY_CALORIE] as? Double
                }
                
            case .defaultData:
                break
                
                
            }
            
            if  let myMinute = minute{
                sportMinute = myMinute
                
            }
            
    
            var detail = sportDetail(diaryId:sportDiaryId,
                                     detailId:sport[SPORTDETAIL_ID] as! Int,
                                     minute:sportMinute,
                                     classification: sport[SPORTDETAIL_CLASSIFICATION] as! String,
                                     sampleName: sport[SPORTDETAIL_SAMPLENAME] as! String,
                                     imageName:sport[SPORTYDIARY_IMAGENAME] as? String,
                                     collection:sport[SPORTDETAIL_COLLECTION] as? Int,
                                     emts: sport[SPORTDETAIL_EMTS] as! Double)
            
            
            if let myCalories = calories{
                detail.calories = myCalories
            }
            
            
            array.append(detail)
            
        }
        return array
    }
    
}







