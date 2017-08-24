//
//  shareDiaryManager.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/4.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import UIKit

typealias DoneHandlerDiarys = (Error?,[OneDiaryRecord])->()
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
    
    convenience init(date:String) {
        self.init(food: nil, sport: nil, text: nil, date:date)
        
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
    
    var diaryId = String()
    var title = String()
    var titleImageURL = String()
    var userId = String()
    var beginDate = String()
    var timestamp = NSNumber()
    var day = NSNumber()
    var open = String()
    
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
    
    
    func dictArrayTurnDiaryItem(dict:[[String:String]]?)->[DiaryItem]?{
        
        guard let mydict = dict else{
            return nil
        }
        
        var items = [DiaryItem]()
        
        for item in mydict {
            
            let diary = DiaryItem(image: nil,
                                  title:item["title"]!,
                                  detail: item["detail"]!)
            
            diary.imageURL = item["imageURL"]
            items.append(diary)
            
        }
        
        
        return items
    }
    
    
    
    
    func getShareDiaryContent(diaryID:String,done:@escaping DoneHandlerDiarys){
        
        
        DataService.standard.dbDiaryContentURL.child(diaryID).observeSingleEvent(of:.childAdded, with: { (DataSnapshot) in
            
            var myDiarys = [OneDiaryRecord]()
            
            guard let diaryDictArray =  DataSnapshot.value as? [[String:AnyObject]] else{
                
                return
            }
            
            for diary in diaryDictArray{
                
                let foodItems = diary["foodItmes"] as?[[String:String]]
                let sportItems = diary["sportItems"] as?[[String:String]]
                let text = diary["text"] as? String
                
                guard let date = diary["date"] as? String else{
                    return
                }
                
                let da = OneDiaryRecord(food:self.dictArrayTurnDiaryItem(dict: foodItems),
                                        sport:self.dictArrayTurnDiaryItem(dict: sportItems),
                                        text: text, date:date)
                myDiarys.append(da)
                
                
            }
            
            done(nil,myDiarys)
            
            
        }){ (error) in
            
            
            print(error.localizedDescription)
            
        }
        
        
    }
    
    
    func itemsTurnDict(items:[DiaryItem]?)->[[String:String]]{
        
        var recordItems = [[String:String]]()
        
        if let myItems = items{
            
            for item in myItems {
                
                var dit = [String:String]()
                dit["title"] = item.title
                dit["detail"] = item.detail
                dit["imageURL"] = item.imageURL
                recordItems.append(dit)
            }
            
        }
        return recordItems
        
    }
    
    
    func diarysTurnDict(day:OneDiaryRecord)->[String:AnyObject]?{
        
        
        let foodItems = itemsTurnDict(items:day.food)
        
        let sportItems = itemsTurnDict(items:day.sport)
        
        
        let  text = day.text == "" ? nil: day.text
        let dict = ["foodItmes":foodItems,
                    "sportItems":sportItems,
                    "text":text,
                    "date":day.date] as [String : Any?]
        
        
        if text == nil,
           foodItems.count == 0,
           sportItems.count == 0{
            
            return nil
        }
        
        return dict as [String : AnyObject]
        
    }

    
    
    
}

























