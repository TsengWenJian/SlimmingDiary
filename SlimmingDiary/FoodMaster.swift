//
//  foodDetail.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import UIKit


let FOODDIARY = "FoodDiary"
let FOODDIARY_ID = "\(FOODDIARY)_Id"
let FOODDIARY_DATE = "\(FOODDIARY)_Date"
let FOODDIARY_DINNERTIME = "\(FOODDIARY)_DinnerTime"
let FOODDIARY_DETAILID = "\(FOODDIARY)_FoodDetailId"
let FOODDIARY_AMOUNT = "\(FOODDIARY)_Amount"
let FOODDIARY_WEIGHT = "\(FOODDIARY)_Weight"
let FOODDIARY_IMAGENAME = "\(FOODDIARY)_ImageName"



let FOODDETAIL = "FoodDetail"
let FOODDETAIL_Id = "\(FOODDETAIL)_Id"
let FOODDETAIL_CLASSIFICATION = "\(FOODDETAIL)_Classification"
let FOODDETAIL_SAMPLENAME = "\(FOODDETAIL)_SampleName"
let FOODDETAIL_WEIGHT = "\(FOODDETAIL)_Weight"
let FOODDETAIL_UNIT = "\(FOODDETAIL)_Unit"
let FOODDETAIL_CALORIE = "\(FOODDETAIL)_Calorie"
let FOODDETAIL_PROTEIN = "\(FOODDETAIL)_Protein"
let FOODDETAIL_CRUDEFAT = "\(FOODDETAIL)_CrudeFat"
let FOODDETAIL_SATURATEDFAT = "\(FOODDETAIL)_SaturatedFat"
let FOODDETAIL_TRANSFATS = "\(FOODDETAIL)_TransFats"
let FOODDETAIL_CARBOHYDRATE = "\(FOODDETAIL)_Carbohydrate"
let FOODDETAIL_DIETARYFIBER = "\(FOODDETAIL)_DietaryFiber"
let FOODDETAIL_TOTALSUGAR = "\(FOODDETAIL)_TotalSugar"
let FOODDETAIL_SODIUM = "\(FOODDETAIL)_Sodium"
let FOODDETAIL_POTASSIUM = "\(FOODDETAIL)_Potassium"
let FOODDETAIL_CALCIUM = "\(FOODDETAIL)_Calcium"
let FOODDETAIL_CHOLESTEROL = "\(FOODDETAIL)_Cholesterol"
let FOODDETAIL_COLLECTION = "\(FOODDETAIL)_Collection"

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
    var collection:Int?
    
    
    init(foodDiaryId:Int,foodDetailId:Int,foodClassification:String,sampleName:String,foodUnit:String,amount:Double,
         weight:Double, calorie:Double, protein:Double, crudeFat:Double, saturatedFat:Double,
         transFats:Double,carbohydrate:Double, dietaryFiber:Double, totalSugar:Double,
         sodium:Double, potassium:Double, calcium:Double,cholesterol:Double,imageName:String?,collection:Int?){
        
        
        
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
        self.collection = collection
        
        
    }
    
    
}


class FoodMaster:DiaryManager{
    
    
    static let standard = FoodMaster()
    var foodDiarys = [foodDiary]()
    var switchIsOnIDs = [Int]()
    
    
    
    
    func removeFoodDiarysAndSwitch(){
        foodDiarys.removeAll()
        switchIsOnIDs.removeAll()
        
    }
    
    func getFoodDetails(_ detailType:DetailType,
                        amount:Double?,
                        weight:Double?,
                        cond:String?,
                        order:String?)->[foodDetails]{
        
        var array = [foodDetails]()
        
        
        for food in getDiaryData(cond:cond, order:order){
            // 食物細節預設一份公克量
            var foodAmount:Double = 1
            var foodWight:Double = food[FOODDETAIL_WEIGHT] as! Double
            var foodDiaryId = 0
            
            
            switch detailType {
                
            case .diaryData:
                
               
                foodAmount = food[FOODDIARY_AMOUNT] as! Double
                foodWight = food[FOODDIARY_WEIGHT] as! Double
                foodDiaryId = food[FOODDIARY_ID] as! Int
                
                
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
                                   foodDetailId:food[FOODDETAIL_Id] as! Int,
                                   foodClassification:food[FOODDETAIL_CLASSIFICATION] as! String,
                                   sampleName: food[FOODDETAIL_SAMPLENAME] as! String,
                                   foodUnit: food[FOODDETAIL_UNIT] as! String,
                                   amount:foodAmount,
                                   weight:foodWight,
                                   calorie: food[FOODDETAIL_CALORIE] as! Double,
                                   protein:food[FOODDETAIL_PROTEIN] as! Double,
                                   crudeFat:food[FOODDETAIL_CRUDEFAT] as! Double,
                                   saturatedFat:food[FOODDETAIL_SATURATEDFAT] as! Double,
                                   transFats:food[FOODDETAIL_TRANSFATS] as! Double ,
                                   carbohydrate:food[FOODDETAIL_CARBOHYDRATE] as! Double,
                                   dietaryFiber:food[FOODDETAIL_DIETARYFIBER] as! Double,
                                   totalSugar:food[FOODDETAIL_TOTALSUGAR] as! Double,
                                   sodium:food[FOODDETAIL_SODIUM] as! Double,
                                   potassium:food[FOODDETAIL_POTASSIUM] as! Double,
                                   calcium:food[FOODDETAIL_CALCIUM] as! Double,
                                   cholesterol:food[FOODDETAIL_CHOLESTEROL] as! Double,
                                   imageName:food[FOODDIARY_IMAGENAME] as? String,
                                   collection: food[FOODDETAIL_COLLECTION] as? Int)
            array.append(food)
            
        }
        return array
    }
    
    func getTodayFoodCalorie()->Double{
        
        let cond = "Food_Diary.\(FOODDIARY_DETAILID)=\(FOODDETAIL_Id) and \(FOODDIARY_DATE) = '\(CalenderManager.standard.currentDateString())'"
        diaryType = .foodDiaryAndDetail
        let foodDetail = getFoodDetails(.diaryData, amount: nil, weight: nil, cond: cond, order: nil)
        var calorieSum:Double = 0
        
        for food in foodDetail{
            
            calorieSum += food.calorie
            
        }
        return calorieSum
    }

    
    
    func insertFoodDiary(diary:foodDiary){
        
        
        diaryType = .foodDiary
        var dict = [String:String]()
        
        
        
        
        dict = [FOODDIARY_DATE:"'\(diary.date)'",
                FOODDIARY_DINNERTIME:"'\(diary.dinnerTime)'",
                FOODDIARY_DETAILID:"\(diary.foodId)",
                FOODDIARY_AMOUNT:"\(diary.amount)",
                FOODDIARY_WEIGHT:"\(diary.weight)"]
        
        if let image = diary.image {
            
            let imageName = "food_\(image.hash)"
            image.writeToFile(imageName: imageName, search: .documentDirectory)
            dict[FOODDIARY_IMAGENAME] = "'\(imageName)'"
            
        }
        

        insertDiary(rowInfo:dict)


    }
    
    
    //MAKE: - FoodDetail
    let foodDetailTitles = ["名稱","數量","重量","熱量","蛋白質","脂肪",
                     "反式脂肪","飽和脂肪","碳水化合物","膳食纖維",
                     "糖質","鈉","鉀","鈣","膽固醇"]
    
    var foodDetailUnits = ["","","公克","大卡","公克","公克","公克",
                    "公克","公克","公克","公克","毫克","毫克","毫克","毫克"]
    
    
    var total:Double = 0
    var foodDetailImage:UIImage?
    var isCollection:Int = 0
    
    
    func getFoodDataArray(_ actionType:ActionType,foodDiaryId:Int?,foodId:Int?,amount:Double?,weight:Double?)->[String]{
        
        let foodDetail:foodDetails
        var foodDataArray = [String]()
        foodDataArray.removeAll()
        let master = FoodMaster.standard
        
        //check is collection?
        master.diaryType = .foodDetail
        let cond =  "\(FOODDETAIL_Id) = '\(foodId!)' and \(FOODDETAIL_COLLECTION) = '1'"
        let detailArray =  master.getDiaryData(cond:cond, order: nil)
        
        
        if detailArray.count >= 1{
            isCollection = 1
            
        }
        
        if(actionType == .insert){
            
            let cond = "\(FOODDETAIL_Id) = "+"\""+String(foodId!)+"\""
            

            foodDetail = master.getFoodDetails(.defaultData,
                                               amount: amount,
                                               weight: weight,
                                               cond:cond,
                                               order: nil)[0]
            
        }else{
            
            
           let cond = "Food_Diary.\(FOODDIARY_DETAILID) = \(FOODDETAIL_Id) and \(FOODDIARY_ID) = \(foodDiaryId!)"
            master.diaryType = .foodDiaryAndDetail
            foodDetail = master.getFoodDetails(.diaryData,
                                               amount:amount,
                                               weight:weight,
                                               cond:cond,
                                               order:nil)[0]
        }
        
        
        
        if let collection = foodDetail.collection{
            
             isCollection =  collection
        }else{
            isCollection = 0
        }

       
        
        foodDetailUnits[1] = foodDetail.foodUnit
        
        total =  foodDetail.protein+foodDetail.carbohydrate+foodDetail.crudeFat
        foodDetailImage = UIImage(imageName: foodDetail.imageName, search: .documentDirectory)
        
        
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
    
    
    
    // MARK : - AddFood 
    let  addFoodTitle = ["名稱","單位(杯)","重量(g)","熱量(kcal)","蛋白質(g)","脂肪(g)",
                         "反式脂肪(g)","飽和脂肪(g)","碳水化合物(g)","膳食纖維(mg)",
                         "糖質(g)","鈉(mg)","鉀(mg)","鈣(mg)","膽固醇(mg)"]
    
    
   
    
    var foodDetailKey = [FOODDETAIL_SAMPLENAME,FOODDETAIL_UNIT,FOODDETAIL_WEIGHT,
                         FOODDETAIL_CALORIE,FOODDETAIL_PROTEIN,FOODDETAIL_CRUDEFAT,
                         FOODDETAIL_SATURATEDFAT, FOODDETAIL_TRANSFATS,FOODDETAIL_CARBOHYDRATE,
                         FOODDETAIL_DIETARYFIBER,FOODDETAIL_TOTALSUGAR, FOODDETAIL_SODIUM,
                         FOODDETAIL_POTASSIUM,FOODDETAIL_CALCIUM, FOODDETAIL_CHOLESTEROL]
    
    
    
 
    
    var foodSelect:[String?] = {
        
        var array = [String?]()
        
        for i in 0..<15{
            
            array.append(nil)
        }
        
        return array
    }()
    
    
    
    func resetFoodSelect(){
        
        
        foodSelect.removeAll()
        
        for _ in 0..<15{
            
            foodSelect.append(nil)
        }

    
    }
    

    func insertFoodDetail(){
        
        var dict = [String:String]()
        dict[FOODDETAIL_CLASSIFICATION] = "'自訂'"
        
        
        var weight:Double = 0
        for i in 0..<foodDetailKey.count{
            
            guard let value = foodSelect[i] else{
                
                continue
            }
            
            if i == 2{
                
                if let myWeight = Double(value){
                    weight = myWeight
                }
                
            }
            if i>2{
                
                if let myValue = Double(value){
                    
                    let doubleFood = (myValue/weight)*100
                    dict[foodDetailKey[i]] = "'\(doubleFood)'"
                }
                
            }else{
                
                dict[foodDetailKey[i]] = "'\(value)'"
                
            }
            
        }
        
        
        FoodMaster.standard.diaryType = .foodDetail
        FoodMaster.standard.insertDiary(rowInfo:dict)
        
        
    }
    

}






