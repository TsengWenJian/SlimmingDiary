//
//  foodDetailManager.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/7.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation

enum ActionType{
    case update
    case insert
    

}

class foodDetailManager {
    
    
    let foodTitle = ["名稱","數量","重量","熱量","蛋白質","脂肪",
                     "反式脂肪","飽和脂肪","碳水化合物","膳食纖維",
                     "糖質","鈉","鉀","鈣","膽固醇"]
    
    var foodUnit = ["","","公克","大卡","公克","公克","公克",
                    "公克","公克","公克","公克","毫克","毫克","毫克","毫克"]
    
    
    var total:Double = 0
    
    var isCollection:Int = 0
    
    
    func getFoodDataArray(_ lastPageVC:ActionType,foodDiaryId:Int?,foodId:Int?,amount:Double?,weight:Double?)->[String]{
        
        
        
        
        let foodDetail:foodDetails
        var foodDataArray = [String]()
        foodDataArray.removeAll()
        let master = foodMaster.standard
        
        //check is collection?
        master.diaryType = .foodDetail
        let cond =  "foodDetails_id = '\(foodId!)' and collection = '1'"
        let detailArray =  master.getDiaryData(cond:cond, order: nil)
        
        
        if detailArray.count >= 1{
            isCollection = 1
            
        }
        
        
        if(lastPageVC == .insert){
            
            let cond = "foodDetails_id = "+"\""+String(foodId!)+"\""
            
            
            
            foodDetail = master.getFoodDetails(.defaultData,
                                               amount: amount,
                                               weight: weight,
                                               cond:cond,
                                               order: nil)[0]
            
        }else{
            
            let cond = "Food_Diary.food_id = foodDetails_id and foodDiary_id = \(foodDiaryId!)"
            master.diaryType = .foodDiaryAndDetail
            foodDetail = master.getFoodDetails(.diaryData,
                                               amount:amount,
                                               weight:weight,
                                               cond:cond,
                                               order:nil)[0]
        }
        
        
        foodUnit[1] = foodDetail.foodUnit
        
        total =  foodDetail.protein+foodDetail.carbohydrate+foodDetail.crudeFat
        
        
        foodDataArray.append(String(foodDetail.sampleName))
        foodDataArray.append(String(foodDetail.amount))
        foodDataArray.append(String(Int(foodDetail.weight)))
        foodDataArray.append(String(format:"%0.1f",foodDetail.calorie))
        foodDataArray.append(String(format:"%0.1f",foodDetail.protein))
        foodDataArray.append(String(format:"%0.1f",foodDetail.crudeFat))
        foodDataArray.append(String(format:"%0.1f",foodDetail.saturatedFat))
        foodDataArray.append(String(format:"%0.1f",foodDetail.transFats))
        foodDataArray.append(String(format:"%0.1f",foodDetail.carbohydrate))
        foodDataArray.append(String(format:"%0.1f",foodDetail.dietaryFiber))
        foodDataArray.append(String(format:"%0.1f",foodDetail.totalSugar))
        foodDataArray.append(String(format:"%0.1f",foodDetail.sodium))
        foodDataArray.append(String(format:"%0.1f",foodDetail.potassium))
        foodDataArray.append(String(format:"%0.1f",foodDetail.sodium))
        foodDataArray.append(String(format:"%0.1f",foodDetail.cholesterol))
        
        return foodDataArray
        
    }
    
    
    
    
}
