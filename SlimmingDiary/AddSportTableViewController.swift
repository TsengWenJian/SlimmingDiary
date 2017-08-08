//
//  AddSportTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/6.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit



class AddSportTableViewController: UITableViewController {
    
    let titleArray = ["名稱","多久(分鐘)","消耗卡路里"]
    var detailArray = ["","",""]
    var pickerVC:PickerViewController!
    var numberOfRows:Int = 2000
    var numberOfComponents:Int = 2
    var setSelectRowOfbegin:Double = 0
    var currentTouchRow = 0
    var textFieldText:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerVC = storyboard?.instantiateViewController(withIdentifier:"PickerViewController") as! PickerViewController
        pickerVC.delegate = self
        
        
        let insertItem = UIBarButtonItem(title:"加入", style: .done, target: self, action: #selector(addSport))
        navigationItem.rightBarButtonItems = [insertItem]
        
        navigationItem.title = "新運動"
        
        
    }
    
  override  func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func addSport(){
        
        var isWriteDone:Bool = true
        
        
        
        
        for i in detailArray{
            if i == "" || textFieldText == nil{
                isWriteDone = false
                break
            }
        }
        
        if isWriteDone{
            
            let master = SportMaster.standard
            
            
            
            guard let cal = Double(detailArray[2]),
                  let minute = Double(detailArray[1]) else{
                    return
            }
            let emts = cal * (60/minute) / ProfileManager.standard.userWeight
            
            
         master.diaryType = .sportDetail
            
            master.insertDiary(rowInfo: ["SportDetail_Classification":"'自訂'",
                                         "SportDetail_SampleName":"'\(detailArray[0])'",
                                         "SportDetail_Emts":"'\(emts.toString())'"])
            
                     
        navigationController?.popViewController(animated: true)
            
            
            
            return
            
        }
        
        let alert = UIAlertController(error: "請輸入完整")
        present(alert, animated: true, completion: nil)
        
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titleArray.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        currentTouchRow = indexPath.row
        
        
        if indexPath.row == 0{
            return
        }
        
        if indexPath.row == 1{
            setSelectRowOfbegin = 30
            numberOfComponents = 1
            
        }else if indexPath.row == 2 {
            
            
            numberOfComponents = 2
            setSelectRowOfbegin = 200
        }
        
        
        pickerVC.displayPickViewDialog(present: self)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell",for: indexPath) as! AddTextFieldTableViewCell
            
            cell.titleLabel.text = titleArray[indexPath.row]
            
            cell.rightTextField.addTarget(self, action: #selector(textChange(_:)), for: .editingChanged)
            
            return cell
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath)
            cell.textLabel?.text = titleArray[indexPath.row]
            
            var text:String
            
            if detailArray[indexPath.row] == ""{
                text = "必填"
            }else{
                text = detailArray[indexPath.row]
            }
            cell.detailTextLabel?.text = text
            return cell
            
        }
    }
    
    func textChange(_ sender:UITextField){
        
        
        textFieldText = sender.text
        
        if let text = sender.text
        {
            detailArray[0] = text
            
        }
        
        
        
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    
    
}



//MARK: - PickerViewDelegate
extension AddSportTableViewController:PickerViewDelegate{
    
    func getSelectRow(data:Double) {
        
        if currentTouchRow == 1{
            
            detailArray[currentTouchRow] = "\(Int(data))"
        }else{
            
            detailArray[currentTouchRow] = String(format: "%.1f", data)
            
            
        }
        
        tableView.reloadData()
    }
    
}



