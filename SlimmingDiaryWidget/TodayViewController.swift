//
//  TodayViewController.swift
//  SlimmingDiaryWidget
//
//  Created by TSENGWENJIAN on 2017/9/9.
//  Copyright © 2017年 Nick. All rights reserved.
//

import NotificationCenter
import UIKit

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet var foodCalorieLabel: UILabel!
    @IBOutlet var resultCalorieLabel: UILabel!
    @IBOutlet var sportCalorieLabel: UILabel!
    @IBOutlet var basicCalorieLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.

        extensionContext?.widgetLargestAvailableDisplayMode = .compact
    }

    @IBAction func goToHostAppAction(_: Any) {
        if let url = URL(string: "myWidget://123") {
            extensionContext?.open(url, completionHandler: { _ in

            })
        }
    }

    func setLabel() {
        if let shared = UserDefaults(suiteName: "group.SlimmingDiary"),
           let food = shared.value(forKey: "todayFoodCalories") as? Double,
           let sport = shared.value(forKey: "todaySportCalories") as? Double,
           let basic = shared.value(forKey: "baseCaloriesRequired") as? Double
        {
            DispatchQueue.main.async {
                self.basicCalorieLabel.text = "\(Int(basic))"
                self.foodCalorieLabel.text = "\(Int(food))"
                self.sportCalorieLabel.text = "\(Int(sport))"
                self.resultCalorieLabel.text = "\(Int(basic - food))"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
        // Perform any setup necessary in order to update the view.

        setLabel()
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.newData)
    }
}
