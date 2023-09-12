//
//  A4xDownloadManager.swift
//  A4xDownload
//
//  Created by wei jin on 2023/5/22.
//

import Foundation
import A4xZKDownload

@objcMembers
public class A4xDownloadManager: NSObject {
    
    @objc public static let shared = A4xDownloadManager()
    
    // m3u8 下载
    private var resoucesM3UModels: [(A4xDownloadModel, Int)] = [] //模型和下载子数量
    private var resoucesM3UModelsDic: [String : (A4xDownloadModel, Int)] = [:] //tag组模型和下载子数量
    private var adM3U8DownloadTagDic: [String : Int] = [:] //tag组字典 // 统计tag各个数量
    private var adM3U8DownloadTagArr: [String] = [] // m3u8 根据tag数判断下载数量
    private var adM3U8DownloadDoneCountArr: [(String, Int)] = [] // 总m3u8已经下载量，按照tag分组
    private var adM3U8UnitCount: Int = 0 // m3u8单元

    private var adM3U8Model: A4xDownloadModel?
    private var tsURLHandler: TsURLHandler?
    
    // 声明队列
    private let operationQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = .utility
        return operationQueue
    }()
    
    // 合并
    private var combineCompletion: CombineCompletion?
    private let dispatchQueue = DispatchQueue(label: "m3u8_combine")
    
    private var downloadItemCompleBlock: ((Bool, [A4xDownloadModel]?) -> Void)?
    private var onFinishBlock: ((Bool) -> Void)?
    private var onProgressBlock: ((_ downloadIndex: Int, _ total: Int, _ progress: Float , _ describe: String) -> Void)?
    private var alreadyDownloadModelArr: [A4xDownloadModel]? = []
    
    private var prepareDownloadCount: Int? = 0
    private var alreadyDownloadCount: Int? = 0
    
    private override init() {}
    
    open override func copy() -> Any {
        return self
    }

    open override func mutableCopy() -> Any {
        return self
    }

    // Optional
    func reset() {
        // Reset all properties to default value
    }
    
    public func initConfig() {
        Downloader.shared().configure.sharedContainerIdentifier = "com.app.download"
        Downloader.shared().configure.isAutoCoding = false
        Downloader.shared().configure.isBackgroudExecute = false
        Downloader.shared().configure.maximumExecutionTask = 1
        Downloader.shared().configure.isAllowCellular = true
        Downloader.shared().configure.isAllowInvalidSSLCertificates = true
    }
    
    // 将m3u8链接拆分成子链接
    private func parseM3u(file: URL) throws {
        adM3U8Model = A4xDownloadModel()
        let m3uName: String = file.deletingPathExtension().lastPathComponent
        adM3U8Model?.m3uUrl = file
        
        let uri: URL = file.deletingLastPathComponent()
        adM3U8Model?.m3uUri = uri
        adM3U8Model?.name = m3uName
        
        guard let adUri = adM3U8Model?.m3uUri else { throw WLError.m3uFileContentInvalid }
        let m3uStr = try String(contentsOf: file)
        let arr = m3uStr.components(separatedBy: "\n")
        if let handler = tsURLHandler {
            adM3U8Model?.tsArr = arr.compactMap { handler($0, adUri) }
        } else {
            adM3U8Model?.tsArr = arr
                .filter { $0.range(of: ".ts") != nil }
                .map { $0.range(of: "http") != nil ? URL.init(string: $0)! : adUri.appendingPathComponent($0)}
        }
        if adM3U8Model?.tsArr?.isEmpty ?? true { throw WLError.m3uFileContentInvalid }
        if adM3U8Model?.totalSize == 0 {
            self.adM3U8Model?.totalSize = adM3U8Model?.tsArr?.count ?? 0
        }
    }
    
    // 计算m3u8的单位子任务下载量
    private func m3u8DownloadCount(by arr: [String]) {
        var tmpCount: [String : Int] = [:]
        for item in arr {
            if let x = tmpCount[item] {
                tmpCount[item] = x + 1
                continue
            }
            tmpCount[item] = 1
        }
        adM3U8DownloadTagDic = tmpCount
    }
    
    // 合并任务入口
    private func ts2Conbine(task: Task, completion: CombineCompletion? = nil) -> Self {
        combineCompletion = completion
        operationQueue.addOperation {
            self.doCombine(task: task)
        }
        return self
    }
    
    // 合并操作
    private func doCombine(task: Task) {
        let tagsArr = task.tags.allObjects
        var model: A4xDownloadModel?
        if tagsArr.count > 0 {
            let tag: String = tagsArr[0] as? String ?? "normalTasks"
            model = resoucesM3UModelsDic[tag]?.0
        }
        
        guard let name = model?.name, let tsArr = model?.tsArr else {
            return
        }
        
        let saveUrl = URL.init(string: task.filePath())
        let savePath = saveUrl?.deletingLastPathComponent().absoluteString ?? ""
        
        // 合并路径
        let combineFilePath = URL.init(string: task.manager?.configure.savePath ?? "")?.appendingPathComponent("Camera_\(name)").appendingPathExtension("ts").absoluteString
        FileManager.default.createFile(atPath: combineFilePath ?? "", contents: nil, attributes: nil)
        let tsFilePaths = tsArr.map { savePath + $0.lastPathComponent }
        
        dispatchQueue.async {
            let fileHandle = FileHandle(forUpdatingAtPath: combineFilePath ?? "")
            defer { fileHandle?.closeFile() }
            // 合并ts核心操作
            for tsFilePath in tsFilePaths {
                if FileManager.default.fileExists(atPath: tsFilePath) {
                    let data = try! Data(contentsOf: URL(fileURLWithPath: tsFilePath))
                    fileHandle?.write(data)
                }
            }
            
            do {
                // 删除合并子任务目录及所有ts文件
                try FileManager.default.removeItem(atPath: savePath)
            } catch {
                DispatchQueue.main.async {
                    self.handleCompletion(of: "combine",
                                          completion: self.combineCompletion,
                                          result: .failure(.handleCacheFailed(error)))
                }
            }
            
            DispatchQueue.main.async {
                self.handleCompletion(of: "combine",
                                      completion: self.combineCompletion,
                                      result: .success(URL.init(string: combineFilePath ?? "")!))
            }
        }
    }
    
    // 完成合并回调 - 可封装成通用
    private func handleCompletion<T>(of task: String, completion: ((Result<T>) -> ())?, result: Result<T>) {
        completion?(result)
        switch result {
        case .failure(let error):
            operationQueue.cancelAllOperations()
            print("---------> combine success \(error)")
        case .success(let value):
            operationQueue.isSuspended = false
            print("---------> combine success \(value)")
        }
        
        if operationQueue.operationCount == 0 {
            print("---------> combine done ")
        }
    }
    
    // 获取指定路径下，指定类型的所有文件
    private func getAllFilePath(_ dirPath: String, fileType: String) -> [String]? {
        var filePaths: [String] = []
        do {
            let array = try FileManager.default.contentsOfDirectory(atPath: dirPath)
            for fileName in array {
                var isDir: ObjCBool = true
                let fullPath = "\(dirPath)\(fileName)"
                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
                    if !isDir.boolValue {
                        let fullUrl = URL.init(string: fullPath)
                        let pathExtension = fullUrl?.pathExtension
                        if ((pathExtension?.hasPrefix(fileType)) != nil) {
                            filePaths.append(fullPath)
                        }
                    }
                }
            }
        } catch let error as NSError {
            print("get file path error: \(error)")
        }
        return filePaths
    }
    
    // 重置下载信息
    private func downloadReset() {
        self.prepareDownloadCount = 0
        self.alreadyDownloadCount = 0
        self.alreadyDownloadModelArr?.removeAll()
        self.resoucesM3UModels.removeAll()
        self.resoucesM3UModelsDic.removeAll()
        self.adM3U8DownloadDoneCountArr.removeAll()
        self.adM3U8DownloadTagDic.removeAll()
        self.adM3U8DownloadTagArr.removeAll()
        self.adM3U8UnitCount = 0
    }
    
    /// download source
    /// - Parameter models: sources models
    /// isShare: true, share download
    @objc public func downloadSource(list: [A4xDownloadModel], isShare: Bool = false, onProgress: @escaping (_ downloadIndex: Int, _ total: Int, _ progress: Float , _ describe: String) -> Void, downloadItemComple: @escaping (Bool, [A4xDownloadModel]?) -> Void, onFinish: @escaping (Bool) -> Void) {
        // 重置
        downloadReset()
        
        // 需要下载的视频数
        self.prepareDownloadCount = list.count
        
        downloadAddTask(models: list, isShare: isShare)
        
        self.downloadItemCompleBlock = downloadItemComple
        
        self.onFinishBlock = onFinish
        
        self.onProgressBlock = onProgress
        
        self.addDownloadListener()
        
    }
    
    // add task
    private func downloadAddTask(models: [A4xDownloadModel], isShare: Bool = false) {
        var normalTasks: Array<Dictionary<String, Any>> = Array()
        var m3u8Tasks: Array<Dictionary<String, Any>> = Array()
        var m3u8Dic: [String : (A4xDownloadModel,Int)] = [:]
        for (_, data) in models.enumerated() {
            if data.mediaType == 1 { // m3u
                // ts 拆分数组处理
                do {
                    try parseM3u(file: URL.init(string: data.videoUrl!)!)
                    adM3U8Model?.tsArr?.forEach({ (url) in
                        let mediaType: MediaType = .video
                        let m3uName: String = url.deletingPathExtension().lastPathComponent
                        let info: Dictionary<String, Any> = [FKTaskInfoFileName: m3uName, FKTaskInfoURL: url.absoluteString, FKTaskInfoUserInfo: ["isShare" : isShare, "sourceid" : data.serialNumber!] as [String : Any], FKTaskInfoTags: ["m3u8Tasks_\(adM3U8Model?.name ?? "normal")"], FKTaskInfoDescribe: data.deviceName ?? "unknow" , FKTaskInfoMediaType: mediaType.rawValue]
                        m3u8Tasks.append(info)
                    })
                    
                    m3u8Dic["m3u8Tasks_\(adM3U8Model?.name ?? "normal")"] = (adM3U8Model ?? A4xDownloadModel(), adM3U8Model?.tsArr?.count ?? 0)
                    let repeatArr = resoucesM3UModels.filter { $0.0.name == adM3U8Model?.name}
                    if repeatArr.count == 0 {
                        resoucesM3UModels.append((adM3U8Model ?? A4xDownloadModel(),adM3U8Model?.tsArr?.count ?? 0))
                    }
                } catch {
                    print("------------> m3u8 解析失败")
                }
            } else { // mp4
                let info: Dictionary<String, Any> = [FKTaskInfoURL : data.videoUrl!, FKTaskInfoUserInfo : ["isShare" : isShare, "sourceid" : data.serialNumber!] as [String : Any], FKTaskInfoTags : ["normalTasks"], FKTaskInfoDescribe : data.deviceName ?? "unknow" , FKTaskInfoMediaType : MediaType.video.rawValue]
                normalTasks.append(info)
            }
        }
        
        resoucesM3UModelsDic = m3u8Dic
        Downloader.shared().addTasks(with: m3u8Tasks)
        Downloader.shared().addTasks(with: normalTasks)
        Downloader.shared().startWithAll()
    }
    
    /// add download listener
    ///
    /// - Parameters:
    ///   - onProgress: current download info (_ downloadIndex : Int , _ total: Int , _ progress : Float , _ describe : String)
    ///   - onProgress: @escaping (_ downloadIndex: Int, _ total: Int, _ progress: Float , _ describe: String) -> Void
    private func addDownloadListener() {
        var compleNumber: Int32 = 0
        
        weak var weakSelf = self
        
        Downloader.shared().queueUpdateBlock = {(tasks, total, wait, complete, error) in
            print("task: \(tasks) wait: \(wait) total: \(total) complete: \(complete)\n error: \(error)")
            
            let task = tasks.first
            let name: String? = task?.describe
            
            // 计算整体m3u8任务数量
            let totalValue = weakSelf?.resoucesM3UModels.reduce(0) {
                $0 + $1.1
            }
            
            let tagsArr = tasks.first?.tags.allObjects
            
            if tagsArr?.count ?? 0 > 0 {
                let tag: String = tagsArr?[0] as? String ?? "normalTasks"
                weakSelf?.adM3U8DownloadTagArr.append(tag) // 根据tag数判断下载数量
                
                weakSelf?.m3u8DownloadCount(by: weakSelf?.adM3U8DownloadTagArr ?? []) // 统计tag数量
                
                if tag.hasPrefix("m3u8Tasks") {
                    // 判断具体标签是否下载完毕，下载完毕 +1、合并、存储
                    
                    // 当前tag标签子任务总数
                    let unitSum: Int = weakSelf?.resoucesM3UModelsDic[tag]?.1 ?? 0
                    let saveUrl = URL.init(string: task?.filePath() ?? "unknow")
                    let savePath = saveUrl?.deletingLastPathComponent().absoluteString ?? ""
                    let arr = weakSelf?.getAllFilePath(savePath, fileType: "ts")
                    // 子任务已经下载数
                    let singleDoneCount: Int = (arr?.count ?? 0) + 1
                    
                    // 子任务是否下载完毕
                    let unitAchieve: Int = unitSum - singleDoneCount > 0 ? 0 : 1
                    // 子任务全部下载完毕
                    if unitAchieve == 1 {
                        weakSelf?.adM3U8UnitCount += 1
                    }
                    
                    // 判断tag 子任务已经下载是否存在
                    let repeatArr = weakSelf?.adM3U8DownloadDoneCountArr.filter { $0.0 == tag}
                    if repeatArr?.count == 0 {
                        // 新的 tag
                        weakSelf?.adM3U8DownloadDoneCountArr.append((tag, singleDoneCount - (unitAchieve == 0 ? 1 : 0)))
                    } else {
                        // 已有的 tag 下载数量更新
                        weakSelf?.adM3U8DownloadDoneCountArr.removeAll {
                            $0.0 == tag
                        }
                        weakSelf?.adM3U8DownloadDoneCountArr.append((tag, singleDoneCount - (unitAchieve == 0 ? 1 : 0)))
                    }
                    
                    // 累加所有tag的数量
                    let m3u8DoneCount = weakSelf?.adM3U8DownloadDoneCountArr.reduce(0) {
                        $0 + $1.1
                    }
                    
                    // 展示层回调
                    task?.progressBlock = { progres in
                        // 下载进度计算：（已下载子任务数 + 当前任务进度) / 总单元任务数
                        let subProgress = (Float(singleDoneCount - 1) + Float(progres.progress.fractionCompleted)) / Float(unitSum)
                        // 下载中任务数、下载总任务数、下载进度
                        weakSelf?.onProgressBlock?(Int(complete + 1) - (m3u8DoneCount ?? 0) + (weakSelf?.adM3U8UnitCount ?? 0), Int(total) - (totalValue ?? 0) + (weakSelf?.resoucesM3UModels.count ?? 0), subProgress, name ?? "unknow")
                    }
                    
                } else {
                    // mp4 处理
                    
                    // 累加所有tag的数量//---0
                    let m3u8DoneCount = weakSelf?.adM3U8DownloadDoneCountArr.reduce(0) {
                        $0 + $1.1
                    }
                    
                    // 展示层回调
                    task?.progressBlock = { progres in //---1
                        weakSelf?.onProgressBlock?(Int(complete + 1) - (m3u8DoneCount ?? 0) + (weakSelf?.adM3U8UnitCount ?? 0), Int(total) - (totalValue ?? 0) + (weakSelf?.resoucesM3UModels.count ?? 0), Float(progres.progress.fractionCompleted), name ?? "unknow")
                    }
                }
            } else {
                // old
                task?.progressBlock = { progres in
                    weakSelf?.onProgressBlock?(Int(complete + 1), Int(total), Float(progres.progress.fractionCompleted), name ?? "unknow")
                }
            }
            
            tasks.first?.statusBlock = { task in
                if task.status == .unknowError {
                    // 下载失败了一个链接的处理
                    weakSelf?.downloadItemCompleBlock?(false, nil)
                    //weakSelf?.stopDownload()
                    //taskResult(false)
                    //weakSelf?.taskError(task: task)
                } else if task.status == .finish {
                    let tagsArr = task.tags.allObjects
                    if tagsArr.count > 0 {
                        let tag: String = tagsArr[0] as? String ?? "normalTasks"
                        if tag.hasPrefix("m3u8Tasks") {
                            // m3u8 处理
                            
                            // 判断task子任务是否全下载完成
                            // 是，合成ts、转码、保存到相册
                            
                            // 当前tag标签子任务总数
                            let unitSum: Int = weakSelf?.resoucesM3UModelsDic[tag]?.1 ?? 0
                            let saveUrl = URL.init(string: task.filePath())
                            let savePath = saveUrl?.deletingLastPathComponent().absoluteString ?? ""
                            let arr = weakSelf?.getAllFilePath(savePath, fileType: "ts")
                            // 子任务已经下载数
                            let singleDoneCount: Int = arr?.count ?? 0
                            
                            print("----------------->task m3u8Tasks 总任务数:\(unitSum) 已经完成子任务:\(singleDoneCount)")
                            print("----------------->task m3u8Tasks 还剩子任务:\(unitSum - singleDoneCount)")
                            if unitSum - singleDoneCount == 0 {
                                let strongSelf = weakSelf
                                // 开始合成
                                let _  = strongSelf?.ts2Conbine(task: task) { (result) in
                                    switch result {
                                    case .success(let url):
                                        print("[Combine Success] " + url.path)
                                        let isShare = task.userInfo?["isShare"] as? Bool ?? false
                                        strongSelf?.taskDone(videoPath: url.path, isShare: isShare, mediaType: 1)
                                    case .failure(let error):
                                        print("[Combine Failure] " + error.localizedDescription)
                                    }
                                }
                                compleNumber += 1
                            }
                            // 否，继续等待
                        } else {
                            // mp4 处理
                            compleNumber += 1
                            let serialNumber = task.userInfo?["sourceid"] as? String
                            let isShare = task.userInfo?["isShare"] as? Bool ?? false
                            weakSelf?.taskDone(videoPath: task.filePath(), isShare: isShare, serialNumber: serialNumber ?? "", mediaType: 0)
                        }
                    } else {
                        // old - 普通mp4视频
                        compleNumber += 1
                        let serialNumber = task.userInfo?["sourceid"] as? String
                        let isShare = task.userInfo?["isShare"] as? Bool ?? false
                        weakSelf?.taskDone(videoPath: task.filePath(), isShare: isShare, serialNumber: serialNumber ?? "", mediaType: 0)
                    }
                } else {
                }
            }
        }
        
        Downloader.shared().downloadEndBlock = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
                Downloader.shared().removeWithAll()
                // compleNumber > 0,可能有缓存下载，此时compleNumber == 0
                weakSelf?.onFinishBlock?(true)
            })
        }
    }
    
    
    /// remove download listener
    private func removeDownloadListenter() {
        Downloader.shared().queueUpdateBlock = {(tasks, total, wait, complete, error) in
            print("removeDownloadListentertask: \(tasks) wait: \(wait) total: \(total) complete: \(complete)\n error: \(error)")
        }
        Downloader.shared().downloadEndBlock = {}
    }
    
    /// stop all cancel and end tasks
    public func stopDownload() {
        Downloader.shared().cancelWithAll()
        Downloader.shared().removeWithAll()
    }
    
    public func cancelDownload(urlStr: String?) {
        guard let cancelURL = urlStr else {
            return
        }
        let task = Downloader.shared().acquire(cancelURL)
        task?.cancel()
    }
    
    /// download done
    /// - Parameter videoPath: downlaod path
    /// - Parameter serialNumber: device  serialNumber
    /// - Parameter mediaType: 1,m3u; 0,mp4
    private func taskDone(videoPath: String, isShare: Bool = false, serialNumber: String = "", mediaType: Int = 0) {
        DispatchQueue.global().async {
            if (FileManager.default.fileExists(atPath: videoPath)) {
                let inputUrl = URL.init(fileURLWithPath: videoPath)
                var inputFileName = inputUrl.lastPathComponent
                var fileHeadName = "Camera_"
                if mediaType == 1 { // m3u
                    let newInputUrlURL = inputUrl.deletingPathExtension().appendingPathExtension("mp4")
                    inputFileName = newInputUrlURL.lastPathComponent
                    fileHeadName = ""
                }
                let fileRootPath = self.substring(str: "\(inputUrl.deletingLastPathComponent())", from: 7)
                let outputfilePath = "\(fileRootPath)\(fileHeadName)\(inputFileName)"
                
                // 判断是否最后一个下载完成
                let downloadModel = A4xDownloadModel()
                downloadModel.downloadTaskPath = videoPath
                downloadModel.downloadOutputPath = outputfilePath
                downloadModel.serialNumber = serialNumber
                downloadModel.mediaType = mediaType // 1,m3u; 0,mp4
                downloadModel.isShare = isShare
                self.alreadyDownloadModelArr?.append(downloadModel)
                self.alreadyDownloadCount! += 1
                // 达到下载完成数 - tips: 下载失败了一个链接的处理
                if self.prepareDownloadCount == self.alreadyDownloadCount {
                    self.downloadItemCompleBlock?(true, self.alreadyDownloadModelArr)
                }
            } else {
                self.downloadItemCompleBlock?(false, nil)
            }
        }
    }
    
    private func substring(str: String, from index: Int) -> String {
        guard let start_index = validStartIndex(str: str, original: index)  else {
            return str
        }
        return String(str[start_index..<str.endIndex])
    }
    
    private func validIndex(str: String, original: Int) -> String.Index {
        switch original {
        case ...str.startIndex.encodedOffset : return str.startIndex
        case str.endIndex.encodedOffset...   : return str.endIndex
        default                          : return str.index(str.startIndex, offsetBy: original)
        }
    }
    
    private func validStartIndex(str: String, original: Int) -> String.Index? {
        guard original <= str.endIndex.encodedOffset else { return nil }
        return validIndex(str: str, original: original)
    }
}
