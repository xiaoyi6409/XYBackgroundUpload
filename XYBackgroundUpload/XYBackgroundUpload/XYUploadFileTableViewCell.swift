//
//  XYUploadFileTableViewCell.swift
//  XYBackgroundUpload
//
//  Created by xiaoyi on 2017/9/11.
//  Copyright © 2017年 xiaoyi. All rights reserved.
//

import UIKit

class XYUploadFileTableViewCell: UITableViewCell {

    let seperateLineHeight = CGFloat(1)
    let screencapImageToLeft = CGFloat(13)

    var startUploadBtn:UIButton!

    var browseNumLabel:UILabel!
    
    let whetherUploadLabelToRight = CGFloat(15)
    let whetherUploadLabelWidth = CGFloat(48)
    let whetherUploadLabelHeight = CGFloat(23)
    var seperateProgressView:UIProgressView!
    var whetherUploadLabel:UILabel!

    var model:XYMyuploadCellModel!
    var service:XYBackgroundService!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if !self.isEqual(nil) {
            

            
            
            startUploadBtn = UIButton(frame: CGRect(x: screencapImageToLeft, y: 18, width: 100 , height: 44))
            startUploadBtn.setTitle("点击上传文件", for: .normal)
            startUploadBtn.setTitleColor(.gray, for: .normal)
            startUploadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            startUploadBtn.titleLabel?.textAlignment = .left
            startUploadBtn.addTarget(self, action: #selector(startUploadBtnAct(sender:)), for: .touchUpInside)

            self.addSubview(startUploadBtn)
            
            
            
            whetherUploadLabel = UILabel(frame: CGRect(x: SCREEN_WIDTH - whetherUploadLabelToRight - whetherUploadLabelWidth, y: 30, width: whetherUploadLabelWidth, height: whetherUploadLabelHeight))
            whetherUploadLabel.textAlignment = .center
            whetherUploadLabel.font = UIFont.systemFont(ofSize: 12)
            whetherUploadLabel.layer.cornerRadius = 3
            whetherUploadLabel.layer.borderWidth = 1
            self.addSubview(whetherUploadLabel)
            

            
            seperateProgressView = UIProgressView(frame: CGRect(x: screencapImageToLeft, y: whetherUploadLabel.frame.maxY + 10, width: SCREEN_WIDTH - screencapImageToLeft*2, height: 3))
            seperateProgressView.progressTintColor = .red
            seperateProgressView.trackTintColor = .gray
            
            self.addSubview(seperateProgressView)
            
        }
    }
    
    
    func setModel(model:XYMyuploadCellModel){
        
        self.model = model
        
        if  model.uploadStatus == "1" {
            whetherUploadLabel.text = "已上传"
            whetherUploadLabel.textColor = .red
            whetherUploadLabel.layer.borderColor = UIColor.red.cgColor
        }else if model.uploadStatus == "0"{
            whetherUploadLabel.text = "未上传"
            whetherUploadLabel.textColor = UIColor.gray
            whetherUploadLabel.layer.borderColor = UIColor.gray.cgColor
        }else if  model.uploadStatus == "2" {
            whetherUploadLabel.text = "上传中"
            whetherUploadLabel.textColor = UIColor.blue
            whetherUploadLabel.layer.borderColor = UIColor.blue.cgColor
        }
        
        seperateProgressView.progress = model.uploadProgress

        
    }
    
    func startUploadBtnAct(sender:UIButton){
        sender.isEnabled = false
        
        DispatchQueue.global().async { [weak self] in
            if self?.model.uploadStatus == "0"{
                self?.service = XYBackgroundService()
                self?.service.startBackgroudUpdload(uploadVC: self!.getViewControllerFromView() as! ViewController, uuid:self!.model.uuid , model: self!.model)
            }
            
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UIView {
    //MARK: - 获得当前VIEW的viewcontroller
    func getViewControllerFromView()->UIViewController?{
        var next:UIView? = self
        repeat{
            if  next?.next is UIViewController{
                return (next?.next as! UIViewController)
            }
            next = next?.superview
        }while next != nil
        return nil
}
}


