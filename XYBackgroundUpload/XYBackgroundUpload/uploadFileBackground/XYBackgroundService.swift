//
//  XYBackgroundService.swift
//  XYBackgroundUpload
//
//  Created by xiaoyi on 2017/9/1.
//  Copyright © 2017年 xiaoyi. All rights reserved.
//

import UIKit
import SwiftyJSON

//文件上传
let uploadFileUrl = "你的上传文件的URL地址"

//这里用来存储所有正在上传的session，与UUID绑定，方便以后在退出屏幕与删除上传的时候做处理
var globaluploadingSessionArr:[Dictionary<String,URLSession>] = Array()


class XYBackgroundService: NSObject ,URLSessionDelegate,URLSessionTaskDelegate,URLSessionDataDelegate{
    
    let XYboundary = "------------XY2017"
    let XYNewLine = "\r\n".data(using: .utf8)
    //后台会话
    var backgroundSession:URLSession!
    //上传返回的服务器数据
    var responseData:NSMutableData!
    //上传结果的Json
    var uploadResultJson:JSON!
    //seivice 目标VC
    weak var targetVC:ViewController!
    
    //当前的UUID
    var uuid:String!
    
    //上传的进度值
    var progressValue:Float = 0.0
    //待上传文件路径数组
    var uploadFilePathArr:[String] = Array()
    //当前上传文件的下标
    var currentUploadIndex:Int = 0
    //已上传的文件信息
    var uploadFileModel = XYUploadResultModel()
    
    
    
    //MARK: - 创建后台请求session
    func creatBackgroundSession(){
        
        let nowDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYYMMddHHMMSS"
        let dateStr =  dateFormatter.string(from: nowDate)
        
        let randomNum = Int(arc4random()%10000)+1
        
        let configrationIdentifier =  "XY" + dateStr + String(randomNum)
        print("configrationIdentifier---->\(configrationIdentifier)")
        
        let backgroundSessionConfigration = URLSessionConfiguration.background(withIdentifier: configrationIdentifier)
        //设置后台上传时的超时timeoutIntervalForResource，默认值为1周
        backgroundSessionConfigration.timeoutIntervalForResource = 24*60*60
        
        //backgroundSessionConfigration.httpMaximumConnectionsPerHost = 1
        backgroundSession = URLSession(configuration: backgroundSessionConfigration, delegate: self, delegateQueue: OperationQueue.main)
        
        
    }
    
    //MARK: - 准备开始后台上传
    func startBackgroudUpdload(uploadVC:ViewController,uuid:String,model:XYMyuploadCellModel){
        
        if fileIsExists(filePath: model.voiceFilePath) == false ||  fileIsExists(filePath: model.scriptFilePath) == false {
            print("文件不存在")
            return
        }
        
        
        //更新正在上传状态
        DispatchQueue.main.async { [weak uploadVC] in
            if uploadVC != nil{
                for index in 0..<uploadVC!.serviceModelArr.count {
                    if uploadVC?.serviceModelArr[index].uuid == uuid {
                        uploadVC?.serviceModelArr[index].uploadStatus = "2"
                        break
                    }
                }
                
                uploadVC?.backgroundServiceTableView.reloadData()
            }
        }
        
        
        //当点击上传时，创建session
        creatBackgroundSession()
        //将上传session加入全局变量
        globaluploadingSessionArr.append([uuid:backgroundSession])
        
        
        
        self.targetVC = uploadVC
        self.uuid = uuid
        
        
        uploadFilePathArr.append(model.voiceFilePath)
        uploadFilePathArr.append(model.scriptFilePath)
        
        //开始上传第一个文件
        if uploadFilePathArr.count > 0 {
            
            if fileIsExists(filePath: uploadFilePathArr[currentUploadIndex]) {
                uploadFile(filePath:uploadFilePathArr[currentUploadIndex])
            }
            
        }
        
    }
    
    
    //MARK: - 单个文件上传
    func uploadFile(filePath:String) {
        
        let url = uploadFileUrl
        
        //设置请求头
        var request = URLRequest(url: URL(string: url )!)
        request.httpMethod = "POST"
        let contentType = "multipart/form-data; boundary=\(XYboundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.addValue("text/html,application/json,text/json", forHTTPHeaderField: "Accept")
        //创建上传的
        let backgroundTask = backgroundSession.uploadTask(with: request, fromFile:  URL(fileURLWithPath: filePath))
        
        // 开始下载
        backgroundTask.resume()
        
    }
    
    
    
    //MARK: - 后台上传Delegate
    
    //MARK: - 进度监控
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        let currentProgress = (totalBytesSent * 100) / totalBytesExpectedToSend
        
        let currentProgressValue = Float(Double(currentProgress) *  Double((currentUploadIndex+1)) / (100.0 * Double(uploadFilePathArr.count)))
        if currentProgressValue - progressValue >= 0.05{
            
            progressValue = currentProgressValue
            
            DispatchQueue.main.async { [weak self] in
                
                for index in 0..<self!.targetVC.serviceModelArr.count {
                    if self?.targetVC.serviceModelArr[index].uuid == self?.uuid {
                        self?.targetVC.serviceModelArr[index].uploadProgress = currentProgressValue
                    }
                }
                
                self?.targetVC.backgroundServiceTableView.reloadData()
            }
            
        }
        
        print("\(currentProgress)%")
    }
    
    
    //MARK: - 后台上传完执行代理方法
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if((appDelegate.handler) != nil) {
            // 执行上传完成delegate
            let  handelerComp  = appDelegate.handler
            appDelegate.handler = nil
            handelerComp!()
            
        }
        
    }
    
    
    
    
    //MARK: 接收返回的数据
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        if self.responseData == nil {
            let resposeData = NSMutableData(data: data)
            self.responseData = resposeData
        }else{
            self.responseData.append(data)
        }
        
    }
    
    
    //MARK: - 上传结束操作，不管是否成功都会调用
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        //上传结束后其他操作
        if error != nil{
            print("上传error--->\(error!)")
            DispatchQueue.main.async { [weak self] in
                if self != nil{
                    for index in 0..<self!.targetVC.serviceModelArr.count {
                        if self?.targetVC.serviceModelArr[index].uuid == self?.uuid {
                            
                            self?.targetVC.serviceModelArr[index].uploadProgress = 0.0
                            self?.targetVC.serviceModelArr[index].uploadStatus = "0"
                            self?.targetVC.backgroundServiceTableView.reloadData()
                            print("文件上传失败")
                        }
                    }
                }
            }
        }else{
            if let resultData = responseData as Data?{
                
                
                uploadResultJson = JSON(data: resultData)
                print("上传单个成功--->\(uploadResultJson!)")
                //保存上传后得到的地址
                if currentUploadIndex == 0{
                    uploadFileModel.voiceFileUrl = XYUploadResultModel.praseUploadResult(jsonData:uploadResultJson)
                }else if currentUploadIndex == 1{
                    uploadFileModel.scriptFileUrl = XYUploadResultModel.praseUploadResult(jsonData:uploadResultJson)
                }
                //清空之前后台返回的数据
                self.responseData = nil
                //让index+1,以执行下一次上传
                currentUploadIndex += 1
                
                //如果所有文件上传完成后更新UI，进行下一步操作
                if currentUploadIndex == uploadFilePathArr.count {
                    print("文件上传完毕")
                    //当所有文件上传完毕后更新UI
                    for index in 0..<self.targetVC.serviceModelArr.count {
                        if self.targetVC.serviceModelArr[index].uuid == uuid {
                            DispatchQueue.main.async {
                                self.targetVC.serviceModelArr[index].uploadStatus = "1"
                                self.targetVC.serviceModelArr[index].uploadProgress = 0.0
                                self.targetVC.backgroundServiceTableView.reloadData()
                            }
                            
                        }
                        
                    }
                    //此处可将所有文件地址返回给后台
                    
                    //所有文件上传完毕后，释放创建的会话（在结束task后）
                    backgroundSession.finishTasksAndInvalidate()
                    
                }else if currentUploadIndex < uploadFilePathArr.count {
                    //上传下一个文件
                    self.uploadFile(filePath: uploadFilePathArr[currentUploadIndex])
                }
                
                
            }
            
        }
    }
    
    
    
    
    
    
    //MARK: - 创建文件夹路径
    class func  creatFileManagerArr() -> String?{
        let filePathManager = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/XYscreencap")
        
        if let screencapFileManager = filePathManager{
            if !FileManager.default.fileExists(atPath: screencapFileManager) {
                try? FileManager.default.createDirectory(atPath: screencapFileManager, withIntermediateDirectories: true, attributes: nil)
            }
            return screencapFileManager
        }
        
        return nil
        
    }
    
    
    //MARK: - 根据路径获取文件,文件存在返回true
    func  fileIsExists(filePath:String) -> Bool{
        return FileManager.default.fileExists(atPath: filePath)
    }
    
    //MARK: - 上传成功后，删除原文件
    class func  deleteUploadSourceFile(filePathArr:[String]){
        
        for filePath in filePathArr {
            
            try? FileManager.default.removeItem(atPath: filePath)
            
        }
        
        
    }
    
    
    
    
    //MARK: - 创建测试数据
    class func createTestFile(){
        
        if XYBackgroundService.creatFileManagerArr() == nil {
            print("文件路径不存在")
        }
        
        let  screencapFileManager =  XYBackgroundService.creatFileManagerArr()!
        
        let data = UIImagePNGRepresentation(#imageLiteral(resourceName: "test.JPG"))
        
        let filePath3 = screencapFileManager.appending("/XYtest3.jpg")
        let filePath1 = screencapFileManager.appending("/XYtest1.jpg")
        let filePath2 = screencapFileManager.appending("/XYtest2.jpg")
        let filePath4 = screencapFileManager.appending("/XYtest4.jpg")
        
        let json1FilePath = screencapFileManager.appending("/XYtest1.json")
        let json2FilePath = screencapFileManager.appending("/XYtest2.json")
        let json3FilePath = screencapFileManager.appending("/XYtest3.json")
        let json4FilePath = screencapFileManager.appending("/XYtest4.json")
        
        
        let JsonStr = "{code : 000001,data : {count : 0},msg :000000 }"
        let JsonStr2 = "{code : 000002,data : {count : 0},msg :000000 }"
        let jsonData = JsonStr.data(using: .utf8)
        let jsonData2 = JsonStr2.data(using: .utf8)
        
        
        try? data?.write(to: URL(fileURLWithPath: filePath1))
        try? data?.write(to: URL(fileURLWithPath: filePath2))
        try? data?.write(to: URL(fileURLWithPath: filePath3))
        try? data?.write(to: URL(fileURLWithPath: filePath4))
        
        try? jsonData?.write(to: URL(fileURLWithPath: json1FilePath))
        try? jsonData2?.write(to: URL(fileURLWithPath: json2FilePath))
        try? jsonData2?.write(to: URL(fileURLWithPath: json3FilePath))
        try? jsonData2?.write(to: URL(fileURLWithPath: json4FilePath))
        
    }
    
    
    
    //MARK: - 创建带请求头的文件流
    func creatNewfile() -> String{
        
        let fileManager = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first?.appending("/XYscreencap")
        
        let imageFilePath = fileManager! + "/XYtest.png"
        let newImagePath = fileManager! + "/xiaoyiTest.png"
        
        let fileData = NSMutableData()
        fileData.append((XYboundary.data(using: .utf8))!)
        fileData.append(XYNewLine!)
        
        //name:file 服务器规定的参数
        //filename: 文件保存到服务器上面的名称
        //Content-Type:文件的类型
        fileData.append("Content-Disposition: form-data; name=file; filename=xiaoyi.png".data(using: .utf8)!)
        fileData.append(XYNewLine!)
        fileData.append("Content-Type: image/png".data(using: .utf8)!)
        fileData.append(XYNewLine!)
        fileData.append(XYNewLine!)
        
        let imageData = try? Data.init(contentsOf: URL(fileURLWithPath: imageFilePath))
        
        fileData.append(imageData!)
        fileData.append(XYNewLine!)
        fileData.append(("--\(XYboundary)--".data(using: .utf8))!)
        fileData.write(toFile: newImagePath, atomically: false)
        print(newImagePath)
        
        return newImagePath
    }
    
    
    
    
    deinit {
        print("XYBackgroundService---->deinit")
    }
    
}
