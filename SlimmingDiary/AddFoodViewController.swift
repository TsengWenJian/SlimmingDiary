//
//  AddFoodViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/12.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class AddFoodViewController: UIViewController {
    
    let addFoodManager = AddFoodManager()
    var numberOfRows:Int = 0
    var numberOfComponents:Int = 0
    var setSelectRowOfbegin:Double = 0
    var currentTouchRow = 0
    var pickerVC:PickerViewController!
    
    
    @IBOutlet weak var addFoodTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        pickerVC = storyboard?.instantiateViewController(withIdentifier:"PickerViewController") as!
        PickerViewController
        pickerVC.delegate = self
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell",bundle: nil)
        addFoodTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        let insertItem = UIBarButtonItem(title:"加入", style: .done, target: self, action: #selector(insertFoodDetail))
        navigationItem.rightBarButtonItems = [insertItem]
        navigationItem.title = "新食物"
        
        
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func insertFoodDetail(){
        
        var isWriteDone:Bool = true
        
        for i in 0..<4{
            if addFoodManager.foodSelect[i] == nil{
                isWriteDone = false
            }
        }
        
        
        if isWriteDone{
            
            addFoodManager.insertFoodDetail()
            navigationController?.popViewController(animated: true)
            return
        }
        
        
        let alert = UIAlertController(title: "輸入", message: "資料輸入不完全", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style:.cancel, handler:nil)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
        
        
        
        
    }
    
}
//MARK: - UITableViewDataSource,UITableViewDelegate
extension AddFoodViewController:UITableViewDataSource,UITableViewDelegate{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return addFoodManager.sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if section == 0 {
            return 3
        }
        
        return addFoodManager.foodTitle.count-3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0{
            
            
            if indexPath.row <= 1{
                
                let cell =  tableView.dequeueReusableCell(withIdentifier:"TextFieldCell")  as!AddTextFieldTableViewCell
                cell.titleLabel.text = addFoodManager.foodTitle[indexPath.row]
                
                
                let rightString:String?
                
                if addFoodManager.foodSelect[indexPath.row] == nil{
                    rightString = "必填"
                    
                }else{
                    
                    rightString = addFoodManager.foodSelect[indexPath.row]
                    
                }
                
                cell.rightTextField.tag = 100+indexPath.row
                cell.rightTextField.placeholder = rightString
                cell.rightTextField.addTarget(self, action:#selector(textChanged(sender:)), for:.editingChanged)
                
                return cell
                
                
            }else{
                
                
                let cell =  tableView.dequeueReusableCell(withIdentifier:"RightDetailCell");             cell?.textLabel?.text = addFoodManager.foodTitle[indexPath.row]
                
                let rightString:String?
                
                if addFoodManager.foodSelect[indexPath.row] == nil{
                    rightString = "必填"
                }else{
                    
                    rightString = addFoodManager.foodSelect[indexPath.row]
                    
                }
                
                cell?.detailTextLabel?.text = rightString
                
                return cell!
                
            }
            
            
        }else { //section == 1
            
            
            let cell =  tableView.dequeueReusableCell(withIdentifier:"RightDetailCell");             cell?.textLabel?.text = addFoodManager.foodTitle[indexPath.row+3]
            cell?.detailTextLabel?.text = addFoodManager.foodSelect[indexPath.row+3]
            
            if indexPath.row == 0{
                
                let detailString:String?
                
                if addFoodManager.foodSelect[indexPath.row+3] == nil{
                    detailString = "必填"
                }else{
                    
                    detailString = addFoodManager.foodSelect[indexPath.row+3]
                    
                }
                cell?.detailTextLabel?.text = detailString
                
            }else{
                let detailString:String?
                
                if addFoodManager.foodSelect[indexPath.row+3] == nil{
                    detailString = "可選"
                }else{
                    
                    detailString = addFoodManager.foodSelect[indexPath.row+3]
                }
                cell?.detailTextLabel?.text = detailString
                
            }
            return cell!
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTouchRow = indexPath.row
        
        
        self.view.endEditing(true)
        if indexPath.section == 0{
            
            
        
            if indexPath.row == 2{
                
                numberOfRows = 1000
                numberOfComponents = 1
                setSelectRowOfbegin = 1
            }else{
                
                return
            }
            
            
        }else{
            currentTouchRow = indexPath.row+3
            numberOfRows = 1000
            numberOfComponents = 2
            setSelectRowOfbegin = 1
            
        }
        
        
        
        if  let select = addFoodManager.foodSelect[currentTouchRow],
            let doubleValue = Double(select){
            setSelectRowOfbegin = doubleValue
        }
        
        pickerVC.displayPickViewDialog(present: self)
        
    }
   
    
    func textChanged(sender:UITextField){
        
        let indexPathRow = sender.tag - 100
        
        if sender.text != "" {
            
            addFoodManager.foodSelect[indexPathRow] = sender.text
        }else{
            
            addFoodManager.foodSelect[indexPathRow] = nil
        }
    
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
        headerCell.titleLabel.text = addFoodManager.sectionTitle[section]
        headerCell.totalCalorieLebel.text = nil
        headerCell.rightLabel.text = nil
        
        
        return headerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
}


//MARK: - PickerViewDelegate
extension AddFoodViewController:PickerViewDelegate{
    
    func getSelectRow(data:Double) {
        
        
        if currentTouchRow == 2{
            
            addFoodManager.foodSelect[currentTouchRow] = String((data))
            
        }else{
            
            addFoodManager.foodSelect[currentTouchRow] = String(data)
            
        }
        
        addFoodTableView.reloadData()
        
        
    }

}


