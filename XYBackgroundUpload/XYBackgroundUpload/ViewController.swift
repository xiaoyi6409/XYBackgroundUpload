//
//  ViewController.swift
//  XYBackgroundUpload
//
//  Created by xiaoyi on 2017/9/19.
//  Copyright © 2017年 xiaoyi. All rights reserved.
//

import UIKit
import UserNotifications


let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let STATUS_NAV_HEIGHT: CGFloat = 64.0
var backgroundSession:URLSession!




class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    //已公开tableView
    public var backgroundServiceTableView:UITableView!
    
    public var serviceModelArr:[XYMyuploadCellModel] = XYMyuploadListModel.TestData().uploadModelArr
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.gray
        
        self.view.addSubview(createbackgroundServiceTableView())
        
        XYBackgroundService.createTestFile()
        
        
    }
    
    

    
    //MARK: - 创建backgroundServiceTableView
    func createbackgroundServiceTableView() -> UITableView{
        
        backgroundServiceTableView = UITableView(frame: CGRect(x:0,y:0, width:SCREEN_WIDTH, height:SCREEN_HEIGHT), style: .plain)
        backgroundServiceTableView.backgroundColor = .white
        backgroundServiceTableView.showsVerticalScrollIndicator = false
        backgroundServiceTableView.separatorStyle = .none
        backgroundServiceTableView.dataSource = self
        backgroundServiceTableView.delegate = self
        
        
        return backgroundServiceTableView
        
    }
    
    
    
    //MARK: - tableview delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func  tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceModelArr.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  68
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "XYUploadFileTableViewCell")
        if cell == nil {
            cell = XYUploadFileTableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "XYScreencapTableViewCell")
        }
        if let targetCell = cell as? XYUploadFileTableViewCell{
            targetCell.selectionStyle = .none
            
            
            targetCell.setModel(model: serviceModelArr[indexPath.row])
            
            return targetCell
        }else{
            return cell!
        }
        
    }


}

