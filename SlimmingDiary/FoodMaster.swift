//
//  foodDetail.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import UIKit

struct foodDiary{
    
    
    let date:String
    let dinnerTime:String
    let amount:Double
    let weight:Double
    let foodId:Int
    var image:UIImage?
    
    
    
    init(dinnerTime:String, amount:Double,weight:Double, foodId:Int){
        
        
        self.date = CalenderManager.standard.displayDateString()
        self.dinnerTime = dinnerTime
        self.amount = amount
        self.weight = weight
        self.foodId = foodId
        
    }
    
}



struct foodDetails{
    
    let foodDiaryId:Int
    let foodDetailId:Int
    let amount:Double
    let weight:Double
    let foodClassification:String
    let sampleName:String
    let foodUnit:String
    let calorie:Double
    let protein:Double
    let crudeFat:Double
    let saturatedFat:Double
    let transFats:Double
    let carbohydrate:Double
    let dietaryFiber:Double
    let totalSugar:Double
    let sodium:Double
    let potassium:Double
    let calcium:Double
    let cholesterol:Double
    var imageName:String?
    
    
    
    
    
    init(foodDiaryId:Int,foodDetailId:Int,foodClassification:String,sampleName:String,foodUnit:String,amount:Double,
         weight:Double, calorie:Double, protein:Double, crudeFat:Double, saturatedFat:Double,
         transFats:Double,carbohydrate:Double, dietaryFiber:Double, totalSugar:Double,
         sodium:Double, potassium:Double, calcium:Double,cholesterol:Double,imageName:String?){
        
        
        
        self.foodDiaryId = foodDiaryId
        self.foodDetailId = foodDetailId
        self.amount = amount
        self.weight = weight
        self.foodUnit = foodUnit
        let percentage = weight/100*amount.roundTo(places: 1)
        self.foodClassification = foodClassification
        self.sampleName = sampleName
        self.calorie = calorie*percentage
        self.protein = protein*percentage
        self.crudeFat = crudeFat*percentage
        self.saturatedFat = saturatedFat*percentage
        self.transFats = transFats*percentage
        self.carbohydrate = carbohydrate*percentage
        self.dietaryFiber = dietaryFiber*percentage
        self.totalSugar = totalSugar*percentage
        self.sodium = sodium*percentage
        self.potassium = potassium*percentage
        self.calcium = calcium*percentage
        self.cholesterol = cholesterol*percentage
        self.imageName = imageName
        
        
    }
    
    
}

enum DiaryType:String {
    
    
    case foodDetail = "Food_Detail"
    case foodDiary = "Food_Diary"
    case sportDetail = "Sport_Detail"
    case sportDiary = "Sport_Diary"
    case sportDiaryAndDetail = "Sport_Diary,Sport_Detail"
    case foodDiaryAndDetail = "Food_Diary,Food_Detail"
    case weightDiary = "Weight_Diary"
    
    
    
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

class foodMaster:DiaryManager{
    
    
    static let standard = foodMaster()
    var foodDiaryArrary = [foodDiary]()
    var switchIsOn = [Int]()
    
    

    enum FoodDetailtype {
        
        case diaryData
        case defaultData
        
        
    }
    
    func removeFoodDiarysAndSwitch(){
        foodDiaryArrary.removeAll()
        switchIsOn.removeAll()
        
    }

    func getFoodDetails(_ detailType:FoodDetailtype,
                        amount:Double?,
                        weight:Double?,
                        cond:String?,
                        order:String?)->[foodDetails]{
        
        var array = [foodDetails]()
        
        
        for food in getDiaryData(cond:cond, order:order){
            // 食物細節預設一份公克量
            var foodAmount:Double = 1
            var foodWight:Double = food["foodDetails_weight"] as! Double
            var foodDiaryId = 0
            
            
            switch detailType {
                
            case .diaryData:
                foodAmount = food["amount"] as! Double
                foodWight = food["weight"] as! Double
                foodDiaryId = food["foodDiary_id"] as! Int
                
            case .defaultData:
                break
                
                
            }
            
            if  let myAmount = amount{
                foodAmount = myAmount
                
            }
            if  let myWeight = weight{
                foodWight = myWeight
                
            }
            
            let food = foodDetails(foodDiaryId:foodDiaryId,
                                   foodDetailId:food["foodDetails_id"] as! Int,
                                   foodClassification:food["food_classification"] as! String,
                                   sampleName: food["sample_name"] as! String,
                                   foodUnit: food["food_unit"] as! String,
                                   amount:foodAmount,
                                   weight:foodWight,
                                   calorie: food["calorie"] as! Double,
                                   protein:food["protein"] as! Double,
                                   crudeFat:food["crude_fat"] as! Double,
                                   saturatedFat:food["saturated_fat"] as! Double,
                                   transFats:food["trans_fats"] as! Double ,
                                   carbohydrate:food["carbohydrate"] as! Double,
                                   dietaryFiber:food["dietary_fiber"] as! Double,
                                   totalSugar:food["total_sugar"] as! Double,
                                   sodium:food["sodium"] as! Double,
                                   potassium:food["potassium"] as! Double,
                                   calcium:food["calcium"] as! Double,
                                   cholesterol:food["cholesterol"] as! Double,
                                   imageName:food["FoodDiary_ImageName"] as? String)
            array.append(food)
            
        }
        return array
    }
    
}






