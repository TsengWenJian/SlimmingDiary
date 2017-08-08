//
//  ProgressPhotoViewController.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/17.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit


class ProgressPhotoViewController:UIViewController{
    
    
    @IBOutlet weak var imageScrollView2: UIScrollView!
    
    
    
    @IBOutlet weak var imageScrollView2Trailing: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var displayPlayPhoto2: UIImageView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
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
        let cond = "Weight_Photo != 'No_Image' and Weight_Type = '\(myType)'"
        let order = "Weight_Date asc"
        weightArray = weightMaster.getWeightDiary(cond:cond,order:order)
        imageNumber = 0
        
        
        
        let distance = view.frame.midX - view.frame.width/8
        photoCollectionView.contentInset = UIEdgeInsets(top:0,
                                                        left:distance,
                                                        bottom:0,
                                                        right: distance)
        
        
        
        
        imageScrollView.delegate = self
        imageScrollView.tag = 100
        
        
        
        imageScrollView.maximumZoomScale = 3.0
        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.zoomScale = 1.1
        
        
        
        imageScrollView2.delegate = self
        imageScrollView2.tag = 200
        imageScrollView2.maximumZoomScale = 3.0
        imageScrollView2.minimumZoomScale = 1.0
        imageScrollView2.zoomScale = 1.1
        
        
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
    
    
    func startTimer(){
        photoCollectionView.isScrollEnabled = false
        photoCollectionView.allowsSelection = false
        
        navigationItem.rightBarButtonItems?.removeAll()
        let puse = UIBarButtonItem(barButtonSystemItem: .pause,
                                   target: self,
                                   action:#selector(endTimer))
        navigationItem.rightBarButtonItem = puse
        
        
        var count = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (Timer) in
            
            self.displayImageView.image = UIImage(imageName:self.weightArray[count].photo,search:.documentDirectory)
            
            
            count+=1
            
            if count == self.weightArray.count{
                count = 0
                
            }
            
        }
        
    }
    
    func endTimer(){
        
        photoCollectionView.isScrollEnabled = true
        photoCollectionView.allowsSelection = true
        setPlayNavBtn()
        timer?.invalidate()
        timer = nil
        
        
    }
    
    func setPlayNavBtn(){
        
        navigationItem.rightBarButtonItems?.removeAll()
        let  play = UIBarButtonItem(barButtonSystemItem:.play,
                                    target:self,
                                    action:#selector(startTimer))
        navigationItem.rightBarButtonItem = play
        
    }
    
    
    

    
    func changeLabelText(){
        
        
        if weightArray.count>0{
            
            let date =  "\(weightArray[imageNumber].date) \(weightArray[imageNumber].time)"
            let kg = "\(weightArray[imageNumber].value) kg"
            
            if isCompare{
                
                date2Label.text = date
                kg2Label.text = kg
                displayPlayPhoto2.image = UIImage(imageName:weightArray[imageNumber].photo,search:.documentDirectory)
                
                return
            }
            
            displayImageView.image =  UIImage(imageName:weightArray[imageNumber].photo,search:.documentDirectory)
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
extension ProgressPhotoViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  1
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return weightArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProgressPhotoCollectionViewCell",for: indexPath)
            as! ProgressPhotoCollectionViewCell
        cell.photoImageView.image = UIImage(imageName:weightArray[indexPath.row].photo,search:.documentDirectory)
        
        
        return cell
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        
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
            
            scrollView.contentSize = CGSize(width: 500, height: 500)
           
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
            
            return displayPlayPhoto2
        }
        
        return nil
    }
}
