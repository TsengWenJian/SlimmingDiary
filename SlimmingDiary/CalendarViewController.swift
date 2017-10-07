//
//  CalendrerViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/6/5.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit



protocol CalendarPickDelegate:class {
    
    func getCalenderSelectDate(date:MyDate)
    
}

class CalendarViewController: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var calenderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var titleDate: UILabel!
    weak var delegate:CalendarPickDelegate!
    let calenderManager = CalenderManager.standard

   
    var MonthTotalDaysArray = [String](){
        didSet{
            calendarCollectionView.reloadData()
            setTitleDate()
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        calenderManager.resetDisplayMonth()
        MonthTotalDaysArray = calenderManager.getMonthTotalDaysArray(type: .current)
        setTitleDate()
        
        
        
        
    }
   
    
    
    @IBAction func swipeNextMonthAction(_ sender:UIButton) {
        MonthTotalDaysArray = calenderManager.getMonthTotalDaysArray(type: .next)
        changeMonthTransition(transitionForm:kCATransitionFromRight)
      
    }
    
    
    
    @IBAction func swipePreviousMonthAction(_ sender: UIButton) {
        MonthTotalDaysArray = calenderManager.getMonthTotalDaysArray(type: .previous)
        changeMonthTransition(transitionForm:kCATransitionFromLeft)
      
        
        
    }
    
   
    
    func displayCalendarPickDialog(_ parentViewController: UIViewController) {
        
        let basic = CABasicAnimation(keyPath:"position.y")
        basic.duration = 0.2
        basic.fromValue = -view.frame.size.width/2
        basic.toValue = view.frame.width/2
        self.calendarCollectionView.layer.add(basic, forKey: nil)
        
        parentViewController.addChildViewController(self)
        parentViewController.view.addSubview(self.view)
        self.didMove(toParentViewController:parentViewController)
        
        
        
        
    }
    
    
    func hideDialog() {
    
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
    }
    
    
    
    func changeMonthTransition(transitionForm:String){
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = "pageCurl"
        transition.subtype = transitionForm
        calendarCollectionView.layer.add(transition, forKey:nil)
        

        
    }
    
    
    @IBAction func hiddenBtn(_ sender: Any) {
        hideDialog()
        calenderManager.displayCalenderAction = false
        
    }
    
    
    func setTitleDate(){
        titleDate.text = String(calenderManager.displayMonth.year)+"年"+String(calenderManager.displayMonth.month)+"月"
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return calenderManager.weekArray.count
        } else {
            
            
            return  calenderManager.getMonthTotalDaysArray(type:.current).count
            
            
            
        }
        
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if indexPath.row ==  0{
            calenderViewHeight.constant = calendarCollectionView.collectionViewLayout.collectionViewContentSize.height
        }

        
    
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CalendarCollectionViewCell
        
        cell.shadowView.isHidden = true
        
        
        if indexPath.section == 0{
            cell.day.text = calenderManager.weekArray[indexPath.row]
            cell.day.textColor = blue
            return cell
            
        }else{
            
        
            cell.day.text = ""
            
            if MonthTotalDaysArray[indexPath.row] != ""{
                
                let day = Int(MonthTotalDaysArray[indexPath.row])
                cell.day.text = MonthTotalDaysArray[indexPath.row]
                
                let myDate = MyDate(year:calenderManager.displayMonth.year, month: calenderManager.displayMonth.month, day: day!)
                
                switch  calenderManager.checkDayType(date:myDate) {
                    
                case .displayDay:
                    
                    cell.day.textColor = UIColor.white
                    cell.shadowView.isHidden = false
                    
                case .today:
                    
                    cell.day.textColor = UIColor.red
                    cell.shadowView.isHidden = true
                    
                case .afterDay:
                    cell.day.textColor = UIColor.gray
                    
                case .none:
                    
                    cell.day.textColor = UIColor.black
                }
                
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        
        let cellWidth = (UIScreen.main.bounds.width) / 7
        let size = CGSize(width:cellWidth, height:cellWidth)
        
        
        if indexPath.section == 0{
            
            return CGSize(width:cellWidth,height:cellWidth*0.66)
        }
        
        
        return size
    }
    
    
   
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell =  collectionView.cellForItem(at:indexPath) as! CalendarCollectionViewCell
        
        CalenderManager.standard.displayCalenderAction = false
        hideDialog()
        if  let day = Int(cell.day.text!){
            
            let myDay = MyDate(year: calenderManager.displayMonth.year,
                               month: calenderManager.displayMonth.month,
                               day: day)
            
            delegate.getCalenderSelectDate(date:myDay)
            
        }
    }
}
