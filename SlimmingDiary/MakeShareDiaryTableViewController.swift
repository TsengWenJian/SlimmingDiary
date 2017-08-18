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
    let master = FoodMaster.standard
    let sportMaster = SportMaster.standard
    let shareManager = shareDiaryManager.standard
    var diaryId = String()
    var sumItem = 0
    var trackUploadImageNumber = 0{
        didSet{
            if trackUploadImageNumber == sumItem{
                
                
                uploadDairyToDB(id:diaryId)
                
            }
        }
    }
    
    var diaryTitle:String?
    var titleImage:UIImage?
    var day:Int?
    var beginDate:String?
    var toastView:NickToastUIView?
    var serviceManager = DataService.standard
    var isLocked:Bool = false
    var trackIsLock:Bool = false
    var sectionsIsExpend = [Bool]()
    var actionType = ActionType.insert
    var titleDiary:ShareDiary!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLineTableView.estimatedRowHeight = 100
        timeLineTableView.rowHeight = UITableViewAutomaticDimension
        
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        timeLineTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        
        
        if actionType == .insert{
            
            
            getDiaryRecords()
            
            
        }else{
            
            
            isLocked = titleDiary.open == "public" ?false:true
            navigationItem.title = "修改日記"
            
            
            
        }
        
        setSectionExpend(sum:diarys.count)
        trackIsLock = isLocked
        let navBarBtn = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(uploadTitleImage))
        let ui = isLocked==true ? UIImage(named:"lock"):UIImage(named:"unlock")
        let btn = UIBarButtonItem(image:ui, style: .plain, target: self, action: #selector(setOpenStatus))
        navigationItem.rightBarButtonItems = [navBarBtn,btn]
        
        
        
    }
    
    
    
    
    func setSectionExpend(sum:Int){
        
        for _ in 0..<sum{
            sectionsIsExpend.append(true)
        }
        
    }
    
    
    
    func getDiaryRecords(){
        
        
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
            let diaryDate = calender.dateToString(calculatedDate)
            
            
            master.diaryType = .foodDiaryAndDetail
            let cond = "Food_Diary.\(FOODDIARY_DETAILID)=\(FOODDETAIL_Id) and \(FOODDIARY_DATE) = '\(diaryDate)'"
            let foodDaiays = master.getFoodDetails(.diaryData,amount:nil,weight:nil,cond: cond,order: nil)
            var foodItems = [DiaryItem]()
            for item in foodDaiays{
                
                let detail = String(format:"%0.1f",item.calorie)
                let image = UIImage(imageName:item.imageName,search: .documentDirectory)
                let myItem = DiaryItem(image:image, title: item.sampleName, detail:detail)
                foodItems.append(myItem)
                
            }
            
            sportMaster.diaryType = .sportDiaryAndDetail
            var sportItems = [DiaryItem]()
            let sportCond = "Sport_Diary.\(SPORTYDIARY_DETAILID)=\(SPORTDETAIL_ID) and \(SPORTYDIARY_DATE) = '\(diaryDate)'"
            let sportDiarys = sportMaster.getSportDetails(.diaryData, minute: nil, cond: sportCond, order: nil)
            for item in sportDiarys{
                
                let detail = String(format: "%0.1f",item.calories)
                let image = UIImage(imageName: item.imageName,search:.documentDirectory)
                let myItem = DiaryItem(image:image,
                                       title:item.sampleName,
                                       detail:detail)
                
                sportItems.append(myItem)
                
            }
            
            
            diarys.append(OneDiaryRecord(food:foodItems,sport:sportItems,text:"",date: diaryDate))
            
            if let calDate =  Calendar.current.date(byAdding:newDateComponent,to:calculatedDate){
                calculatedDate = calDate
            }
            
        }
        
    }
    
    
    
    func setOpenStatus(){
        
        let title:String
        let imageString:String
        if !isLocked{
            
            title = "設定為私人"
            imageString = "lock"
            isLocked = true
            
            
        }else{
            
            title = "設定為公開"
            imageString = "unlock"
            isLocked = false
            
            
        }
        
        navigationItem.rightBarButtonItems?[1].image = UIImage(named:imageString)
        let alert = UIAlertController(title:title,message:"",preferredStyle: .alert)
        self.present(alert, animated: true)
        
        
        Timer.scheduledTimer(withTimeInterval:0.6, repeats: false) { (Timer) in
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
    
    
    
    func uploadDiaryWithItemsImage(diarys:[OneDiaryRecord]){
        
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
            
            if (i.food?.count != 0 && i.food != nil) || (i.sport?.count != 0 && i.sport != nil) {
                chickDiaryIsEmpty = false
            }
        }
        return chickDiaryIsEmpty
        
    }
    
    
    
    func uploadTitleImage(){
        
        sumItem = calSumItem()
        
        if serviceManager.isConnectDBURL == false{
            let alert = UIAlertController(error:NO_CONNECTINTENTER)
            present(alert, animated: true, completion: nil)
            return
        }
        
        
        sumItem = calSumItem()
        
        if chickIsEmpty(diary:diarys){
            
            let alert = UIAlertController(error: "記錄為空請填寫")
            present(alert, animated: true, completion: nil)
            
            return
            
        }
        
        if toastView != nil {
            return
        }
        
        
        if let navView = navigationController?.view{
            toastView = NickToastUIView(supView:navView, type:.Upload)
        }
        
        
        
        if actionType == .update{
            
            self.uploadDiaryWithItemsImage(diarys:self.diarys)
            
            return
            
        }
        
        
        
        
        
        diaryId = NSUUID().uuidString
        
        
        
        guard let myTitleImage = titleImage?.resizeImage(maxLength: 1024),
            let dataImage = UIImageJPEGRepresentation(myTitleImage,0.8)else{
                return
        }
        
        let timestamp = Date().timeIntervalSince1970
        
        
        serviceManager.storageTitleImagesURL.child("image_\(timestamp)_\(myTitleImage.hash).jpg").putData(dataImage, metadata: nil) { (metadata, error) in
            
            
            if let err = error{
                print(err.localizedDescription)
                self.toastView?.removefromView()
                return
            }
            
            
            guard let titleImageURL = metadata?.downloadURL()?.absoluteString,
                let userId = ProfileManager.standard.userUid,
                let myPlanTitle = self.diaryTitle,
                let myBeginDate = self.beginDate else{
                    return
                    
            }
            
            
            
            let open = self.isLocked == true ?"private":"public"
            let dict = ["title":myPlanTitle,
                        "titleImageURL":titleImageURL,
                        "diaryId":self.diaryId,
                        "userId":userId,
                        "beginDate":myBeginDate,
                        "day":self.diarys.count,
                        "timestamp":timestamp,
                        "open":open] as [String : Any]
            
            
            self.serviceManager.dbDiarysURL.child(open).child(self.diaryId).updateChildValues(dict) { (error,reference) in
                
                if error != nil{
                    self.toastView?.removefromView()
                    print(error.debugDescription)
                    return
                    
                }
                
                self.serviceManager.dbUserDiaryURL.child(userId).child(self.diaryId).updateChildValues(dict, withCompletionBlock: { (error, userdiaryDB) in
                    
                    if error != nil{
                        self.toastView?.removefromView()
                        print(error.debugDescription)
                        return
                    }
                    
                })
                self.uploadDiaryWithItemsImage(diarys:self.diarys)
                
                
            }
        }
        
    }
    
    
    
    
    
    
    
    func uploadImageIntoStorage(items:[DiaryItem]){
        
        
        if diarys.count == 0{
            toastView?.removefromView()
            toastView = nil
        }
        
        for item in items{
            
            guard let myImage = item.image,
                let data = UIImageJPEGRepresentation(myImage,0.8) else{
                    trackUploadImageNumber+=1
                    continue
            }
            let timestamp = Date().timeIntervalSince1970
            serviceManager.storageImagesURL.child("item_\(timestamp)_\(myImage.hash).jpg").putData(data,metadata: nil, completion: { (StorageMetadata,error) in
                
                if let err = error{
                    print(err.localizedDescription)
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
            
            if let dict = dataTurnDict(day:record){
                records.append(dict)
            }
        }
        
        
        
        if actionType == .insert{
            
            
            serviceManager.dbDiaryContentURL.child(id).updateChildValues(["diaryRecords":records]) { (error, databaseReference) in
                
                self.toastView?.removefromView()
                if error != nil{
                    
                    print(error.debugDescription)
                    
                    return
                }
                
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
        }else{
            
            
            
            let originOpen = self.trackIsLock == true ?"private":"public"
            let nowOpen = self.isLocked == true ?"private":"public"
            
            
            let dict = ["title":titleDiary.title,
                        "titleImageURL":titleDiary.titleImageURL,
                        "diaryId":titleDiary.diaryId,
                        "userId":titleDiary.userId,
                        "beginDate":titleDiary.beginDate,
                        "day":titleDiary.day,
                        "timestamp":titleDiary.timestamp,
                        "open":nowOpen] as [String : Any?]
            
            
            if trackIsLock != isLocked{
                
                self.serviceManager.dbDiarysURL.child(nowOpen).child(self.titleDiary.diaryId!).setValue(dict)
                self.serviceManager.dbDiarysURL.child(originOpen).child(self.titleDiary.diaryId!).removeValue()
                self.serviceManager.dbUserDiaryURL.child(ProfileManager.standard.userUid!).child(self.titleDiary.diaryId!).removeValue()
                self.serviceManager.dbUserDiaryURL.child(ProfileManager.standard.userUid!).child(self.titleDiary.diaryId!).setValue(dict)
                
            }
            
            
            serviceManager.dbDiaryContentURL.child(titleDiary.diaryId!).updateChildValues(["diaryRecords":records], withCompletionBlock: { (error, data) in
                self.toastView?.removefromView()
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    
                }
            })
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
    
    
    func dataTurnDict(day:OneDiaryRecord)->[String:AnyObject]?{
        
        
        let foodItems = itemsTurnDict(items:day.food)
        
        let sportItems = itemsTurnDict(items:day.sport)
        
        
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
        sectionsIsExpend[section] = !sectionsIsExpend[section]
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
            
            if diarys[indexPath.section].text == ""{
                
                
                cell.textView.text = "輸入點內容吧"
            }else{
                cell.textView.text = diarys[indexPath.section].text
            }
            
            
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


