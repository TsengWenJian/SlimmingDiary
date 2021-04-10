//
//  ViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/5/26.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Firebase
import UIKit

class ViewController: UIViewController {
    var pageVCDefaultHeight: CGFloat = 214
    @IBOutlet var pageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var moveTopBtn: UIButton!
    @IBOutlet var homePageTableView: UITableView!
    @IBOutlet var pageContainerView: UIView!

    let newsManager = RSSParserManager()
    var TodayHeatVC: TodayHeatViewController?
    var TargetWeightVC: TargetWeightViewController?
    var todayStepVC: TodayStepViewController?
    var newsArray = [NewsItem]()
    var myRefresh = UIRefreshControl()

    var showNotConnectCell: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        getNewsArray()

        homePageTableView.contentInset = UIEdgeInsets(top: pageVCDefaultHeight, left: 0, bottom: 0, right: 0)

        var pageVC = UIPageViewController()
        pageVC = childViewControllers.first as! UIPageViewController

        pageVC.delegate = self
        pageVC.dataSource = self

        if let todayVC = storyboard?.instantiateViewController(withIdentifier: "TodayHeatViewController") as? TodayHeatViewController {
            TodayHeatVC = todayVC
            pageVC.setViewControllers([todayVC], direction: .forward, animated: false, completion: nil)
        }

        TargetWeightVC = storyboard?.instantiateViewController(withIdentifier: "TargetWeightViewController") as? TargetWeightViewController
        todayStepVC = storyboard?.instantiateViewController(withIdentifier: "TodayStepViewController") as? TodayStepViewController

        homePageTableView.refreshControl = myRefresh
        myRefresh.addTarget(self, action: #selector(getNewsArray), for: .valueChanged)
    }

    @objc func getNewsArray() {
        if newsManager.isConnect {
            showNotConnectCell = false
            newsManager.downloadList { error, result in

                if let err = error {
                    SHLog(message: err)

                    return
                }

                self.newsArray = result

                DispatchQueue.main.async {
                    self.homePageTableView.reloadData()
                }
            }

        } else {
            showNotConnectCell = true
            homePageTableView.reloadData()
        }

        myRefresh.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func moveTopBtnAction(_: Any) {
        let zero = IndexPath(row: 0, section: 0)
        homePageTableView.scrollToRow(at: zero, at: .top, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        pageHeightConstraint.constant = offsetY < 0.0 ? -offsetY : 0.0

        if scrollView.contentOffset.y > view.frame.height * 1.5 {
            moveTopBtn.isHidden = false
        } else {
            moveTopBtn.isHidden = true
        }
    }
}

// MARK: - UITableViewDelegate,UITableViewDataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return showNotConnectCell == false ? newsArray.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !showNotConnectCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RssTableViewCell") as! RssTableViewCell
            cell.titleLabel.text = newsArray[indexPath.row].title
            cell.pudDate.text = newsArray[indexPath.row].pubDate
            cell.advanceImage.loadWithURL(urlString: newsArray[indexPath.row].imageURL)
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailImageTableViewCell") as! DetailImageTableViewCell
            cell.selectImageView.image = UIImage(named: "not_connect")

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !showNotConnectCell {
            let nextPage = storyboard?.instantiateViewController(withIdentifier: "NewsWebViewController") as! NewsWebViewController
            nextPage.newsLink = newsArray[indexPath.row].link
            nextPage.hidesBottomBarWhenPushed = true
            tableView.deselectRow(at: indexPath, animated: false)
            present(nextPage, animated: true, completion: nil)
        }
    }
}

// MARK: - UIPageViewControllerDelegate,UIPageViewControllerDataSource

extension ViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: TodayHeatViewController.self) {
            return TargetWeightVC

        } else if viewController.isKind(of: TargetWeightViewController.self) {
            return todayStepVC
        }

        return nil
    }

    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.isKind(of: TargetWeightViewController.self) {
            return TodayHeatVC

        } else if viewController.isKind(of: TodayStepViewController.self) {
            return TargetWeightVC
        }

        return nil
    }
}
