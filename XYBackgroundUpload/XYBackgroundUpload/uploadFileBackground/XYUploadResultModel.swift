//
//  XYUploadResultModel.swift
//  XYBackgroundUpload
//
//  Created by xiaoyi on 2017/9/5.
//  Copyright © 2017年 xiaoyi. All rights reserved.
//

import UIKit
import SwiftyJSON
class XYUploadResultModel: NSObject {
    //已上传的音频文件Url
    var voiceFileUrl:String!
    //已上传的脚本文件Url
    var scriptFileUrl:String!
    //uuid
    var uuid:String!
    
    
    //在这里解析你从后台拿到的json数据
    class func praseUploadResult(jsonData:JSON) -> String {
        
        var materialFullPath = ""
        
        if jsonData["success"].boolValue == true {
            if jsonData["result"]["files"].arrayValue.count > 0{
                materialFullPath = (jsonData["result"]["files"].arrayValue.first!)["materialFullPath"].stringValue
            }
        }
        
        return materialFullPath
    }
    
    
}
