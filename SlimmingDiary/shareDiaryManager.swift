//
//  shareDiaryManager.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/4.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import UIKit


class OneDiaryRecord:NSObject{
    
    var food:[DiaryItem]?
    var sport:[DiaryItem]?
    var text:String?
    var date:String
    
    init(food:[DiaryItem]?,sport:[DiaryItem]?,text:String?,date:String) {
        self.food = food
        self.sport = sport
        self.text = text
        self.date = date
    }
}


class DiaryItem {
    
    var image:UIImage?
    var imageURL:String?
    var title:String
    var detail:String
    
    
    
    
    init(image:UIImage?,title:String,detail:String) {
        self.image = image
        self.title = title
        self.detail = detail
        
    }
    
}

class ShareDiary:NSObject {
    
    var diaryId:String?
    var title:String?
    var titleImageURL:String?
    var userId:String?
    var beginDate:String?
    var timestamp:NSNumber?
    var day:NSNumber?
    var open:String?
    
}

class UserData: NSObject {
    
    var name:String?
    var imageURL:String?
    
    
}




class shareDiaryManager {
    
    static let standard = shareDiaryManager()
    
    func calSumCalorie(items:[DiaryItem]?)->String{
        
        var sum:Double = 0
        guard let myItems = items else {
            return "0"
        }
        
        for i in myItems{
            sum += Double(i.detail)!
            
        }
        
        return String(format: "%1.f", sum)
        
    }

    
}

























