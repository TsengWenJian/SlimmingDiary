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
    @IBOutlet weak var btnContainerleading: NSLayoutConstraint!
    
    var pageVCPan = UIPanGestureRecognizer()
    var pageVC: UIPageViewController!
    
   
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
        
        didSet{changeBtnStatus()}
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
        
        
        
      
        pageContainerView.addGestureRecognizer(pageVCPan)
        pageVCPan.delegate = self

        
        for view in pageVC.view.subviews {
            
            if view.isKind(of:UIScrollView.self){
                if let  scrollPan = view.gestureRecognizers?[1] as? UIPanGestureRecognizer{
                    
                    pageVCPan = scrollPan
                    pageContainerView.addGestureRecognizer(pageVCPan)
                }

            }
            
        }
        
        
        btnBackgroundView.setShadowView(1, 0.2,CGSize.zero)
        btnBackgroundView.layer.shadowRadius = 1
        
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func changeBtnStatus(){
        let offset = self.view.frame.width / 3.0 * CGFloat(currentPage)
        
        UIView.animate(withDuration: 0.2) {
            
            self.btnContainerleading.constant = offset
            self.view.layoutIfNeeded()
            
            
        }
        
        let wobble = CAKeyframeAnimation(keyPath: "transform.rotation")
        wobble.duration = 0.2
        wobble.repeatCount = 2
        wobble.values = [0.0,-0.05,0.0,0.05, 0.0]
        
        
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
                
                
            }else{
                lastPage = 0
                direction = .forward
                
            }
            
            currentPageVC = sportsDiaryVC
            currentPage = 1
            
        }else{
            
            currentPage = 2
            direction = .forward
            currentPageVC = weightDiaryVC
            lastPage = 1
            
        }
        
        pageVC.setViewControllers([currentPageVC], direction:direction,animated:true,completion: nil)
        
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
            calendarPickVC.delegate = self
            calendarPickVC.displayCalendarPickDialog(self)
            calender.displayCalenderAction = true
            
        }
        
    }
    
    func updateDisplayeDate(){
        displayDate = calender.displayDate
    }
    
        
    
}
//MARK: - UIPageViewControllerDelegate,UIPageViewControllerDataSource
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
            
            
            lastPage = currentPage == 2 ?2:0
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

//MARK: - CalendarPickDelegate
extension MainDiaryViewController:CalendarPickDelegate{
    
    func getCalenderSelectDate(date:MyDate) {
        calender.displayDate = date
        displayDate = date
        
    }
    
}
//MARK: - UIGestureRecognizerDelegate
extension MainDiaryViewController:UIGestureRecognizerDelegate{
    

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
    
          if let touchView =  touch.view,
             let superView = touchView.superview,
             let cellView = superView.superview{
            
             let cellClass =  String(describing:cellView.classForCoder)
        
            if cellClass == "BodyTableViewCell" || cellClass == "WeightDiaryBodyTableViewCell"{
                
                pageContainerView.removeGestureRecognizer(pageVCPan)
                
                return false
                
            } else {
                
                pageContainerView.addGestureRecognizer(pageVCPan)
            }
        }
        
        
        return true
        
    }
}

