//
//  ShowDiaryImageViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/7.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ShowDiaryImageViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    var diaryItems = [DiaryItem]()
    var currentItem = 0

    @IBOutlet var containerScrollView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.contentSize = CGSize(width: CGFloat(diaryItems.count) * containerScrollView.frame.width,
                                        height: scrollView.frame.height - 44)

        for (index, item) in diaryItems.enumerated() {
            let imageView = UIImageView(frame: CGRect(x: containerScrollView.frame.width * CGFloat(index),
                                                      y: 0,
                                                      width: containerScrollView.frame.width,
                                                      height: scrollView.frame.height))

            imageView.contentMode = .scaleAspectFit

            if let url = item.imageURL {
                imageView.loadImageCacheWithURL(urlString: url)
            }

            scrollView.addSubview(imageView)
            let titlelabel = UILabel(frame: CGRect(x: 0, y: 0, width: imageView.frame.width, height: 50))
            titlelabel.text = "\(item.title) \(item.detail) 大卡"
            titlelabel.textColor = UIColor.white
            titlelabel.textAlignment = .center
            imageView.addSubview(titlelabel)
        }

        let currentImagePoint = CGPoint(x: containerScrollView.frame.width * CGFloat(currentItem), y: 0)
        scrollView.setContentOffset(currentImagePoint, animated: false)
    }

    @IBAction func cancelBtn(_: Any) {
        hiddleDialog()
    }

    func displayPickViewDialog(present: UIViewController) {
        view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        view.alpha = 0

        UIView.animate(withDuration: 0.2) {
            self.view.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.view.alpha = 1
        }
        present.addChildViewController(self)
        present.view.addSubview(view)
        didMove(toParentViewController: self)
    }

    func hiddleDialog() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
