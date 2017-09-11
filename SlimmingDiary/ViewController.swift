//
//  ViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/26.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController{
    
    var  pageHeightDefaultHeight:CGFloat = 214
    @IBOutlet weak var pageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moveTopBtn: UIButton!
    
    let newsManger = RSSParserManager()
    var TodayHeatVC:HomePageTodayHeatViewController!
    var TargetWeightVC:HomePageTargetWeightViewController!
    var todayStepVC:HomePageTodayStepViewController!
    var newsArray = [NewsItem]()
    var myRefresh = UIRefreshControl()
    
    @IBOutlet weak var homePageTableView: UITableView!
    @IBOutlet weak var pageContainerView: UIView!
    
    var showNotConnectCell:Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        getNewsArray()
        
        homePageTableView.contentInset = UIEdgeInsets(top:pageHeightDefaultHeight,left:0,bottom:0, right: 0)
        
        var pageVC = UIPageViewController()
        pageVC = self.childViewControllers.first as! UIPageViewController
        
        pageVC.delegate = self
        pageVC.dataSource = self
        
        TodayHeatVC = storyboard?.instantiateViewController(withIdentifier: "HomePageTodayHeatViewController") as! HomePageTodayHeatViewController
        TargetWeightVC = storyboard?.instantiateViewController(withIdentifier: "HomePageTargetWeightViewController") as! HomePageTargetWeightViewController
        todayStepVC = storyboard?.instantiateViewController(withIdentifier: "HomePageTodayStepViewController") as! HomePageTodayStepViewController
        
        pageVC.setViewControllers([TodayHeatVC],direction: .forward,animated: false,completion: nil)
        homePageTableView.refreshControl = myRefresh
        myRefresh.addTarget(self, action: #selector(getNewsArray), for: .valueChanged)
        
        
        
    }
    
    
    func getNewsArray(){
        
        if newsManger.isConnect{
            
            showNotConnectCell = false
            newsManger.downloadList { (error, result) in
                
                if let err = error{
                    
                    SHLog(message:err)
                    
                    return
                }
                
                self.newsArray = result
                
                DispatchQueue.main.async {
                    self.homePageTableView.reloadData()
                }
            }
            
            
        }else{
            
            
            showNotConnectCell = true
            self.homePageTableView.reloadData()
            
        }
        
        myRefresh.endRefreshing()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func moveTopBtnAction(_ sender: Any) {
        
        let zero = IndexPath(row: 0, section: 0)
        homePageTableView.scrollToRow(at: zero, at: .top, animated: true)
        
    }
}


//MARK: - UIScrollViewDelegate
extension ViewController:UIScrollViewDelegate{
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        let offsetY = scrollView.contentOffset.y
        pageHeightConstraint.constant = offsetY < 0.0 ? -offsetY : 0.0
        
        if scrollView.contentOffset.y > view.frame.height*1.5{
            
            moveTopBtn.isHidden = false
        }else{
            
            moveTopBtn.isHidden = true
        }
    }
    
}



//MARK: - UITableViewDelegate,UITableViewDataSource
extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return showNotConnectCell == false ? newsArray.count:1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if !showNotConnectCell{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RssTableViewCell") as! RssTableViewCell
            cell.titleLabel.text = newsArray[indexPath.row].title
            cell.pudDate.text = newsArray[indexPath.row].pubDate
            cell.advanceImage.loadWithURL(urlString:newsArray[indexPath.row].imageURL)
            return cell
            
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailImageTableViewCell") as! DetailImageTableViewCell
            cell.selectImageView.image = UIImage(named:"not_connect")
            
            
            return cell
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if !showNotConnectCell{
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "NewsWebViewController") as!NewsWebViewController
            nextPage.newsLink = newsArray[indexPath.row].link
            nextPage.hidesBottomBarWhenPushed = true
            tableView.deselectRow(at:indexPath, animated: false)
            present(nextPage, animated: true, completion: nil)
        }
        
    }
}



//MARK: - UIPageViewControllerDelegate,UIPageViewControllerDataSource
extension ViewController:UIPageViewControllerDelegate,UIPageViewControllerDataSource{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        
        if viewController.isKind(of:HomePageTodayHeatViewController.self){
            return TargetWeightVC
            
            
        }else if viewController.isKind(of:HomePageTargetWeightViewController.self){
            return todayStepVC
        }
        
        return nil
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        
        if viewController.isKind(of:HomePageTargetWeightViewController.self){
            return TodayHeatVC
        }else if viewController.isKind(of: HomePageTodayStepViewController.self){
            return TargetWeightVC
        }
        
        return nil
        
    }
    
}
