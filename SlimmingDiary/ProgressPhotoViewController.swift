//
//  ProgressPhotoViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/17.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit
import Social


class ProgressPhotoViewController:UIViewController{
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageScrollView2: UIScrollView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var containerLabelView: UIView!
    @IBOutlet weak var displayImageView2: UIImageView!
    @IBOutlet weak var displayImageView: UIImageView!
    
    
    @IBOutlet weak var containerScrollView: UIView!
    @IBOutlet weak var imageScrollView2Trailing: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var kgLabel: UILabel!
    @IBOutlet weak var date2Label: UILabel!
    @IBOutlet weak var kg2Label: UILabel!
    @IBOutlet weak var isCompareBtn: UIButton!
    
    var isCompare:Bool = false
    var timer:Timer?
    var type:String?
    var weightId:Int?
    let weightMaster = WeightMaster.standard
    var weightArray = [WeightDiary]()
    
    var imageNumber:Int = 0 {
        didSet{
            changeLabelText()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "進展圖片"
        setPlayNavBtn()
        
        
        guard let myType = type else{
            return
        }
        
        
        
        imageScrollView2Trailing.constant = -view.frame.width/2
        
        weightMaster.diaryType = .weightDiary
        let cond = "\(WEIGHTDIARY_PHOTO) != 'No_Image' and \(WEIGHTDIARY_TYPE) = '\(myType)'"
        let order = "\(WEIGHTDIARY_DATE) asc"
        weightArray = weightMaster.getWeightDiary(cond:cond,order:order)
        imageNumber = 0
        
        
        
        let distance = view.frame.midX - view.frame.width/8
        photoCollectionView.contentInset = UIEdgeInsets(top:0,
                                                        left:distance,
                                                        bottom:0,
                                                        right: distance)
        
        
        
        
        
        imageScrollView.tag = 100
        
        
        
        imageScrollView.maximumZoomScale = 3.0
        imageScrollView.minimumZoomScale = 1
        imageScrollView.zoomScale = 1.0
        imageScrollView.contentInset = UIEdgeInsets(top:100,left:0,bottom:100,right: 100)
        
        
        
        
        imageScrollView2.tag = 200
        imageScrollView2.maximumZoomScale = 3.0
        imageScrollView2.minimumZoomScale = 1
        imageScrollView2.zoomScale = 1.0
        imageScrollView2.contentInset = UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100)
        
        
        for (index,value) in weightArray.enumerated(){
            
            if value.id == weightId{
                setContentOffSet(index:index)
                return
                
            }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        endTimer()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // photo Collection view contentoffset
    func setContentOffSet(index:Int){
        let itemWidth = view.frame.width/4
        let offset = -(photoCollectionView.contentInset.left)
        let x = CGPoint(x:offset + itemWidth*CGFloat(index),y:0)
        photoCollectionView.setContentOffset(x,animated: true)
        
        
    }
    
    
    @objc func startTimer(){
        photoCollectionView.isScrollEnabled = false
        photoCollectionView.allowsSelection = false
        
        navigationItem.rightBarButtonItems?.remove(at: 0)
        let puse = UIBarButtonItem(barButtonSystemItem: .pause,
                                   target: self,
                                   action:#selector(endTimer))
        navigationItem.rightBarButtonItem = puse
        
        
        var count = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (Timer) in
            
            self.displayImageView.image = UIImage(imageName:self.weightArray[count].imageName,search:.documentDirectory)
            
            
            count+=1
            
            if count == self.weightArray.count{
                count = 0
                
            }
            
        }
        
    }
    
    @objc func endTimer(){
        
        photoCollectionView.isScrollEnabled = true
        photoCollectionView.allowsSelection = true
        setPlayNavBtn()
        timer?.invalidate()
        timer = nil
        
        
    }
    
    func setPlayNavBtn(){
        
        navigationItem.rightBarButtonItems?.removeAll()
        
        let  share = UIBarButtonItem(title: "分享", style: .plain, target:self, action: #selector(shareWightImage))
        let  play = UIBarButtonItem(barButtonSystemItem:.play,
                                    target:self,
                                    action:#selector(startTimer))
        navigationItem.rightBarButtonItems = [play,share]
        
        
        
    }
    
    @objc func shareWightImage(){
        
        
        isCompareBtn.isHidden = true
        self.containerScrollView.alpha = 0.5

        UIView.animate(withDuration: 0.3, animations: {
         self.containerScrollView.alpha = 1

        }) { (Bool) in
           
            
            let viewSize = CGRect(x:0,
                            y:0,
                            width:self.containerScrollView.frame.width*2,
                            height:self.containerScrollView.frame.height*2)
            
            let selectSize = CGSize(width:self.containerScrollView.frame.width*2,
                                    height:(self.imageScrollView2.frame.height+self.containerLabelView.frame.height*3/4)*2)
            UIGraphicsBeginImageContext(selectSize)
            self.containerScrollView.drawHierarchy(in:viewSize, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            self.isCompareBtn.isHidden = false
            
            if let myImage = image{
            
            let activityViewController = UIActivityViewController(activityItems:[myImage], applicationActivities:nil)
            self.present(activityViewController, animated: true, completion: nil)
            }
        }

        
    }
    
    
    
    
    
    func changeLabelText(){
        
        
        if weightArray.count>0{
            
            let date =  "\(weightArray[imageNumber].date) \(weightArray[imageNumber].time)"
            let kg = "\(weightArray[imageNumber].value) kg"
            
            if isCompare{
                
                date2Label.text = date
                kg2Label.text = kg
                displayImageView2.image = UIImage(imageName:weightArray[imageNumber].imageName,search:.documentDirectory)
                
                return
            }
            
            displayImageView.image =  UIImage(imageName:weightArray[imageNumber].imageName,search:.documentDirectory)
            dateLabel.text = date
            kgLabel.text = kg
            
            
        }
        
    }
    
    
    @IBAction func compareBtnAction(_ sender: Any) {
        
        var traing:CGFloat
        
        if isCompare {
            
            traing = -view.frame.width/2
            isCompare = false
            isCompareBtn.isSelected = false
            
            
        }else{
            
            traing = 0
            isCompare = true
            isCompareBtn.isSelected = true
            changeLabelText()
            
            
        }
        
        UIView.animate(withDuration: 0.3) {
            self.imageScrollView2Trailing.constant = traing
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    
}
//MARK: -UICollectionViewDelegate,UICollectionViewDataSource
extension ProgressPhotoViewController:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return weightArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgressPhotoCollectionViewCell",for: indexPath)
            as! ProgressPhotoCollectionViewCell
        cell.photoImageView.image = UIImage(imageName:weightArray[indexPath.row].imageName,search:.documentDirectory)
        
        
        return cell
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = view.frame.width/4
        
        return CGSize(width: width, height:width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setContentOffSet(index:indexPath.row)
        
    }
}

//MARK: -UIScrollViewDelegate
extension ProgressPhotoViewController:UIScrollViewDelegate{
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        //  container photo scrollView
        if scrollView.tag == 100 || scrollView.tag == 200{
            
            
            
            return
        }
        
        let itemHalf = view.frame.width/4
        let offset = scrollView.contentOffset.x + view.frame.midX - itemHalf/2
        let number = Int(round(offset/itemHalf))
        
        
        
        if number == imageNumber{
            return
        }
        
        if number >= 0 && number < weightArray.count{
            
            imageNumber = number
        }
        
    }
    
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        if scrollView.tag == 100 {
            
            return displayImageView
            
        }else if scrollView.tag == 200{
            
            return displayImageView2
        }
        
        return nil
    }
}
