//
//  XYMyuploadModel.swift
//  XYBackgroundUpload
//
//  Created by xiaoyi on 2017/8/28.
//  Copyright © 2017年 xiaoyi. All rights reserved.
//

import UIKit
import SwiftyJSON
class XYMyuploadCellModel: NSObject {

    //是否上传,2:上传中，0 未上传 1 已上传
    var uploadStatus:String!

    //uuid
    var uuid:String!
    //作品uuid
    var worksUuid:String!
    //本地音频地址
    var voiceFilePath:String!
    //脚本地址
    var scriptFilePath:String!
    
    /*本地存储使用*/
    //上传进度
    var uploadProgress:Float = 0.0
    


    
    
    //MARK: - json数据解析
    public class func testData() -> XYMyuploadCellModel{
        
        let model = XYMyuploadCellModel()
        

        
        model.uploadStatus = "0"
        
        
        return model
    }
    
    
    
    
}



class XYMyuploadListModel: NSObject {
    
    //录屏列表数组
    var uploadModelArr:[XYMyuploadCellModel] = Array()


    
    
    public class func TestData() -> XYMyuploadListModel {
        let uploadModel = XYMyuploadListModel()
        
        for index in 0..<8{
            
            let model = XYMyuploadCellModel.testData()
            if index%3 == 0{
                model.uploadStatus = "0"
            }
            model.uuid = String(index)
            model.voiceFilePath = XYBackgroundService.creatFileManagerArr()! + "/XYtest\(index+1).jpg"
            
            model.scriptFilePath = XYBackgroundService.creatFileManagerArr()! + "/XYtest\(index+1).json"
            uploadModel.uploadModelArr.append(model)
        }

        
        return uploadModel
        
    }
    
    
}

