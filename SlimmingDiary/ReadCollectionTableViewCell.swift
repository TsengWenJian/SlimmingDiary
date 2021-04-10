//
//  ReadCollectionTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/1.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ReadCollectionTableViewCell: UITableViewCell {
    var VC: ShowDiarysDetailViewController?
    var diaryImageType: DiaryImageType = .food

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!

    var data = [DiaryItem]() {
        didSet {
            let text = shareDiaryManager.standard.calSumCalorie(items: data)
            titleLabel.text = diaryImageType == .food ? "飲食" : "運動"
            detailLabel.text = diaryImageType == .food ? "攝取\(text)大卡" : "消耗 \(text)大卡"
            collectionView.reloadData()
        }
    }

    var currentTapRow = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

extension ReadCollectionTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InTableCollectionViewCell", for: indexPath) as! InTableCollectionViewCell
        let rowData = data[indexPath.row]

        let defaultImage = UIImage(named: diaryImageType.rawValue)

        if let imageURL = rowData.imageURL {
            cell.imageView.loadImageCacheWithURL(urlString: imageURL)

        } else {
            cell.imageView.image = defaultImage
        }

        cell.titleLabel.text = rowData.title
        cell.detailLabel.text = "\(rowData.detail)大卡"
        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {
        let nextPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ShowDiaryImageViewController") as! ShowDiaryImageViewController

        let filterData = data.filter { (item) -> Bool in

            if item.imageURL != nil {
                return true
            } else {
                return false
            }
        }

        if filterData.count >= 1 {
            nextPage.diaryItems = filterData
            nextPage.currentItem = currentTapRow
            nextPage.displayPickViewDialog(present: VC!)
        }
    }
}
