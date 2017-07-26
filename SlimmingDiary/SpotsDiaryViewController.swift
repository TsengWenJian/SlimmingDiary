//
//  SpotsDiaryTableViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/11.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class SpotsDiaryViewController:UIViewController{
    @IBOutlet weak var spotsDiaryTableView: UITableView!
    let dinnerTime = ["有氧運動","肌力訓練"]
    var isExpend = [true,true]


     override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibHeader = UINib(nibName: "HeaderTableViewCell", bundle: nil)
        spotsDiaryTableView.register(nibHeader, forCellReuseIdentifier: "headerCell")
        
        let nibBody = UINib(nibName: "BodyTableViewCell", bundle: nil)
        spotsDiaryTableView.register(nibBody, forCellReuseIdentifier: "Cell")
        
        let nibFooter = UINib(nibName: "FooterTableViewCell", bundle: nil)
        spotsDiaryTableView.register(nibFooter, forCellReuseIdentifier: "footerCell")
        


       
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
          }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

  
   
}


extension SpotsDiaryViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as!BodyTableViewCell
        
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as!HeaderTableViewCell
        headerCell.titleLabel.text = dinnerTime[section]
        headerCell.totalCalorieLebel.text = ""
        
        
        return headerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = tableView.dequeueReusableCell(withIdentifier: "footerCell") as!FooterTableViewCell
        footerCell.titleLabel.text = "尚未添加運動"
        
        return footerCell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
    
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    
    
    
    
    
    
}
