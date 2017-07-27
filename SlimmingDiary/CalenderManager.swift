//
//  Calender.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/8.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation

struct MyDate {
    
    var year: Int
    var month: Int
    var day: Int
}

enum MonthType {
    case previous
    case next
    case current
}
enum DayType {
    case today
    case displayDay
    case afterDay
    case none
    
}

class CalenderManager{
    
    
    static let  standard = CalenderManager()
    
    
    let weekArray = ["日", "一", "二","三", "四", "五", "六"]
    var displayDate: MyDate = MyDate(year: 2000, month: 1, day: 1){
        didSet{
         displayMonth = displayDate
            
                   }
    }
    var displayMonth:MyDate = MyDate(year: 2000, month: 1, day: 1)
    var currentDate: MyDate = MyDate(year: 2000, month: 1, day: 1)
   
    var displayCalenderAction:Bool = false
    
    init() {
        let currentCalendar = Calendar.current
        var comp = currentCalendar.dateComponents([.year, .month, .day], from:Date())
        guard let year = comp.year, let month = comp.month ,let day = comp.day else{
            return
        }
        self.displayDate = MyDate(year: year, month:month, day:day)
        self.currentDate = MyDate(year: year, month:month, day:day)
        self.displayMonth = MyDate(year: year, month:month, day:1)
   
    }
    
    
    
    
    
    func getFirstWeekDayInThisMonth(comp:DateComponents) -> Int {
        
        
        let calendar = Calendar.current
        let offset = TimeZone.current.secondsFromGMT()
        let date = Date(timeInterval:TimeInterval(offset), since: calendar.date(from:comp)!)
        let dateComponent = calendar.dateComponents([.weekday], from: date)
        return dateComponent.weekday!
    }
    
    
    func changeDisplayDate(_ type: MonthType){
        switch type {
            
        case .previous:
            displayDate.day -= 1
            if displayDate.day <= 0 {
                displayDate.month -= 1
                displayDate.day = getTotalDaysInMonth(comp: getMonthComponent(.current))
                if displayDate.month <= 0 {
                    displayDate.month = 12
                    displayDate.year -= 1
                }
            }
        case .next:
            displayDate.day += 1
            if  displayDate.day > getTotalDaysInMonth(comp:getMonthComponent(.current)){
                displayDate.day = 1
                displayDate.month += 1
                if displayDate.month >= 13 {
                    displayDate.month = 1
                    displayDate.year += 1
                }
            }
        case .current:
            break
        }
        
    }
    
    
    
    
    func getTotalDaysInMonth(comp:DateComponents)->Int{
        
        let calendar = Calendar.current
        let date = calendar.date(from:comp)!
        let range = calendar.range(of:.day, in: .month, for: date)
        
        return (range?.count)!
        
        
    }
    //拿到每個月1號的datacomponent
    func getMonthComponent(_ type: MonthType) -> DateComponents {
        switch type {
        case .previous:
            displayMonth.month -= 1
            if displayMonth.month <= 0 {
                displayMonth.month = 12
                displayMonth.year -= 1
            }
        case .next:
            displayMonth.month += 1
            if displayMonth.month >= 13 {
                displayMonth.month = 1
                displayMonth.year += 1
            }
        case .current:
            break
            
            
        }
       
        var dateComponent =  myDateToDateComponet(myDate:displayMonth)
        
      
        dateComponent.day = 1
        return dateComponent
    }
    
    
    func getMonthTotalDaysArray(type:MonthType)->[String]{
        let monthComponent = getMonthComponent(type)
        let firstDay:Int = getFirstWeekDayInThisMonth(comp:monthComponent)
        let totalDay:Int = getTotalDaysInMonth(comp: monthComponent)
        let  item = Int(ceil(Double(firstDay-1+totalDay)/Double(7)))*7
        
        var myArray = [String]()
        
        for i in 1...item{
            
            
            if i < Int(firstDay){
                
                myArray.append("")
                
            }else if i > totalDay + Int(firstDay-1){
                
                myArray.append("")
            }else{
                myArray.append(String(i-Int(firstDay-1)))
            }
        }
        return myArray
    }
    
    
    
       func myDateToDateComponet(myDate:MyDate)->DateComponents{
        
        var dateComponent = DateComponents()
        dateComponent.year = myDate.year
        dateComponent.month = myDate.month
        dateComponent.day = myDate.day
        
         return dateComponent
        
    }
    
    func dateToString(_ date:Date)->String{
        
        let formmater = DateFormatter()
        formmater.dateFormat = "YYYY-MM-dd"
        
        
        return formmater.string(from: date)
        
    }
    
    func displayDateString()->String{
        
       return myDateToString(displayDate)
    }
    
    func currentDateString()->String{
        return myDateToString(currentDate)
    }
    
    func getCurrentTime()->String{
        
        let formmater = DateFormatter()
        formmater.dateFormat = "HH:mm"
        return formmater.string(from:Date())

        
    }
    
    
    
    
    
    func myDateToString(_ myDate:MyDate)->String{
        
    
        return "\(myDate.year)-\(myDate.month)-\(myDate.day)"
        
    }
   
    
    func checkDayType(date:MyDate)->DayType{
        
        
         if displayDate.day == date.day && date.year == displayDate.year && date.month == displayDate.month{
            
            return DayType.displayDay
            
         }else  if date.year == currentDate.year && currentDate.day == date.day && currentDate.month == date.month{
                
                return DayType.today
        }else{
            
            
            
            if isAfterCurrentDay(date:date) {
                
                return DayType.afterDay
            }else{
                
                return DayType.none
            }
            
        }
        
        
    }
    
    func isAfterCurrentDay(date:MyDate)->Bool{
        
        
        let displayDateInt:Int = date.year*10000 + date.month*100 + date.day
        let currentDateInt: Int = currentDate.year*10000 + currentDate.month*100 + currentDate.day
        
        if displayDateInt > currentDateInt {
            
            return true
        }else{
            
            return false
        }

        
        
    }
    
    
    
    
}

