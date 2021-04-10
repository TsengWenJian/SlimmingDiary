
//
//  HomePageTargetWeightViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/12.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class TargetWeightViewController: UIViewController {
    let profileManager = ProfileManager.standard

    @IBOutlet var targetProgress: NickProgress3UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_: Bool) {
        let denominator = fabs(profileManager.userWeight - profileManager.userTargetWeight)
        let molecular = fabs(profileManager.userOriginWeight - profileManager.userTargetWeight)
        var progress = (1 - denominator / molecular) * 100

        //  NaN 0.0/0.0
        if progress.isNaN {
            progress = 0
        }

        let denominatorStr = String(format: "%.1f", denominator)

        DispatchQueue.main.async {
            if progress >= 100 {
                self.targetProgress.setTitleText(text: "恭喜")
                self.targetProgress.setSubTitleText(text: "達成目標")
                self.targetProgress.setDetailText(text: "")

            } else {
                self.targetProgress.setTitleText(text: "距離目標")
                self.targetProgress.setSubTitleText(text: denominatorStr)
                self.targetProgress.setDetailText(text: "kg")
            }

            // if progress is not change don't again anim
            if progress != self.targetProgress.getProgress() {
                self.targetProgress.resetProgress(progress)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
