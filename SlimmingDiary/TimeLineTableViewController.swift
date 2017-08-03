//
//  TimeLineTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Firebase

class OneDiaryRecord {
    
    var food:[DiaryItem]?
    var sport:[DiaryItem]?
    var text:String?
    
    init(food:[DiaryItem]?,sport:[DiaryItem]?,text:String?) {
        self.food = food
        self.sport = sport
        self.text = text
    }
}


class DiaryItem:NSObject {
    
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



let titleArray = ["飲食","運動"]
let detailArray = ["",""]



class TimeLineTableViewController: UITableViewController {
    @IBOutlet var timeLineTableView: UITableView!
    
    
    var data:[OneDiaryRecord]?
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
        
        let navBarBtn = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(uploadTitleImage))
        navigationItem.rightBarButtonItem = navBarBtn
        
        // uploadTitleImage
        // 先上傳前面填寫封面照和標題 /diarys
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
            
            
            let foodDaiays = master.getFoodDetails(.diaryDate,amount:nil,weight:nil,cond: cond,order: nil)
            
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
            data?.append(OneDiaryRecord(food:foodItems, sport: sportItems,text:nil))
            calculatedDate = Calendar.current.date(byAdding:newDateComponent, to: calculatedDate)!
            
        }
        
        
    }
    
    
    
    func uploadDiaryWithDay(diary:[OneDiaryRecord]){
        
        for i in diary{
            
            guard let myfood = i.food,
                let mySport = i.sport else{
                    continue
            }
            
            uploadImageIntoStorage(items:myfood)
            uploadImageIntoStorage(items:mySport)
            
        }
    }
    
    func uploadTitleImage(){
        
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
            
            
            self.serviceManager.dbDiarysURL.childByAutoId().updateChildValues(dict) { (erroe, databaseReference) in
                
                
                
                self.uploadDiaryWithDay(diary:self.data!)
                
                
            }
        }
        
    }
    
    
    func uploadImageIntoStorage(items:[DiaryItem]){
        
        if items.count == 0{
            trackUploadImageNumber = 0
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
        
        for record in data!{
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
        
        for i in d.food! {
            
            var dit = [String:String]()
            dit["title"] = i.title
            dit["detail"] = i.detail
            dit["imageURL"] = i.imageURL
            
            dit4.append(dit)
        }
        
        
        var dit5 = [[String:String]]()
        
        for ii in d.sport!{
            var dit = [String:String]()
            dit["title"] = ii.title
            dit["detail"] = ii.detail
            dit["imageURL"] = ii.imageURL
            
            dit5.append(dit)
            
        }
        
        
        let dict = ["foodItmes":dit4,"sportItems":dit5,"text":d.text ?? "nil"] as [String : Any]
        
        return dict as [String : AnyObject]
        
        
        
    }
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return (data?.count)!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        
        if indexPath.row == 2{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewTableViewCell", for: indexPath) as! TextViewTableViewCell
            
            cell.oneDiary = data?[indexPath.section]
            return cell
            
        }
        
        
        
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionTableViewCell", for: indexPath) as! CollectionTableViewCell
        
        cell.titleLabel.text = titleArray[indexPath.row]
        
        
        
        if indexPath.row == 0{
            
            
            
            let text:String = calSumCalorie(items:data?[indexPath.section].food)
            cell.detailLabel.text = "攝取\(text)大卡"
            cell.data = (data?[indexPath.section].food)!
            cell.diaryImageType = .food
        }
        
        
        
        if indexPath.row == 1{
            cell.diaryImageType = .sport
            
            let text:String = calSumCalorie(items:data?[indexPath.section].sport)
            cell.detailLabel.text = "消耗 \(text)大卡"
            cell.data = (data?[indexPath.section].sport!)!
        }
        
        
        cell.VC = self
        
        
        
        return cell
    }
    
    
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
    
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
        
        headerCell.titleLabel.text = "day\(section+1)"
        
        return headerCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    
    
}



