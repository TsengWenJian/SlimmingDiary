//
//  MainDiaryViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/27.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class MainDiaryViewController: UIViewController{
    @IBOutlet weak var btnBackgroundView: UIView!
    @IBOutlet weak var pageContainerView: UIView!
    @IBOutlet weak var spotsDiaryBtn: UIButton!
    @IBOutlet weak var foodDiaryBtn: UIButton!
    @IBOutlet weak var displayDateBtn: UIButton!
    @IBOutlet weak var weightDiaryBtn: UIButton!
    
    var pan = UIPanGestureRecognizer()
    var pageVC: UIPageViewController!
    
    var displayCalendar = false
    
    var calender = CalenderManager.standard
    var foodDairyVC:FoodDiaryViewController!
    var sportsDiaryVC:SpotsDiaryViewController!
    var weightDiaryVC:WeightDiaryViewController!
    var calendarPickVC:CalendarViewController!
    
    var lastPage = 0
    
    
    var displayDate:MyDate = CalenderManager.standard.displayDate{
        
        didSet{
            NotificationCenter.default.post(name:NSNotification.Name(rawValue: "changeDiaryData"), object: nil)
            displayDateBtn.setTitle(calender.myDateToString(displayDate), for: .normal)
            
        }
    }
    
    var currentPage:Int = 0{
        
        didSet{
            let offset = self.view.frame.width / 3.0 * CGFloat(currentPage)
            
            UIView.animate(withDuration: 0.2) {
                self.btnBackgroundView.frame.origin = CGPoint(x: offset, y: self.btnBackgroundView.frame.minY)
                
            }
            
            let wobble = CAKeyframeAnimation(keyPath: "transform.rotation")
            wobble.duration = 0.2
            wobble.repeatCount = 2
            wobble.values = [0.0,-0.05,0.0,0.05, 0.0]
            wobble.keyTimes = [0.0, 0.25, 0.5, 0.75, 1.0]
            
            self.btnBackgroundView.layer.add(wobble,forKey:nil)
            
            foodDiaryBtn.isSelected = false
            spotsDiaryBtn.isSelected = false
            weightDiaryBtn.isSelected = false
            
            if currentPage == 0{
                
                foodDiaryBtn.isSelected = true
                
            }else if currentPage == 1{
                
                spotsDiaryBtn.isSelected = true
                
            }
            else{
                weightDiaryBtn.isSelected = true
                
            }
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        displayDateBtn.setTitle(calender.myDateToString(displayDate), for: .normal)
        
        
        pageVC = self.childViewControllers.first as! UIPageViewController
        
        foodDairyVC = storyboard?.instantiateViewController(withIdentifier: "FoodDiaryViewController") as!FoodDiaryViewController
        
        sportsDiaryVC = storyboard?.instantiateViewController(withIdentifier: "SpotsDiaryViewController") as!SpotsDiaryViewController
        
        
        weightDiaryVC = storyboard?.instantiateViewController(withIdentifier: "WeightDiaryViewController") as!WeightDiaryViewController
        
        pageVC.delegate = self
        pageVC.dataSource = self
        
        
        
        pageVC.setViewControllers([foodDairyVC],direction:.forward,animated: false,completion: nil)
        
    
        calendarPickVC = storyboard!.instantiateViewController(withIdentifier: "CalendarViewController") as!
        CalendarViewController
        calendarPickVC.delegate = self
        
        
        
        pageContainerView.addGestureRecognizer(pan)
        pan.delegate = self
        
        
        for x in pageVC.view.subviews {
            
            pan = x.gestureRecognizers?[1] as! UIPanGestureRecognizer
            pageContainerView.addGestureRecognizer(pan)
            
            
            
        }
        
      
        
        btnBackgroundView.layer.cornerRadius = 1
        btnBackgroundView.layer.shadowOpacity = 0.2
        btnBackgroundView.layer.shadowRadius = 1
        btnBackgroundView.layer.shadowOffset = CGSize(width:0, height: 0)
        btnBackgroundView.layer.shadowColor = UIColor.black.cgColor
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func typeButton(_ sender: UIButton) {
        
        var direction = UIPageViewControllerNavigationDirection.forward
        let btnTag = sender.tag-100
        
        let currentPageVC:UIViewController
        
        if btnTag == 0{
            
            currentPage = 0
            direction = .reverse
            currentPageVC = foodDairyVC
            
            
            lastPage = 1
            
        }else if btnTag == 1{
            
            if currentPage == 2{
                lastPage = 2
                direction = .reverse
                currentPageVC = sportsDiaryVC
                
                
            }else{
                lastPage = 0
                direction = .forward
                currentPageVC = sportsDiaryVC
                
                
            }
            
            currentPage = 1
            
        }else{
            
            currentPage = 2
            direction = .forward
            currentPageVC = weightDiaryVC
            
            lastPage = 1
            
        }
        
        pageVC.setViewControllers([currentPageVC], direction:direction, animated: true, completion: nil)
        
    }
    
    
    
    
    @IBAction func previousDay(_ sender:UIButton) {
        calender.changeDisplayDate(.previous)
        updateDisplayeDate()
    
        
          }
    
    
    @IBAction func nextDay(_ sender:UIButton) {
        calender.changeDisplayDate(.next)
        updateDisplayeDate()
        
    }
    
    
    
    @IBAction func calenderAction(_ sender: Any) {
        if  calender.displayCalenderAction{
            calendarPickVC.hideDialog()
            calender.displayCalenderAction = false
            
            
        }else{
            
            calendarPickVC.displayCalendarPickDialog(self)
            calender.displayCalenderAction = true
            
        }
        
    }
    
    func updateDisplayeDate(){
        displayDate = calender.displayDate
    }
    
    
    
}
extension MainDiaryViewController:UIPageViewControllerDelegate,UIPageViewControllerDataSource{
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        

        if !completed {
            currentPage = lastPage
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let pendingVC = pendingViewControllers.first else{
            return
        }
        
        if  pendingVC.isKind(of:SpotsDiaryViewController.self){
            
            
            if currentPage == 2{
                lastPage = 2
            }else{
                
                lastPage = 0
            }
            currentPage = 1
            
            
        }else if pendingVC.isKind(of:FoodDiaryViewController.self){
            currentPage = 0
            lastPage = 1
            
        }else if pendingVC.isKind(of:WeightDiaryViewController.self){
            
            currentPage = 2
            lastPage = 1
            
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of:SpotsDiaryViewController.self){
            return foodDairyVC
        }
        
        if viewController.isKind(of:WeightDiaryViewController.self){
            
            return sportsDiaryVC
        }
        return nil
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController.isKind(of: FoodDiaryViewController.self){
            return  sportsDiaryVC
            
        }else if viewController.isKind(of:SpotsDiaryViewController.self){
            
            return weightDiaryVC
        }
        
        return nil
    }
}


extension MainDiaryViewController:CalendarPickDelegate{
    
    func getCalenderSelectDate(date:MyDate) {
        calender.displayDate = date
        displayDate = date
        
    }
    
}

extension MainDiaryViewController:UIGestureRecognizerDelegate{
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if String(describing:touch.view!.superview!.superview!.classForCoder) == "BodyTableViewCell" || String(describing:touch.view!.superview!.superview!.classForCoder) == "WeightDiaryBodyTableViewCell"{
            pageContainerView.removeGestureRecognizer(pan)
            return false
            
        } else {
            
            pageContainerView.addGestureRecognizer(pan)
        }
        
        return true
        
    }
}

