//
//  CollectionTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/28.
//  Copyright © 2017年 Nick. All rights reserved.
//

import Foundation
import UIKit

enum DiaryImageType: String {
    case food
    case sport
}

class CollectionTableViewCell: UITableViewCell {
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!

    var isEdit = false {
        didSet {
            let btnTitle = isEdit ?"Done" : "Edit"
            editBtn.setTitle(btnTitle, for: .normal)
        }
    }

    var currentTapItem = 0
    var VC: MakeDiarysTableViewController?
    var diaryImageType: DiaryImageType = .food

    var allDiarys = ADiary(date: "") {
        didSet {
            if let mydata = diaryImageType == .food ? allDiarys.food : allDiarys.sport {
                diaryItems = mydata
            }
        }
    }

    var diaryItems = [DiaryItem]() {
        didSet {
            if diaryImageType == .food {
                allDiarys.food = diaryItems
            } else {
                allDiarys.sport = diaryItems
            }

            let calorie = shareDiaryManager.standard.calSumCalorie(items: diaryItems)
            titleLabel.text = diaryImageType == .food ? "飲食" : "運動"
            detailLabel.text = diaryImageType == .food ? "攝取\(calorie)大卡" : "消耗 \(calorie)大卡"
            collectionView.reloadData()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func editBtnAction(_: Any) {
        var btnTitle: String

        if isEdit {
            btnTitle = "Edit"
            isEdit = false

        } else {
            btnTitle = "Done"
            isEdit = true
        }

        editBtn.setTitle(btnTitle, for: .normal)
        collectionView.reloadData()
    }
}

extension CollectionTableViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var finalImage = UIImage()

        if let photo = info[UIImagePickerControllerOriginalImage] as? UIImage {
            finalImage = photo
        }
        if let myImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            finalImage = myImage
        }

        diaryItems[currentTapItem].image = finalImage.resizeImage(maxLength: 1024)
        collectionView.reloadData()
        VC?.dismiss(animated: true, completion: nil)
    }

    func launchImagePickerWithSourceType(type: UIImagePickerControllerSourceType) {
        if UIImagePickerController.isSourceTypeAvailable(type) == false {
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = type
        picker.delegate = self

        if type == .camera {
            picker.mediaTypes = ["public.image"]

        } else {
            picker.allowsEditing = true
        }
        VC?.present(picker, animated: true, completion: nil)
    }
}

extension CollectionTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in _: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }

        return diaryItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InTableCollectionViewCell", for: indexPath) as! InTableCollectionViewCell

        if indexPath.section == 0 {
            cell.imageView.image = UIImage(named: "add")
            cell.titleLabel.text = ""
            cell.detailLabel.text = ""
            cell.isBeginEdit = false

        } else if indexPath.section == 1 {
            if isEdit {
                let wobble = CAKeyframeAnimation(keyPath: "transform.rotation")
                wobble.duration = 0.2
                wobble.repeatCount = MAXFLOAT
                wobble.values = [-0.08, 0.08, -0.08]
                wobble.isRemovedOnCompletion = false
                cell.layer.add(wobble, forKey: "cellRotato")

            } else {
                cell.layer.removeAnimation(forKey: "cellRotato")
            }

            let rowData = diaryItems[indexPath.row]
            let defaultImage = UIImage(named: diaryImageType.rawValue)

            if let _ = rowData.image {
                cell.imageView.image = rowData.image

            } else {
                if let url = rowData.imageURL {
                    cell.imageView.loadImageCacheWithURL(urlString: url)

                } else {
                    cell.imageView.image = defaultImage
                }
            }

            cell.titleLabel.text = rowData.title
            cell.detailLabel.text = "\(rowData.detail)大卡"
            cell.isBeginEdit = isEdit
            cell.deleteBtnAction.addTarget(self, action: #selector(deleteItem(_:)), for: .touchUpInside)
            cell.deleteBtnAction.tag = 1000 + indexPath.row
        }
        return cell
    }

    @objc func deleteItem(_ sender: UIButton) {
        let tag = sender.tag - 1000
        diaryItems.remove(at: tag)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentTapItem = indexPath.row

        if indexPath.section == 0 {
            let nextPage = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChoiceFoodViewController") as! ChoiceFoodViewController

            nextPage.actionType = .update
            nextPage.diaryType = diaryImageType
            nextPage.dinnerTime = ""

            nextPage.selectItemsDone = { (_) -> Void in

                if self.diaryImageType == .food {
                    for i in FoodMaster.standard.foodDiarys {
                        let detail = FoodMaster.standard.getFoodDataArray(.insert,
                                                                          foodDiaryId: nil,
                                                                          foodId: i.foodId,
                                                                          amount: i.amount,
                                                                          weight: i.weight)
                        let item = DiaryItem(image: i.image,
                                             title: detail[0],
                                             detail: detail[3])
                        self.diaryItems.append(item)
                    }

                } else {
                    for i in SportMaster.standard.sportDiarys {
                        SportMaster.standard.diaryType = .sportDetail
                        let cond = "\(SPORTDETAIL_ID)=\(i.sportId)"

                        let detail = SportMaster.standard.getSportDetails(.defaultData,
                                                                          minute: i.minute,
                                                                          cond: cond,
                                                                          order: nil).first

                        guard let firDetail = detail else {
                            continue
                        }

                        let item = DiaryItem(image: i.image,
                                             title: firDetail.sampleName,
                                             detail: "\(firDetail.calories)")
                        self.diaryItems.append(item)
                    }
                }
            }

            VC?.navigationController?.pushViewController(nextPage, animated: true)
            return
        }

        let alertVC = UIAlertController(title: "選擇照片", message: "", preferredStyle: .actionSheet)

        let camera = UIAlertAction(title: "拍照", style: .default, handler: { _ in
            self.launchImagePickerWithSourceType(type: .camera)
        })

        let library = UIAlertAction(title: "相簿", style: .default, handler: { _ in
            self.launchImagePickerWithSourceType(type: .photoLibrary)
        })

        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)

        alertVC.addAction(camera)
        alertVC.addAction(library)
        alertVC.addAction(cancel)
        VC?.present(alertVC, animated: true, completion: nil)
    }
}
