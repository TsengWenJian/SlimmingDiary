//
//  CollectionTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Foundation

enum DiaryImageType:String{
    case food = "food"
    case sport = "sport"
    
}

class CollectionTableViewCell:UITableViewCell{
    
    
    
    
    
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isEdit = false
    var currentTapItem = 0
    var VC:MakeShareDiaryTableViewController?
    var diaryImageType:DiaryImageType = .food
    
    var allData = OneDiaryRecord(food:nil,sport:nil,text:nil, date: ""){
        
        didSet{
            
            if let mydata = diaryImageType == .food ? allData.food:allData.sport {
                
                data = mydata
                
            }
        }
    }
    
    var data = [DiaryItem](){
        
        didSet{
            
            if diaryImageType == .food{
                
                allData.food = data
            }else{
                
                allData.sport = data
            }
            
            
            let text = shareDiaryManager.standard.calSumCalorie(items: data)
            titleLabel.text = diaryImageType == .food ? "飲食":"運動"
            detailLabel.text = diaryImageType == .food ? "攝取\(text)大卡":"消耗 \(text)大卡"
            collectionView.reloadData()
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    
    @IBAction func editBtnAction(_ sender: Any) {
        
        
        var btnTitle:String
        
        if isEdit{
            
            btnTitle = "Edit"
            isEdit = false
            
        }else{
            
            btnTitle = "Done"
            isEdit = true
        }
        
        editBtn.setTitle(btnTitle, for: .normal)
        collectionView.reloadData()
        
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
        
        data[currentTapItem].image = finalImage.resizeImage(maxLength:1024)
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
        return  2
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }
        
        return  data.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InTableCollectionViewCell",for: indexPath) as! InTableCollectionViewCell
        
        
        if indexPath.section == 0{
            
            
            cell.imageView.image = UIImage(named: "add")
            cell.titleLabel.text = ""
            cell.detailLabel.text = ""
            cell.isBeginEdit = false
            
            
            
            
        }else if indexPath.section == 1{
            
            if isEdit{
                
                let wobble = CAKeyframeAnimation(keyPath: "transform.rotation")
                wobble.duration = 0.2
                wobble.repeatCount = MAXFLOAT
                
                wobble.values = [-0.08,0.08,-0.08]
                wobble.isRemovedOnCompletion = false
                cell.layer.add(wobble,forKey:"cellRotato")
                
                
            }else{
                
                cell.layer.removeAnimation(forKey: "cellRotato")
                
            }
            
            
            let rowData = data[indexPath.row]
            let defaultImage = UIImage(named:diaryImageType.rawValue)
            let myImage = rowData.image != nil ? rowData.image:defaultImage
            
            
            cell.imageView.image = myImage
            cell.titleLabel.text = rowData.title
            cell.detailLabel.text = "\(rowData.detail)大卡"
            cell.isBeginEdit = isEdit
            cell.deleteBtnAction.addTarget(self,action: #selector(deleteItem(_:)), for: .touchUpInside)
            cell.deleteBtnAction.tag = 1000 + indexPath.row
            
            
        }
        return cell
        
        
    }
    
    func deleteItem(_ sender:UIButton){
        
        let tag = sender.tag - 1000
        data.remove(at:tag)
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentTapItem = indexPath.row
        
        if indexPath.section == 0{
            
            let nextPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChoiceFoodViewController") as! ChoiceFoodViewController
            
            nextPage.lastPageVC = .update
            nextPage.diaryType = diaryImageType
            nextPage.dinnerTime = ""
            
            
            nextPage.selectFoodDone = {(done)->()in
                
                if self.diaryImageType == .food{
                
                for i in foodMaster.standard.foodDiaryArrary{
                    let detail = foodDetailManager().getFoodDataArray(.insert,
                                                                      foodDiaryId:nil,
                                                                      foodId:i.foodId,
                                                                      amount:i.amount,
                                                                      weight:i.weight)
                    
                    let item:DiaryItem =  DiaryItem(image:i.image,
                                                    title:detail[0],
                                                    detail:detail[3])
                    self.data.append(item)
                    
                }
                    
                }else{
                    
                    
                    for i in SportMaster.standard.sportDiaryArrary{
                        
                        print(i)
                        SportMaster.standard.diaryType = .sportDiaryAndDetail
                       let cond = "Sport_Diary.SportDiary_DetailId=SportDetail_Id"

                       let detail = SportMaster.standard.getSportDetails(.defaultData,
                                                                         minute:i.minute,
                                                                         cond: cond,
                                                                         order:nil).first
                        
                        
                        guard let firDetail = detail else{
                            continue
                        }
                        
                        
                        let item:DiaryItem =  DiaryItem(image:i.image,
                                                        title:firDetail.sampleName,
                                                        detail:"\(firDetail.calories)")
                        self.data.append(item)

                    }
                }
                
            }
            
            
            VC?.navigationController?.pushViewController(nextPage, animated: true)
            return
            
        }
        
        
        
        
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


