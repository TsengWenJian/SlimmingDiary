//
//  TimeLineTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Firebase


class TimeLineTableViewController: UITableViewController {
    @IBOutlet var timeLineTableView: UITableView!
    
    
    var data = [OneDiaryRecord]()
    let master = foodMaster.standard
    var number = String()
    var sumItem = 0
    var trackUploadImageNumber = 0{
        didSet{
            
            if trackUploadImageNumber == sumItem{
                uploadDairyToDB(id:number)
            }
        }
    }
    
    var planTitle:String?
    var titleImage:UIImage?
    var day:Int?
    var beginDate:String?
    var toastView:NickToastUIView?
    var serviceManager = DataService.standard
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        timeLineTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        let navBarBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(uploadTitleImage))
        navigationItem.rightBarButtonItem = navBarBtn
       
        
        
        
        // uploadTitleImage
        // 先上傳前面填寫得封面照和標題等資料 /diarys
        // 在上傳全部items圖片到storage 拿到imageUrl
        // 將data轉換為dictinoary 上傳到 firebaseDB /diary-content
        
        
        
        timeLineTableView.estimatedRowHeight = 100
        timeLineTableView.rowHeight = UITableViewAutomaticDimension
        
       
        
        
        
        let calender = CalenderManager()
        var newDateComponent = DateComponents()
        newDateComponent.day = 1
        
        data = [OneDiaryRecord]()
        
        guard let myBeginDate = beginDate,
            let myDay = day else{
                return
        }
        
        
        
        //begin date
        var calculatedDate = calender.StringToDate(myBeginDate)
        
        
        for _ in 0..<myDay{
            
            
            let d = calender.dateToString(calculatedDate)
            
            
            master.diaryType = .foodDiaryAndDetail
            let cond = "Food_Diary.food_id=foodDetails_id and date = '\(d)'"
            
            
            let foodDaiays = master.getFoodDetails(.diaryData,amount:nil,weight:nil,cond: cond,order: nil)
            
            var foodItems = [DiaryItem]()
            
            
            
            for item in foodDaiays{
                
                let detail = String(format: "%0.1f",item.calorie)
                let myItem = DiaryItem(image:nil, title: item.sampleName, detail:detail)
                foodItems.append(myItem)
                
                
            }
            
            
            sumItem+=foodItems.count
            
            var sportItems = [DiaryItem]()
            
            for item in foodDaiays{
                let detail = String(format: "%0.1f",item.calorie)
                let myItem = DiaryItem(image:nil, title: item.sampleName, detail:detail)
                sportItems.append(myItem)
                
            }
            
            sumItem+=sportItems.count
            data.append(OneDiaryRecord(food:foodItems,sport: sportItems,text:""))
            calculatedDate = Calendar.current.date(byAdding:newDateComponent, to: calculatedDate)!
            
        }
        
    }
    
    func calSumItem()->Int{
        
        var sum:Int = 0
        
        for i in data{
            
            if let myFood = i.food?.count{
                sum+=myFood
            }
            if let mySport = i.sport?.count{
                sum+=mySport

                
            }
        
        }
        return sum
        
    }
    
    
    
    func uploadDiaryWithDay(diary:[OneDiaryRecord]){
        
        for i in diary{
            
            
            if let myfood = i.food {
                 uploadImageIntoStorage(items:myfood)
            }
            
            
            if let mySport = i.sport{
                
                uploadImageIntoStorage(items:mySport)
                
            }

        }
    }
    
    
    
    func chickIsEmpty(diary:[OneDiaryRecord])->Bool{
        
        var chickDiaryIsEmpty = true
        
        for i in diary{
            
            if i.food?.count != 0 || i.sport?.count != 0 || i.text != "" {
                chickDiaryIsEmpty = false
            }
            
        }
        return chickDiaryIsEmpty
        
    }
    
    
    
    func uploadTitleImage(){
        
        
         sumItem = calSumItem()
        
        if chickIsEmpty(diary:data){
        
            let alert = UIAlertController(error: "記錄為空請填寫")
            present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        
        toastView = NickToastUIView(supView: self.view, type:.Upload)
        
        let id = NSUUID().uuidString
        number = id
        
        
        guard let myTitleImage = titleImage?.resizeImage(maxLength: 1024),
            let dataImage = UIImageJPEGRepresentation(myTitleImage,0.8)else{
                return
        }
        
        
        
        
        serviceManager.storageImagesURL.child("\(id).jpg").putData(dataImage, metadata: nil) { (StorageMetadata, Error) in
            
            
            if let err = Error{
                print(err)
                self.toastView?.removefromView()
                return
            }
            
            
            guard let titleImageURL = StorageMetadata?.downloadURL()?.absoluteString,
                let userId = ProfileManager.standard.userUid,
                let myPlanTitle = self.planTitle,
                let myBeginDate = self.beginDate,
                let myday = self.day else{
                    return
                    
            }
            
            
            
            
            let timestamp:Double = Date().timeIntervalSince1970
            
            let dict = ["title":myPlanTitle,
                        "titleImageURL":titleImageURL,
                        "diayId":id,
                        "userId":userId,
                        "beginDate":myBeginDate,
                        "day":"\(myday)",
                "timestamp":"\(Int(timestamp))"]
            
            
            self.serviceManager.dbDiarysURL.childByAutoId().updateChildValues(dict) { (errpr, databaseReference) in
                
                self.uploadDiaryWithDay(diary:self.data)
                
                
            }
        }
        
    }
    
    
    func uploadImageIntoStorage(items:[DiaryItem]){
        
        
        if items.count == 0{
            toastView?.removefromView()
        }
        
        for item in items{
            
            guard let myImage = item.image,
                let data = UIImageJPEGRepresentation(myImage,0.8) else{
                    trackUploadImageNumber+=1
                    
                    continue
            }
            
            
            
            serviceManager.storageImagesURL.child("\(myImage.hash).jpg").putData(data, metadata: nil, completion: { (StorageMetadata,error) in
                
                if let err = error{
                    print(err)
                    
                    return
                }
                
                
                item.imageURL = StorageMetadata?.downloadURL()?.absoluteString
                self.trackUploadImageNumber+=1
                
            })
            
        }
    }
    
    
    
    func uploadDairyToDB(id:String){
        
        
        
        var records = [[String:AnyObject]]()
        
        
        
        for record in data{
            records.append(dataTurnDict(d:record))
            
        }
        
        
    
        serviceManager.dbDiaryContentURL.child(id).updateChildValues(["disryRecords":records]) { (error, databaseReference) in
            
            
            if let err = error{
                print(err)
                self.toastView?.removefromView()
                return
            }
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                
            }
            
            
        }
        
        
    }
    
    
    func dataTurnDict(d:OneDiaryRecord)->[String:AnyObject]{
        
        
        var dit4 = [[String:String]]()
        
        
        if let myFood = d.food{
        for i in myFood {
            
            var dit = [String:String]()
            dit["title"] = i.title
            dit["detail"] = i.detail
            dit["imageURL"] = i.imageURL
            
            dit4.append(dit)
        }
        
        }
        var dit5 = [[String:String]]()
        if let mysport = d.sport{
            
        for ii in mysport{
            var dit = [String:String]()
            dit["title"] = ii.title
            dit["detail"] = ii.detail
            dit["imageURL"] = ii.imageURL
            
            dit5.append(dit)
            
        }
        
        }
        let dict = ["foodItmes":dit4,"sportItems":dit5,"text":d.text] as [String : Any?]
        
        return dict as [String : AnyObject]
        
        
        
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let sectionDay = data[indexPath.section]
            if let cell = tableView.cellForRow(at: indexPath) as? CollectionTableViewCell{
                
                switch cell.diaryImageType {
                    
                    
                case .food:
                    sectionDay.food = nil
                    
                case .sport:
                    sectionDay.sport = nil
                    
                    
                }
            }else{
                
                
                sectionDay.text = nil
                
                
            }
            
            
            if  sectionDay.food == nil && sectionDay.sport == nil && sectionDay.text == nil{
                data.remove(at: indexPath.section)
            }
            
            tableView.reloadData()
            
            
            
        }
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        var calRow = 0
        let sectionDay = data[section]
        if sectionDay.food != nil{calRow+=1}
        if sectionDay.sport != nil{calRow+=1}
        if sectionDay.text != nil{calRow+=1}
        
        

        return calRow
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
    
        
        var calRow:Int = 0
        var foodRow:Int = 0
        
        
        if data[indexPath.section].food == nil{
            calRow += 1
            foodRow = -1
            
        }
        if data[indexPath.section].sport == nil{
            calRow += 1
            
        }
        
        
       
        let sportRow:Int = 1 - calRow
        let textRow:Int = 2 - calRow
        
        
        

        if indexPath.row == textRow{
            
            let cell = tableView.dequeueReusableCell(withIdentifier:"TextViewTableViewCell",for: indexPath) as! TextViewTableViewCell
            
            cell.oneDiary = data[indexPath.section]
            
            return cell
            
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionTableViewCell", for: indexPath) as! CollectionTableViewCell
            cell.VC = self
        
        
        if indexPath.row == foodRow {
            
            cell.diaryImageType = .food
        
            
        }else if indexPath.row == sportRow {
            
            cell.diaryImageType = .sport
        
            
        }
        
         cell.allData = data[indexPath.section]
        
        
        return cell
        
    }
    
       
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
        
        headerCell.titleLabel.text = "day\(section+1)"
        
        return headerCell.contentView
    }
    
    
    
    
    
    
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    
}



