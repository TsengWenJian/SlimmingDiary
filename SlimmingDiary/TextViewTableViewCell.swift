//
//  TextViewTableViewCell.swift
//  SlimmingDiary
//
//  Created by TSENGWENJIAN on 2017/7/29.
//  Copyright © 2017年 Nick. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet var textView: UITextView!
    var oneDiary: ADiary?
    var myTableView: UITableView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        let doneToolbar = UIToolbar(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: frame.width,
                                                  height: 50))
        doneToolbar.barStyle = .default
        doneToolbar.backgroundColor = UIColor.white

        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
                                        target: nil,
                                        action: nil)

        let doneBtn = UIBarButtonItem(title: "確定",
                                      style: UIBarButtonItemStyle.done,
                                      target: self,
                                      action: #selector(doneBtnAction))

        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(doneBtn)
        doneToolbar.items = items
        textView.inputAccessoryView = doneToolbar
        textView.delegate = self
    }

    @objc func doneBtnAction() {
        textView.resignFirstResponder()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "輸入點內容吧" {
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "輸入點內容吧"
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        oneDiary?.text = textView.text

        var bounds = textView.bounds
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let maxSize = CGSize(width: bounds.width, height: 1000)
        let newRect = NSString(string: textView.text).boundingRect(with: maxSize, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)

        let newSize = textView.sizeThatFits(newRect.size)
        bounds.size = newSize
        textView.bounds = bounds

        myTableView?.beginUpdates()
        myTableView?.endUpdates()
    }
}
