//
//  AddFoodViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/12.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class AddFoodViewController: UIViewController {
    
    let foodMaster = FoodMaster.standard
    var currentTouchRow = 0
    let sectionTitles = ["食物","營養"]
    let picker = PickerViewController.shared
    
    @IBOutlet weak var addFoodTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell",bundle: nil)
        addFoodTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        let insertItem = UIBarButtonItem(title:"加入", style: .done, target: self, action: #selector(insertFoodDetail))
        navigationItem.rightBarButtonItems = [insertItem]
        navigationItem.title = "新食物"
        
        picker.delegate = self
        picker.numberOfRows = 1000
        picker.numberOfComponents = 0
        picker.selectRowOfbegin = 1
        
    }
    
    
    deinit {
        foodMaster.resetFoodSelect()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    @objc func insertFoodDetail(){
        
        var isWriteDone:Bool = true
        
        for i in 0..<4{
            if foodMaster.foodSelect[i] == nil{
                isWriteDone = false
            }
        }
        
        
        if isWriteDone{
            
            foodMaster.insertFoodDetail()
            navigationController?.popViewController(animated: true)
            return
        }
        
        let alert = UIAlertController(error: "請填寫完整哦")
        present(alert, animated: true, completion: nil)
    

    }
    
}
//MARK: - UITableViewDataSource,UITableViewDelegate
extension AddFoodViewController:UITableViewDataSource,UITableViewDelegate{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if section == 0 {
            return 3
        }
        
        return foodMaster.addFoodTitle.count-3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if indexPath.section == 0{
            
            
            if indexPath.row <= 1{
                
                let cell =  tableView.dequeueReusableCell(withIdentifier:"TextFieldCell")  as!AddTextFieldTableViewCell
                cell.titleLabel.text = foodMaster.addFoodTitle[indexPath.row]
                
                
                let rightString:String?
                
                if foodMaster.foodSelect[indexPath.row] == nil{
                    rightString = "必填"
                    
                }else{
                    
                    rightString = foodMaster.foodSelect[indexPath.row]
                    
                }
                
                cell.rightTextField.tag = 100+indexPath.row
                cell.rightTextField.placeholder = rightString
                cell.rightTextField.addTarget(self, action:#selector(textChanged(sender:)), for:.editingChanged)
                
                return cell
                
                
            }else{
                
                
                let cell =  tableView.dequeueReusableCell(withIdentifier:"RightDetailCell");
                cell?.textLabel?.text = foodMaster.addFoodTitle[indexPath.row]
                
                let rightString:String?
                
                if foodMaster.foodSelect[indexPath.row] == nil{
                    rightString = "必填"
                }else{
                    
                    rightString = foodMaster.foodSelect[indexPath.row]
                    
                }
                
                cell?.detailTextLabel?.text = rightString
                
                return cell!
                
            }
            
            
        }else { //section == 1
            
            
            let cell =  tableView.dequeueReusableCell(withIdentifier:"RightDetailCell");
            cell?.textLabel?.text = foodMaster.addFoodTitle[indexPath.row+3]
            cell?.detailTextLabel?.text = foodMaster.foodSelect[indexPath.row+3]
            
            if indexPath.row == 0{
                
                let detailString:String?
                
                if foodMaster.foodSelect[indexPath.row+3] == nil{
                    detailString = "必填"
                }else{
                    
                    detailString = foodMaster.foodSelect[indexPath.row+3]
                    
                }
                cell?.detailTextLabel?.text = detailString
                
            }else{
                let detailString:String?
                
                if foodMaster.foodSelect[indexPath.row+3] == nil{
                    detailString = "可選"
                }else{
                    
                    detailString = foodMaster.foodSelect[indexPath.row+3]
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
                
                picker.numberOfComponents = 1
                
            }else{
                return
            }
            
            
        }else{
            currentTouchRow = indexPath.row+3
            picker.numberOfComponents = 2
            
            
        }
        
        
        if  let select = foodMaster.foodSelect[currentTouchRow],
            let doubleValue = Double(select){
            picker.selectRowOfbegin = doubleValue
        }
        
      picker.displayDialog(present:self)
    }
    
    
    @objc func textChanged(sender:UITextField){
        
        let indexPathRow = sender.tag - 100
        foodMaster.foodSelect[indexPathRow] = sender.text
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
        headerCell.titleLabel.text = sectionTitles[section]
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
    
        foodMaster.foodSelect[currentTouchRow] = String(data)
        addFoodTableView.reloadData()
        
    }
    
}


