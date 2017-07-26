
//
//  AddFoodManager.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/12.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation


class AddFoodManager {
    
    let  foodTitle = ["名稱","單位","重量(g)","熱量(kcal)","蛋白質(g)","脂肪(g)",
                      "反式脂肪(g)","飽和脂肪(g)","碳水化合物(g)","膳食纖維(mg)",
                      "糖質(g)","鈉(mg)","鉀(mg)","鈣(mg)","膽固醇(mg)"]
    
    
    
    
    var foodSelect:[String?] = {
        
        var array = [String?]()
        
        for i in 0..<15{
            
            array.append(nil)
        }
        
        return array
    }()
    
    let sectionTitle = ["食物","營養"]
    
    
    
    var foodDetailKey = ["sample_name","food_unit","foodDetails_weight","calorie","protein",
                         "crude_fat","saturated_fat","trans_fats","carbohydrate","dietary_fiber",
                         "total_sugar","sodium","potassium","calcium","cholesterol"]
    
    func insertFoodDetail(){
        
        var dict = [String:String]()
        dict["food_classification"] = "'自訂'"
        
        
        var weight:Double = 0
        
        for i in 0..<foodDetailKey.count{
            
            if foodSelect[i] != nil{
                
                guard let food = foodSelect[i] else{
                    
                    return
                }
                
                if i == 2{
                    weight = Double(food)!
                }
                
                if i>2{
                    
                    let doubleFood = (Double(food)!/weight)*100
                    
                    dict[foodDetailKey[i]] = "'\(doubleFood)'"
                    
                    
                }else{
                    
                    dict[foodDetailKey[i]] = "'\(food)'"
                    
                }
                
                
            }
        }
        
        foodMaster.standard.diaryType = .foodDetail
        foodMaster.standard.insertDiary(rowInfo:dict)
        
        
    }
    
}
