//
//  Calculate.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/16.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import UIKit

enum WeightType:String {
    case tooHeay = "過重"
    case tooLight = "過輕"
    case standard = "標準"
    case obesity  = "肥胖"
}



enum BodyFatType:String{
    
    case toolittle = "過少"
    case robust = "健碩"
    case standard = "健康"
    case tooHeight = "過高"
}




class BodyInformationManager {
    
    
    static let standard = BodyInformationManager()
    let manager = ProfileManager.standard
    var height:Double = 0
    var weight:Double = 0
    var gender:Int = 0
    

    func setBodyData(_ he:Double,_ we:Double, _ ge:Int) {
        height = he
        weight = we
        gender = ge
        
    }

    
    func getBmi()->Double{
        
        let bmi = weight/pow((height/100),2)
        return bmi
        
    }
    
    

    func getStandardWeight()->Double{
        
        var weight:Double
        
        if gender == 0{
            
            weight = (height - 70)*0.6
            
        }else{
            
            weight = (height - 80)*0.7
            
        }
        
        return weight
        
    }
    
    
    func getIdealWeight()->String{
        
        let standardWeight = getStandardWeight()
        
        let minWeight = standardWeight * (1-0.1)
        let maxWeight = standardWeight * (1+0.1)
        
        
       
        return "\(String(format:"%0.1f", minWeight))~\(String(format:"%0.1f",maxWeight))"
        
    }
    
    
    func getWeightType()->WeightType{
        
        
        
        let standardWeight = getStandardWeight()
        
        if weight <= standardWeight * 0.9{
            return .tooLight
        }
        
        if weight >= standardWeight * 1.2{
            return .obesity
        }
        
        if weight >= standardWeight * 1.1{
            
            return .tooHeay
        }
        
        return .standard
        
    }
    
    
    func getWeightTypeColor()->UIColor{
        
        let type  = getWeightType()
        var color = UIColor()
        switch type {
        case .standard:
            
            color = orestgreen
            
        case .tooHeay:
            
             color = gold
            
        case .tooLight:
            
             color = mediumseagreen
            
        case .obesity:
             color = orangered
            
        }
        return color
        
    }
    
    
    func getBodyFatTitleColor(type:BodyFatType)->UIColor{
        
        var color = UIColor()
        
        switch type {
            
        case .standard:
            
            color = orestgreen
            
        case .robust:
            
            color = orestgreen
            
        case .toolittle:
            
            color = mediumseagreen
            
        case .tooHeight:
            
            color = orangered
            
            
        }
        return color

        
    }
    
    func getIdealBodyFat()->String{
        
        if gender == 0{
            
            return "21~24"
        }
        
        return "14~17"
        
        
    }
    
    func getBodyFatType(fat:Double)->BodyFatType{
        
        if gender == 0{
            
            if fat <= 12{
                
                return .toolittle
                
            }else if fat >= 13 && fat <= 20{
                
                return .robust
                
            }else if  fat >= 21 && fat <= 24{
                
                return .standard
                
            }else{
                
                return .tooHeight
            }
        
            
        }else{
            
            
            if fat <= 4{
                
                return .toolittle
                
            }else if fat >= 5 && fat <= 13{
                
                return .robust
                
            }else if  fat >= 14 && fat <= 17{
                
                return .standard

                
            }else{
                
                return .tooHeight
            }
        }
    }
    
    
    
    func getDailyCaloriesRequired()->Double{
        
        let type = getWeightType()
        let lifeSyle = manager.userLifeStyle
        var cal:Double = 35
        
        
        if type == .tooLight{
            
            switch lifeSyle {
            case 0:
                break
            case 1:
                cal+=5
            case 2:
                cal+=10
                
            default:
                
                break
                
            }
            
        }else if type == .standard{
            
            switch lifeSyle {
                
            case 0:
                cal-=5
            case 1:
                break
            case 2:
                cal+=5
                
            default:
                break
                
            }
        }else{
            
            switch lifeSyle {
                
            case 0:
                cal-=10
            case 1:
                cal-=5
            case 2:
                break
                
            default:
                break
                
            }
            
        }
        return cal*weight
        
    }
}
