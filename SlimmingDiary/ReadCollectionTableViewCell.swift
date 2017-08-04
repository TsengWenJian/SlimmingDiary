//
//  ReadCollectionTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/8/1.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class ReadCollectionTableViewCell: UITableViewCell {

    
    var VC:TimeLineTableViewController?
    var diaryImageType:DiaryImageType = .food
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var data = [DiaryItem](){
        didSet{
            
            let text = shareDiaryManager.standard.calSumCalorie(items: data)
            titleLabel.text = diaryImageType == .food ? "飲食":"運動"
            detailLabel.text = diaryImageType == .food ? "攝取\(text)大卡":"消耗 \(text)大卡"
            collectionView.reloadData()
        }
    }
    var currentTapRow = 0
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
}

extension ReadCollectionTableViewCell: UICollectionViewDataSource,UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return  data.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InTableCollectionViewCell",for: indexPath) as! InTableCollectionViewCell
        let rowData = data[indexPath.row]
        
        
        
        let defaultImage = UIImage(named:diaryImageType.rawValue)
        
    
        
        if let imageURL = rowData.imageURL{
        
            cell.imageView.loadImageCacheWithURL(urlString: imageURL)
            
        }else{
            
             cell.imageView.image = defaultImage
            
        }
        

       
        cell.titleLabel.text = rowData.title
        cell.detailLabel.text = "\(rowData.detail)大卡"
        return cell
        
        
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
//        
//        let width = self.frame.width/3
//        return CGSize(width: width, height:width)
//    }
    
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentTapRow = indexPath.row
        
    
}
}

