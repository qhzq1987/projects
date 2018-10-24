//
//  DevicesViewController.swift
//  Thermometer
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesViewController: UIHfhBaseViewController, NSHfhPeripheralsDelegate, UITableViewDelegate, UITableViewDataSource {    

    //tableView
    private var tableView: UITableView!
    //CELL高度
    private var hCell: CGFloat = 64.0
    //加载等待
    private var indicatorView: UIActivityIndicatorView!
    //定时器
    private var requestTimer: DispatchSourceTimer!
    private var timerCount: Int = 0
    //缺省提示
    fileprivate var zeroView: UIHfhZeroView!
    
    //闭包
    typealias ReturnClosure = (_ type: NSHfhPeripheralsReturnType) -> Void
    //回调
    var returnSuccess: ReturnClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //自定义navBar样式
        super.navigationStyle()
        //自定义返回按钮样式
        super.backItemNavigation(self.objStr)
        //创建视图
        initViews()
        //搜索
        if -1 == NSHfhPeripherals.shared.currIndex {
            rightBarItemRecognizer(self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //委托
        NSHfhPeripherals.shared.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //委托
        NSHfhPeripherals.shared.delegate = nil
    }
    
    override func viewControllWillDisappear() -> Bool {
        
        //销毁Timer
        requestTimer(destory: true)
        //取消扫描
        NSHfhPeripherals.shared.delegate = nil
        NSHfhPeripherals.shared.stopScan()
        //是否为空？
        if nil != indicatorView {
            indicatorView.removeFromSuperview()
            indicatorView = nil
        }
        //返回
        return true
    }
    
    override func resizeViewController(with size: CGSize) -> Void {
        
        //RECT
        var rect = self.tableView.frame
        rect.size = size
        self.tableView.frame = rect
        //子视图RECT值
        let tempArray = self.tableView.visibleCells
        for cell in tempArray {
            (cell as! DevicesCell).startResize = size
        }
        //缺省
        zeroView.startResize = size
    }
    
    // MARK: - Custom Methods
    
    private func initViews() -> Void {
        
        //减去高度
        let hMinus: CGFloat = NSHfhVar.hStatusBar + NSHfhVar.hNaviBar
        //大小
        let whIndicator: CGFloat = 44.0
        //tableView
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: NSHfhVar.scHeight - hMinus))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = NSHfhFunc.colorHex(intVal: NSHfhVar.backgroundColor)
        //等待
        indicatorView = UIActivityIndicatorView(frame: CGRect(x: 128.0, y: NSHfhVar.hStatusBar, width: whIndicator,
                                                              height: whIndicator))
        indicatorView.activityIndicatorViewStyle = .white
        //提示
        zeroView = UIHfhZeroView(frame: CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: tableView.frame.size.height))
        zeroView.loadCustomView("zero_fly", text: "正在搜索设备，请稍候...") { (zeroView: UIHfhZeroView) in
            print("can refresh")
        }
        zeroView.ratio = 0.3
        //zeroView.isHidden = true
        //添加
        tableView.addSubview(zeroView)
        self.navigationController?.view.addSubview(indicatorView)
        self.view.addSubview(tableView)
        //右上角按钮
        self.navigationItem.rightBarButtonItem = rightItem()
    }
    
    private func rightItem() -> UIBarButtonItem {
        
        let hVal: CGFloat = 44.0, imgWH = 0.45 * hVal
        //背景
        let bgView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth / 4.0, height: hVal))
        //消息tag图标
        let imageView = UIImageView(frame: CGRect(x: bgView.frame.size.width - imgWH, y: 0.5 * (bgView.frame.size.height - imgWH),
                                                  width: imgWH, height: imgWH))
        imageView.image = UIImage(named: "device_refresh")
        //添加
        bgView.addSubview(imageView)
        //添加事件
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightBarItemRecognizer(_:))))
        //返回
        return UIBarButtonItem(customView: bgView)
    }
    
    private func alterMessage(_ msg: String) -> Void {
        
        //提示
        let alertController = UIAlertController(title: "提示", message: msg, preferredStyle: .alert)
        //确定
        let trueAction = UIAlertAction(title: "确定", style: .destructive, handler: { (UIAlertAction) -> Void in
            
        })
        //添加
        alertController.addAction(trueAction)
        //显示
        self.navigationController?.present(alertController, animated: true, completion: { () -> Void in})
    }
    
    @objc private func rightBarItemRecognizer(_ sender: Any) -> Void {
        
        //是否正在搜索？
        if true != indicatorView.isHidden {
            return
        }
        //提示文本
        zeroView.text = "正在搜索设备，请稍候..."
        //显示
        indicatorView.isHidden = false
        indicatorView.startAnimating()
        //设备中心
        let obj = NSHfhPeripherals.shared
        obj.delegate = self
        //开始搜索
        obj.startManager()
        //重新刷新tableView
        tableView.reloadData()
        //定时器
        requestTimer(destory: true)
        requestTimer()
    }
    
    private func updateCell(_ newCell: DevicesCell, connected: Bool, isConnecting: Bool) -> Void {
        
        //是否已连接？
        if true == connected {
            newCell.connected()
        }
        else if true == isConnecting {
            newCell.connecting()
        }
        else {
            newCell.reset()
        }
    }
    
    private func requestTimer(destory: Bool = false) -> Void {
        
        //是否为释放资源？
        if true == destory {
            //释放资源
            if nil != requestTimer {
                requestTimer.cancel()
                requestTimer = nil
            }
            return
        }
        //是否已经创建？
        if nil != requestTimer {
            return
        }
        //计数置0
        timerCount = 0
        //间隔时长
        let timeInterval = 1
        //定时器
        requestTimer = DispatchSource.makeTimerSource()
        requestTimer.schedule(deadline: .now()/* + .seconds(timeInterval)*/, repeating: .seconds(timeInterval))
        requestTimer.setEventHandler {
            //刷新数据
            self.requestHandler()
        }
        //开始
        requestTimer.resume()
    }
    
    private func requestHandler() -> Void {
        
        timerCount = timerCount + 1
        //是否超过30秒？
        if timerCount > 30 {
            //取消扫描
            NSHfhPeripherals.shared.stopScan()
            requestTimer(destory: true)
            //主线程中更新
            DispatchQueue.main.async {
                //列表是否大于0？
                let tempVal = NSHfhPeripherals.shared.peripherals.count > 0
                if true != tempVal {
                    self.zeroView.text = "没有蓝牙探头，请打开探头后重新搜索"
                }
                self.zeroView.isHidden = tempVal
                self.indicatorView.isHidden = true
            }
        }
    }
    
    // MARK: - NSHfhPeripherals Delegate
    
    func peripheralsStateError(_ message: String) -> Void {
        
        //扫描状态
        indicatorView.isHidden = true
        //消息是否为空？
        if "" != message {
            alterMessage(message)
        }
    }
    
    func peripherals(_ type: NSHfhPeripheralsReturnType, message: String) -> Void {
        
        //回调是否为空？
        if let tempReturnClosure = self.returnSuccess {
            tempReturnClosure(type)
        }
        //返回类型
        switch type {
        case .noServies:
            fallthrough
        case .error:
            //刷新tableView
            self.tableView.reloadData()
            //消息是否为空？
            if "" != message {
                alterMessage(message)
            }
        case .reloadData:
            //主线程中更新
            DispatchQueue.main.async {
                self.zeroView.isHidden = NSHfhPeripherals.shared.peripherals.count > 0
            }
            //刷新tableView
            tableView.reloadData()
        case .notify:
            //扫描状态
            if nil != indicatorView {
                indicatorView.removeFromSuperview()
                indicatorView = nil
            }
            //关闭自己
            self.closeViewController()
        default:
            break
        }
    }
    
    // MARK: - TableView DataSource Delegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return NSHfhPeripherals.shared.peripherals.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return hCell
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //重用CELL
        let sDevicesCellIndentifer = "SDevicesTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: sDevicesCellIndentifer)
        //返回结果
        let newCell: DevicesCell!
        //是否为空？
        if cell != nil {
            newCell = cell as! DevicesCell
        }
        else {
            //创建
            newCell = DevicesCell(style: .default, reuseIdentifier: sDevicesCellIndentifer)
            newCell.loadViewInSize(CGSize(width: NSHfhVar.scWidth, height: self.hCell))
        }
        //当前设备
        let tempObj = NSHfhPeripherals.shared.peripherals[indexPath.row]
        //标题
        newCell.title = tempObj.peripheral.name
        newCell.subTitle = "信号强度：\(tempObj.rssiVal)dBm"
        //更新状态
        updateCell(newCell, connected: tempObj.isConnected, isConnecting: tempObj.isConnecting)
        //返回
        return newCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //连接，返回值：1-连接，0-未进行连接（有可能正在连接，所以不进行再次连接）
        if true != NSHfhPeripherals.shared.willConnectObj(indexPath.row) {
            return
        }
        //停止定时器
        requestTimer(destory: true)
        //扫描状态
        indicatorView.isHidden = true
        //修改状态
        let tempCell = tableView.cellForRow(at: indexPath) as! DevicesCell
        tempCell.connecting()
        //回调是否为空？
        if let tempReturnClosure = self.returnSuccess {
            tempReturnClosure(.connecting)
        }
    }
}

// MARK: -

fileprivate class DevicesCell: UIHfhSquareCell {
    
    //名称、地址
    private var titleLabel: UILabel!, subTitleLabel: UILabel!
    //连接状态
    private var connectedLabel: UILabel!
    //等待
    private var connView: UIActivityIndicatorView!
    
    open var title: String? {
        //标题
        set {
            if nil != titleLabel {
                titleLabel.text = newValue
            }
        }
        get {
            return nil != titleLabel ? titleLabel.text : ""
        }
    }
    
    open var subTitle: String? {
        //副标题
        set {
            if nil != subTitleLabel {
                subTitleLabel.text = newValue
            }
        }
        get {
            return nil != subTitleLabel ? subTitleLabel.text : ""
        }
    }
    
    open var startResize: CGSize {
        //修改RECT值
        set {
            self.selfSize.width = newValue.width
            //RECT值
            var rect1 = connView.frame, rect2 = connectedLabel.frame
            rect1.origin.x = newValue.width - rect1.height
            rect2.size.width = newValue.width - 2.0 * rect2.origin.x
            connView.frame = rect1
            connectedLabel.frame = rect2
            //分隔线
            self.widthToSeparator = newValue.width
        }
        get {
            return self.selfSize
        }
    }
    
    override func viewDidLoad() -> Void {
        
        //label高度
        let hLabel: CGFloat = 20.0
        //边距参考
        let lrVal: CGFloat = 15.0
        //名称
        titleLabel = label(with: CGRect(x: lrVal, y: 0.5 * (self.selfSize.height - 2.0 * hLabel),
                                        width: self.selfSize.width - 2.0 * lrVal, height: hLabel), font: 16.0)
        //副标题
        subTitleLabel = label(with: CGRect(x: lrVal, y: titleLabel.frame.maxY, width: titleLabel.frame.size.width,
                                          height: hLabel),
                             font: 12.0, textColor: NSHfhVar.txt99Color)
        //等待
        connView = UIActivityIndicatorView(frame: CGRect(x: self.selfSize.width - self.selfSize.height, y: 0.0,
                                                         width: self.selfSize.height, height: self.selfSize.height))
        connView.activityIndicatorViewStyle = .gray
        connView.isHidden = true
        //连接状态
        connectedLabel = label(with: CGRect(x: lrVal, y: 0.0, width: titleLabel.frame.size.width, height: self.selfSize.height),
                               font: 18.0, textAlignment: .right, textColor: NSHfhVar.txt99Color)
        connectedLabel.text = "已连接"
        connectedLabel.isHidden = true
        //添加
        self.contentView.addSubview(connView)
        //选择样式
        self.selectionStyle = .none
    }
    
    open func reset() -> Void {
        
        //隐藏
        connectedLabel.isHidden = true
        connView.isHidden = true
    }
    
    open func connecting() -> Void {
        
        //显示
        connView.isHidden = false
        connView.startAnimating()
    }
    
    open func connected() -> Void {
        
        //已连接？
        connectedLabel.isHidden = false
        connView.isHidden = true
    }
    
    private func label(with frame: CGRect, font: CGFloat, textAlignment: NSTextAlignment = .left, textColor: Int = 0) -> UILabel {
        
        //创建
        let tempLabel = UILabel(frame: frame)
        tempLabel.font = UIFont.systemFont(ofSize: font)
        tempLabel.textColor = NSHfhFunc.colorHex(intVal: textColor)
        tempLabel.clipsToBounds = true
        tempLabel.textAlignment = textAlignment
        //添加
        self.contentView.addSubview(tempLabel)
        //返回
        return tempLabel
    }
}
