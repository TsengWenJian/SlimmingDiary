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
    @IBOutlet weak var pageHeightConstraint: NSLayoutConstraint!{
        didSet{
            pageHeightConstraint.constant = pageHeightDefaultHeight
        }
    }
    @IBOutlet weak var moveTopBtn: UIButton!
  
    
    
    let newsManger = RSSParserManager()
    var TodayHeatVC:HomePageTodayHeatViewController!
    var TargetWeightVC:HomePageTargetWeightViewController!
    var newsArray = [NewsItem]()
    
    @IBOutlet weak var homePageTableView: UITableView!
    @IBOutlet weak var pageContainerView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            
        newsManger.downloadList { (error, result) in
            
            self.newsArray = result
            
            DispatchQueue.main.async {
                self.homePageTableView.reloadData()
            }
            
        }
        print(pageHeightDefaultHeight)

        homePageTableView.contentInset = UIEdgeInsets(top: pageHeightDefaultHeight
            ,left:0, bottom: 0, right: 0)
        
        var pageVC = UIPageViewController()
        pageVC = self.childViewControllers.first as! UIPageViewController
        
        pageVC.delegate = self
        pageVC.dataSource = self
        
        TodayHeatVC = storyboard?.instantiateViewController(withIdentifier: "HomePageTodayHeatViewController") as! HomePageTodayHeatViewController
        
        TargetWeightVC = storyboard?.instantiateViewController(withIdentifier: "HomePageTargetWeightViewController") as! HomePageTargetWeightViewController
        
        
        pageVC.setViewControllers([TodayHeatVC],direction: .forward,animated: false,completion: nil)
        
        
//        Database.database().reference().child("group").childByAutoId().child(ProfileManager.standard.userUid!).updateChildValues(["title":"30天不喝飲料","mesage":"fff"])
//        
//        
//        
//        Database.database().reference().child("users").observe(.value, with: { (DataSnapshot) in
//            print(DataSnapshot)
//        })
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return newsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RssTableViewCell") as! RssTableViewCell
        
        cell.titleLabel.text = newsArray[indexPath.row].title
        cell.pudDate.text = newsArray[indexPath.row].pubDate
        cell.advanceImage.loadWithURL(urlString: newsArray[indexPath.row].imageURL)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextPage = storyboard?.instantiateViewController(withIdentifier: "NewsWebViewController") as!NewsWebViewController
        nextPage.newsLink = newsArray[indexPath.row].link
        nextPage.hidesBottomBarWhenPushed = true
        tableView.deselectRow(at:indexPath, animated: false)
        navigationController?.pushViewController(nextPage, animated: true)
        
    }
    
    
}



//MARK: - UIPageViewControllerDelegate,UIPageViewControllerDataSource
extension ViewController:UIPageViewControllerDelegate,UIPageViewControllerDataSource{
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        
        if viewController.isKind(of:HomePageTodayHeatViewController.self){
            return TargetWeightVC
        }
    
        return nil
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        
        if viewController.isKind(of:HomePageTargetWeightViewController.self){
            return TodayHeatVC
        }
        
        return nil
        
    }
    
}
