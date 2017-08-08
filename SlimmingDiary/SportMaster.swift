//
//  SportMaster.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/5.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import UIKit

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
    var sportDiaryArrary = [sportDiary]()
    var switchIsOn = [Int]()
    
    
    
    enum SportDetailtype {
        
        case diaryData
        case defaultData
        
        
    }
    
    func removeFoodDiarysAndSwitchIsON(){
        sportDiaryArrary.removeAll()
        switchIsOn.removeAll()
        
    }
    
    
    
    func getSportDetails(_ detailType:SportDetailtype,
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
                sportMinute = sport["SportDiary_Minute"] as! Int
                sportDiaryId = sport["SportDiary_Id"] as! Int
                
                if minute == nil{
                calories = sport["SportDiary_Calorie"] as? Double
                }
                
            case .defaultData:
                break
                
                
            }
            
            if  let myMinute = minute{
                sportMinute = myMinute
                
            }
            
            
            var detail = sportDetail(diaryId:sportDiaryId,
                                     detailId:sport["SportDetail_Id"] as! Int,
                                     minute:sportMinute,
                                     classification: sport["SportDetail_Classification"] as! String,
                                     sampleName: sport["SportDetail_SampleName"] as! String,
                                     imageName:sport["SportDiary_ImageName"] as? String,
                                     collection:sport["SportDetail_Collection"] as? Int,
                                     emts: sport["SportDetail_Emts"] as! Double)
            
     
            if let myCalories = calories{
                detail.calories = myCalories
            }
            
            
            array.append(detail)
            
        }
        return array
    }
    
}







