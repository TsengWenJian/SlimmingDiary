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
    var myRefresh = UIRefreshControl()
    
    @IBOutlet weak var homePageTableView: UITableView!
    @IBOutlet weak var pageContainerView: UIView!
    
    var newsReach = Reachability(hostName:"www.apple.com")
    
    var isConnect:Bool{
        guard let reach = newsReach else{
            return false
        }
        return reach.checkInternetFunction()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        checkIsLogInSetUserDefault()
        getNewsArray()
        
        homePageTableView.contentInset = UIEdgeInsets(top:pageHeightDefaultHeight
            ,left:0,bottom:0, right: 0)
        
        var pageVC = UIPageViewController()
        pageVC = self.childViewControllers.first as! UIPageViewController
        
        pageVC.delegate = self
        pageVC.dataSource = self
        
        TodayHeatVC = storyboard?.instantiateViewController(withIdentifier: "HomePageTodayHeatViewController") as! HomePageTodayHeatViewController
        
        TargetWeightVC = storyboard?.instantiateViewController(withIdentifier: "HomePageTargetWeightViewController") as! HomePageTargetWeightViewController
        
        
        pageVC.setViewControllers([TodayHeatVC],direction: .forward,animated: false,completion: nil)
        
        homePageTableView.refreshControl = myRefresh
        myRefresh.addTarget(self, action: #selector(getNewsArray), for: .valueChanged)
        
        
        
        
    }
    
    func checkIsLogInSetUserDefault(){
        
        if DataService.standard.isLogin{
            
            if ProfileManager.standard.userUid == nil{
                
                guard let user = DataService.standard.currentUser else{
                    
                    return
                }
                DataService.standard.downlondUserDataWithLogin(done: { (userData) in
                    
                    
                    guard let dict = userData,
                        let name = dict["name"] as? String  else{
                            return
                    }
                    
                    
                    
                    if let imageURLString = dict["imageURL"] as? String,
                        let url = URL(string:imageURLString){
                        
                        let photoName = "Profile_\(user.uid)"
                        
                        DataService.standard.downloadImageSaveWithCaches(url:url, imageName:photoName,done:{ (error) in
                            
                            ProfileManager.standard.setPhotName(photoName)
                            
                        })
                    }
                    
                    ProfileManager.standard.setUid(user.uid)
                    ProfileManager.standard.setUserName(name)
                    ProfileManager.standard.setUserEmail(user.email)
                    
                    
                })
            }
        }
        
        
        

        
        
    }
    
    func getNewsArray(){
        
        if isConnect{
            
            newsManger.downloadList { (error, result) in
                
                if let  err = error{
                    print(err)
                    return
                }
                
                self.newsArray = result
                DispatchQueue.main.async {
                    self.homePageTableView.reloadData()
                }
            }
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
        
        
        return isConnect ? newsArray.count:1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isConnect{
            
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
        
        if isConnect{
            
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
