//
//  MakeShareDiaryTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Firebase


class MakeShareDiaryTableViewController: UITableViewController {
    @IBOutlet var timeLineTableView: UITableView!
    
    
    var diarys = [OneDiaryRecord]()
    let master = foodMaster.standard
    let sportMaster = SportMaster.standard
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
    var isLocked:Bool = false
    var sectionsIsExpend = [Bool]()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        timeLineTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        let navBarBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(uploadTitleImage))
        let ui = UIImage(named:"unlocked")
        
        let btn = UIBarButtonItem(image:ui, style: .plain, target: self, action: #selector(open))
        navigationItem.rightBarButtonItems = [navBarBtn,btn]
        
        
        
        
        // uploadTitleImage
        // 先上傳前面填寫得封面照和標題等資料 /diarys
        // 在上傳全部items圖片到storage 拿到imageUrl
        // 將data轉換為dictinoary 上傳到 firebaseDB /diary-content
        
        
        
        timeLineTableView.estimatedRowHeight = 100
        timeLineTableView.rowHeight = UITableViewAutomaticDimension
        
        
        
        
        
        let calender = CalenderManager()
        var newDateComponent = DateComponents()
        newDateComponent.day = 1
        
        diarys = [OneDiaryRecord]()
        
        guard let myBeginDate = beginDate,
            let myDay = day else{
                return
        }
        
        
        
        //begin date
        var calculatedDate = calender.StringToDate(myBeginDate)
        
        
        for _ in 0..<myDay{
            
            sectionsIsExpend.append(true)
            let d = calender.dateToString(calculatedDate)
            
            
            master.diaryType = .foodDiaryAndDetail
            let cond = "Food_Diary.food_id=foodDetails_id and date = '\(d)'"
            
            
            
            let foodDaiays = master.getFoodDetails(.diaryData,amount:nil,weight:nil,cond: cond,order: nil)
            
            var foodItems = [DiaryItem]()
            
            
            
            for item in foodDaiays{
                
                let detail = String(format: "%0.1f",item.calorie)
                let image = UIImage(imageName: item.imageName, search: .documentDirectory)
                let myItem = DiaryItem(image:image, title: item.sampleName, detail:detail)
                foodItems.append(myItem)
                
                
            }
            
            
            
            
            sportMaster.diaryType = .sportDiaryAndDetail
            var sportItems = [DiaryItem]()
            let sportCond = "Sport_Diary.SportDiary_DetailId=SportDetail_Id and SportDiary_Date = '\(d)'"
            let sportDiarys = sportMaster.getSportDetails(.diaryData, minute: nil, cond: sportCond, order: nil)
            
            for item in sportDiarys{
                
                let detail = "\(item.calories)"
                
                let image = UIImage(imageName: item.imageName, search: .documentDirectory)
                let myItem = DiaryItem(image:image,
                                       title:item.sampleName,
                                       detail:detail)
                
                sportItems.append(myItem)
                
            }
            
            
            
            
            diarys.append(OneDiaryRecord(food:foodItems,sport:sportItems,text:"", date: d))
            calculatedDate = Calendar.current.date(byAdding:newDateComponent,
                                                   to:calculatedDate)!
            
        }
        
    }
    
    func open(){
        
        let message:String
        let imageString:String
        if !isLocked{
            
            message = "設定為私人"
            imageString = "locked"
            isLocked = true
            
            
        }else{
            
            message = "設定為公開"
            imageString = "unlocked"
            isLocked = false
            
            
        }
        
        navigationItem.rightBarButtonItems?[1].image = UIImage(named:imageString)
        
        let alert = UIAlertController(title:message, message:"", preferredStyle: .alert)
        self.present(alert, animated: true)
        
        
        Timer.scheduledTimer(withTimeInterval:0.5, repeats: false) { (Timer) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func calSumItem()->Int{
        
        var sum:Int = 0
        for day in diarys{
            
            if let myFood = day.food?.count{sum+=myFood}
            if let mySport = day.sport?.count{sum+=mySport}
            
        }
        return sum
        
    }
    
    
    
    func uploadDiaryWithDay(diarys:[OneDiaryRecord]){
        
        for diary in diarys{
            
            
            if let myfood = diary.food {
                uploadImageIntoStorage(items:myfood)
            }
            
            
            if let mySport = diary.sport{
                
                uploadImageIntoStorage(items:mySport)
                
            }
            
        }
    }
    
    
    
    func chickIsEmpty(diary:[OneDiaryRecord])->Bool{
        
        var chickDiaryIsEmpty = true
        
        for i in diary{
            
            if i.food?.count != 0 || i.sport?.count != 0 {
                chickDiaryIsEmpty = false
            }
            
            
        }
        return chickDiaryIsEmpty
        
    }
    
    
    
    func uploadTitleImage(){
        
        
        sumItem = calSumItem()
        
        if chickIsEmpty(diary:diarys){
            
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
        
        
        
        Storage.storage().reference().child("titleImage").child("image_\(myTitleImage.hashValue).jpg").putData(dataImage, metadata: nil) { (StorageMetadata, Error) in
            
            
            if let err = Error{
                print(err)
                self.toastView?.removefromView()
                return
            }
            
            
            guard let titleImageURL = StorageMetadata?.downloadURL()?.absoluteString,
                let userId = ProfileManager.standard.userUid,
                let myPlanTitle = self.planTitle,
                let myBeginDate = self.beginDate else{
                    return
                    
            }
            
            
            
            
            let timestamp:Double = Date().timeIntervalSince1970
            
            let dict = ["title":myPlanTitle,
                        "titleImageURL":titleImageURL,
                        "diaryId":id,
                        "userId":userId,
                        "beginDate":myBeginDate,
                        "day":self.diarys.count,
                        "timestamp":Int(timestamp),
                        "open":String(!self.isLocked)] as [String : Any]
            
            
            self.serviceManager.dbDiarysURL.child(id).updateChildValues(dict) { (errpr, databaseReference) in
                
                self.uploadDiaryWithDay(diarys:self.diarys)
                
                
            }
        }
        
    }
    
    
    func uploadImageIntoStorage(items:[DiaryItem]){
        
        
        if diarys.count == 0{
            toastView?.removefromView()
        }
        
        for item in items{
            
            guard let myImage = item.image,
                let data = UIImageJPEGRepresentation(myImage,0.8) else{
                    trackUploadImageNumber+=1
                    
                    continue
            }
            
            
            
            serviceManager.storageImagesURL.child("item_\(myImage.hash).jpg").putData(data,metadata: nil, completion: { (StorageMetadata,error) in
                
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
        
        for record in diarys{
            
            if  let dict = dataTurnDict(day:record){
                records.append(dict)
                
            }else{
                
                
            }
            
        }
        
        
        serviceManager.dbDiaryContentURL.child(id).updateChildValues(["diaryRecords":records]) { (error, databaseReference) in
            
            if let err = error{
                print(err)
                
                return
            }
            
            DispatchQueue.main.async {
                self.toastView?.removefromView()
                self.navigationController?.popToRootViewController(animated: true)
                
            }
        }
    }
    
    
    func dataTurnDict(day:OneDiaryRecord)->[String:AnyObject]?{
        
        
        var foodItems = [[String:String]]()
        
        
        if let items = day.food{
            
            for item in items {
                
                var dit = [String:String]()
                dit["title"] = item.title
                dit["detail"] = item.detail
                dit["imageURL"] = item.imageURL
                
                foodItems.append(dit)
            }
            
        }
        var sportItems = [[String:String]]()
        
        
        if let items = day.sport{
            
            for item in items{
                
                var dit = [String:String]()
                dit["title"] = item.title
                dit["detail"] = item.detail
                dit["imageURL"] = item.imageURL
                sportItems.append(dit)
                
            }
        }
        
        let  text = day.text == "" ? nil: day.text
        let dict = ["foodItmes":foodItems,"sportItems":sportItems,"text":text,"date":day.date] as [String : Any?]
        
        
        if text == nil && foodItems.count == 0 && sportItems.count == 0{
            
            
            return nil
        }
        
        return dict as [String : AnyObject]
        
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let sectionDay = diarys[indexPath.section]
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
                diarys.remove(at: indexPath.section)
                sectionsIsExpend.remove(at:indexPath.section)
            }
            
            tableView.reloadData()
            
        }
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return diarys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sectionsIsExpend[section]{
            
            var calRow = 0
            let sectionDay = diarys[section]
            if sectionDay.food != nil{calRow+=1}
            if sectionDay.sport != nil{calRow+=1}
            if sectionDay.text != nil{calRow+=1}
            return calRow
            
        }else{
            
            return 0
            
            
        }
        
    }

    
        
        func sectionIsExpend(sender:UIButton){
            let section = sender.tag - 1000
            
            if sectionsIsExpend[section]{
                sectionsIsExpend[section] = false
            } else {
                sectionsIsExpend[section] = true
            }
            
            timeLineTableView.reloadSections(IndexSet(integer:section), with: .automatic)
            
            
            
        }
        
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            
            
            
            var calRow:Int = 0
            var foodRow:Int = 0
            
            
            if diarys[indexPath.section].food == nil{
                calRow += 1
                foodRow = -1
                
            }
            if diarys[indexPath.section].sport == nil{
                calRow += 1
                
            }
            
            
            
            let sportRow:Int = 1 - calRow
            let textRow:Int = 2 - calRow
            
            
            
            
            if indexPath.row == textRow{
                
                let cell = tableView.dequeueReusableCell(withIdentifier:"TextViewTableViewCell",for: indexPath) as! TextViewTableViewCell
                
                cell.oneDiary = diarys[indexPath.section]
                
                return cell
                
            }
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CollectionTableViewCell", for: indexPath) as! CollectionTableViewCell
            cell.VC = self
            
            
            if indexPath.row == foodRow {
                
                cell.diaryImageType = .food
                
                
            }else if indexPath.row == sportRow {
                
                cell.diaryImageType = .sport
                
                
            }
            
            cell.allData = diarys[indexPath.section]
            
            
            return cell
            
        }
        
        
        
        override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
            
            headerCell.titleLabel.text = "DAY\(section+1)    \(diarys[section].date)"
            headerCell.expendBtn.addTarget(self, action: #selector(sectionIsExpend), for: .touchUpInside)
            headerCell.expendBtn.tag = 1000 + section

            
            return headerCell.contentView
        }
        
        
        
        override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 40
        }
        
        
        
}



