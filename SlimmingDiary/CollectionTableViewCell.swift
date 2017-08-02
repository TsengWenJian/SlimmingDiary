//
//  CollectionTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

enum DiaryImageType:String{
    case food = "food"
    case sport = "sport"
}

class CollectionTableViewCell:UITableViewCell{
    
    
    var VC:TimeLineTableViewController?
    var diaryImageType:DiaryImageType = .food
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var data = [DiaryItem](){
        didSet{
            collectionView.reloadData()
        }
    }
    var current = 0
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self

        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        
    }
    
    
    
    
}
extension CollectionTableViewCell:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var  finalImage = UIImage()
        
        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage{
            finalImage = photo
            
        }
        if let myImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            finalImage = myImage
        }
        data[current].image = finalImage.resizeImage(maxLength:1024)
        collectionView.reloadData()
        VC?.dismiss(animated: true, completion: nil)
        
    }

    
    func launchImagePickerWithSourceType(type:UIImagePickerControllerSourceType){
        
        
        if UIImagePickerController.isSourceTypeAvailable(type) == false{
            return
            
        }
        
        let picker = UIImagePickerController()
        picker.sourceType =  type
        picker.delegate = self
        
        if type == .camera{
            picker.mediaTypes = ["public.image"]
            
        }else{
            picker.allowsEditing = true;
            
        }
        VC?.present(picker, animated: true, completion: nil)
        
    }
    
}

extension CollectionTableViewCell: UICollectionViewDataSource,UICollectionViewDelegate{
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
        let myImage = rowData.image != nil ? rowData.image:defaultImage
        
        
        cell.imageView.image = myImage
        cell.titleLabel.text = rowData.title
        cell.detailLabel.text = "\(rowData.detail)大卡"
        return cell
        
        
    }
    
    
    
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        current = indexPath.row
        
        let alertVC = UIAlertController(title:"選擇照片", message:"", preferredStyle:.actionSheet)
        
        let camera = UIAlertAction(title: "拍照", style: .default, handler: { (UIAlertAction) in
            self.launchImagePickerWithSourceType(type:.camera)
        })
        
        
        let library = UIAlertAction(title: "相簿", style: .default, handler: { (UIAlertAction) in
            self.launchImagePickerWithSourceType(type:.photoLibrary)
        })
        
        
        let cancel = UIAlertAction(title: "取消", style:.cancel, handler:nil)
        
        
        alertVC.addAction(camera)
        alertVC.addAction(library)
        alertVC.addAction(cancel)
        VC?.present(alertVC, animated: true, completion: nil)
        
    }
    

}


