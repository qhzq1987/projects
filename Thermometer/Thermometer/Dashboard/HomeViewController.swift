//
//  HomeViewController.swift
//  Thermometer
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIHfhBaseViewController, NSHfhPeripheralsDelegate {
    
    //温度列表
    private var tempraturesArray = Array<CGFloat>(), lastCount: Int = 0
    //状态文本
    private var stateLabel: UILabel!
    //实时温度
    private var rateView: HomeRateView!
    //最近几分钟趋势图
    private var trendView: HomeTrendView!
    //报警音乐
    private var audioPlayer: AVAudioPlayer!
    
    //定时刷新数据
    private var requestTimer: DispatchSourceTimer!, stateTimer: DispatchSourceTimer!
    //是否正在请求？
    private var isRequesting: Bool = false
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.navigationItem.title = "首页"
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //自定义navBar样式
        super.navigationStyle(transparent: false)
        //创建视图
        initViews()
        //不锁屏
        UIApplication.shared.isIdleTimerDisabled = true
        
        //注：以下仅做测试时使用
        /*timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(etstTime(_:)), userInfo: nil, repeats: true)
        timer.fire()
        */
    }

    @objc func etstTime(_ tim: Timer) {

        let tempVal = arc4random() % UInt32(NSHfhVar.MAX_TEMP_VALUE) + 1
        print("模拟温度值 = \(tempVal)")
        NotificationCenter.default.post(name: NSHfhPeripherals.shared.NOTI_VALUE_CHANGED, object: tempVal)
        //启动定时器
        requestTimer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //委托
        NSHfhPeripherals.shared.delegate = self
        //是否为空？
        if nil != rateView {
            rateView.resetData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //委托
        NSHfhPeripherals.shared.delegate = nil
    }
    
    override func resizeViewController(with size: CGSize) -> Void {
        
        //RECT
        var rect1 = self.scrollView.frame, rect2 = rateView.frame, rect3 = trendView.frame
        rect1.size = size
        //底部高度
        let hBar = (self.tabBarController?.tabBar.frame.size.height)!
        //横竖屏
        if size.width > size.height {
            rect2.size.height = size.height - 2.0 * rect2.origin.x - hBar
            rect2.size.width = 0.5 * (size.width - 3.0 * rect2.origin.y)
            rect3.size = rect2.size
            rect3.origin.y = rect2.origin.y
            rect3.origin.x = rect2.size.width + 2.0 * rect2.origin.x
        }
        else {
            //竖屏
            rect2.size.width = size.width - 2.0 * rect2.origin.x
            rect2.size.height = 0.5 * (size.height - 3.0 * rect2.origin.y - hBar)
            rect3.size = rect2.size
            rect3.origin.y = rect2.maxY + rect2.origin.y
            rect3.origin.x = rect2.origin.x
        }
        self.scrollView.frame = rect1
        rateView.frame = rect2
        trendView.frame = rect3
        //子视图
        rateView.startResize = rect2.size
        trendView.startResize = rect3.size
        //修改contentSize值
        self.scrollView.contentSize = CGSize(width: size.width, height: size.height - hBar + 0.5)
    }
    
    // MARK: - Custom Methods
    
    private func initViews() -> Void {
        
        //tabBar的高度
        let hTabBar: CGFloat = (self.tabBarController?.tabBar.frame.size.height)!
        //减去高度
        let hMinus: CGFloat = NSHfhVar.hStatusBar + NSHfhVar.hNaviBar
        //RECT值
        let rect = CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: NSHfhVar.scHeight - hMinus - hTabBar)
        //创建tableView
        super.showScroll(with: rect)
        self.scrollView.contentSize = CGSize(width: rect.size.width, height: rect.size.height + 0.5)
        //边距参考
        let lrVal: CGFloat = 10.0
        //RECT值
        var rect1: CGRect, rect2: CGRect
        //横屏
        if NSHfhVar.scWidth > NSHfhVar.scHeight {
            rect1 = CGRect(x: lrVal, y: lrVal, width: 0.5 * (NSHfhVar.scWidth - 3.0 * lrVal),
                           height: NSHfhVar.scHeight - 2.0 * lrVal - hTabBar - hMinus)
            rect2 = CGRect(x: rect1.size.width + 2.0 * lrVal, y: rect1.origin.y, width: rect1.size.width,
                           height: rect1.size.height)
        }
        else {
            rect1 = CGRect(x: lrVal, y: lrVal,
                           width: NSHfhVar.scWidth - 2.0 * lrVal, height: 0.5 * (rect.size.height - 3.0 * lrVal))
            rect2 = CGRect(x: lrVal, y: rect1.maxY + lrVal,
                           width: rect1.size.width, height: rect1.size.height)
        }
        //报警占比
        rateView = HomeRateView(frame: rect1); rateView.loadCustomView("当前实时温度")
        //本月趋势图
        trendView = HomeTrendView(frame: rect2); trendView.loadCustomView("实时温度曲线图")
        //添加
        self.scrollView.addSubview(trendView)
        self.scrollView.addSubview(rateView)
        //右上角按钮
        self.navigationItem.rightBarButtonItem = rightItem()
        /*//是否登录？
        if "1" != NSHfhVar.userInfo["logined"] as? String {
            return showLoginNoti(self)
        }
        //已登录成功
        loginSuccess()
        */
        //基本信息
        showPatientNoti(self)
        //背景颜色为黑色
        self.view.backgroundColor = UIColor.black
    }
    
    private func rightItem() -> UIBarButtonItem {
        
        let hVal: CGFloat = 44.0, imgWH = 0.45 * hVal
        //文本宽度
        let wLabel: CGFloat = 74.0
        //背景
        let bgView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth / 4.0, height: hVal))
        //消息tag图标
        let imageView = UIImageView(frame: CGRect(x: bgView.frame.size.width - imgWH, y: 0.5 * (bgView.frame.size.height - imgWH),
                                                  width: imgWH, height: imgWH))
        imageView.image = UIImage(named: "db_home_right_bar_item")
        //文本
        stateLabel = UILabel(frame: CGRect(x: imageView.frame.origin.x - wLabel - 5.0, y: 0.0, width: wLabel, height: hVal))
        stateLabel.textColor = UIColor.white
        stateLabel.text = "搜索设备"
        stateLabel.font = UIFont.systemFont(ofSize: 15.0)
        stateLabel.textAlignment = .right
        //添加
        bgView.addSubview(imageView)
        bgView.addSubview(stateLabel)
        //添加事件
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightBarItemRecognizer(_:))))
        //返回
        return UIBarButtonItem(customView: bgView)
    }
    
    private func loginSuccess() -> Void {
        
        //消息
        let center = NotificationCenter.default
        let obj = NSHfhPeripherals.shared
        //登录消息
        center.addObserver(self, selector: #selector(showPatientNoti(_:)), name: NSHfhVar.notiLogin, object: nil)
        center.addObserver(self, selector: #selector(tValueChangeNoti(_:)), name: obj.NOTI_VALUE_CHANGED, object: nil)
    }
    
    private func isLogined() -> Bool {
        
        //登录标志
        let tempVal = NSHfhVar.userInfo["logined"] as? String
        //返回
        return "1" == tempVal
    }
    
    @objc private func rightBarItemRecognizer(_ sender: UITapGestureRecognizer) -> Void {
        
        //是否连接成功？
        if stateLabel.text == "连接成功" {
            return
        }
        //设备列表
        let viewController = DevicesViewController()
        viewController.objStr = "设备列表"
        //回调
        viewController.returnSuccess = { [unowned self] (type: NSHfhPeripheralsReturnType) -> Void in
            self.peripherals(type, message: "")
        }
        //下一步时隐藏底部tabBar
        viewController.hidesBottomBarWhenPushed = true
        //显示
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc private func showPatientNoti(_ noti: Any) -> Void {
        
        //删除消息
        let center = NotificationCenter.default
        let obj = NSHfhPeripherals.shared
        center.removeObserver(self, name: NSHfhVar.notiLogin, object: nil)
        center.removeObserver(self, name: obj.NOTI_VALUE_CHANGED, object: nil)
        //重置状态
        obj.reset()
        //重置
        peripherals(.reset, message: "")
        //销毁定时器
        requestTimer(destory: true)
        stateTimer(destory: true)
        //基本信息
        let viewController = PatientViewController()
        let naviController = UINavigationController(rootViewController: viewController)
        //登录成功回调
        viewController.loginSuccess = { [unowned self] () -> Void in
            //保存
            if true != NSHfhFunc.saveData(NSHfhVar.userInfo, file: NSHfhVar.fileName2LoginUser) {
                print("userInfo保存失败")
            }
            //登录成功
            self.loginSuccess()
        }
        //显示
        self.navigationController?.present(naviController, animated: false, completion: {
            
        })
    }
    
    @objc private func tValueChangeNoti(_ noti: Notification) -> Void {
        
        //是否为空？
        guard let tempVal = noti.object as? CGFloat else {
            return
        }
        //写入列表
        tempraturesArray.append(tempVal)
        //更新温度
        rateView.temperature = tempVal
        //更新曲线数据
        trendView.updateData = tempVal
    }
    
    private func requestHandler() -> Void {
        
        let tempCount = tempraturesArray.count
        //列表是否大于0？
        if tempCount > 0 && tempCount > lastCount {
            //数据库
            let path = NSHfhFunc.documentPath(with: "thermometer.db")
            let db = FMDatabase(path: path)
            //打开是否成功？
            if true != db.open() {
                return print("db open fail.")
            }
            //插入
            let sql = "insert into 't_temperature'(temperature, createTime, tdate, department, zoneSerial, pName) "
                + "values(?, ?, ?, ?, ?, ?)"
            let result = db.executeUpdate(sql, withArgumentsIn:
                [
                    tempraturesArray.last!, NSHfhFunc.stringDate(Date(), with: "yyyy-MM-dd HH:mm:ss"),
                    NSHfhFunc.stringDate(Date(), with: "yyyy-MM-dd"),
                    NSHfhVar.userInfo["department"] as? String ?? "",
                    NSHfhVar.userInfo["zoneSerial"] as? String ?? "", NSHfhVar.userInfo["pName"] as? String ?? ""
                ])
            if true != result {
                print("insert fail. error = \(db.lastError().localizedDescription)")
            }
            //关闭数据库
            db.close()
        }
        //最后和记录数
        lastCount = tempCount
        //清除设备上的数据
        NSHfhPeripherals.shared.clearData()
    }
    
    private func stateHandler() -> Void {
        
        //是否有数据？
        let tempVal = NSHfhPeripherals.shared.isDataResponse
        if true != tempVal {
            //重置
            DispatchQueue.main.async {
                self.peripherals(.reset, message: "")
            }
            //销毁定时器
            stateTimer(destory: true)
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
        //间隔时长
        let timeInterval = 60
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
    
    private func stateTimer(destory: Bool = false) -> Void {
        
        //是否为释放资源？
        if true == destory {
            //释放资源
            if nil != stateTimer {
                stateTimer.cancel()
                stateTimer = nil
            }
            return
        }
        //是否已经创建？
        if nil != stateTimer {
            return
        }
        //间隔时长
        let timeInterval = 3
        //定时器
        stateTimer = DispatchSource.makeTimerSource()
        stateTimer.schedule(deadline: .now()/* + .seconds(timeInterval)*/, repeating: .seconds(timeInterval))
        stateTimer.setEventHandler {
            //刷新数据
            self.stateHandler()
        }
        //开始
        stateTimer.resume()
    }
    
    private func download() -> Void {
        
        DispatchQueue(label: "head_image_download").async {
            //URL地址
            guard let url = URL(string: NSHfhVar.userInfo["imgUrl"] as? String ?? "") else {
                return
            }
            //是否获取成功？
            guard let imgData = try? Data(contentsOf: url) else {
                return
            }
            //头像名称
            let tempVal = "\(NSHfhVar.userInfo["id"]!)" + NSHfhVar.hdImg2LoginUser
            //保存到本地
            NSHfhFunc.saveData2Document(imgData, with: tempVal)
        }
    }
    
    // MARK: - NSHfhPeripherals Delegate
    
    func peripherals(_ type: NSHfhPeripheralsReturnType, message: String) -> Void {
        
        //返回类型
        switch type {
        case .notify:
            //更改状态
            stateLabel.text = "连接成功"
            //启动定时器
            requestTimer()
            stateTimer()
        case .connecting:
            //更改状态
            stateLabel.text = "正在连接"
        case .noServies:
            fallthrough
        case .error:
            fallthrough
        case .reset:
            //更改状态
            stateLabel.text = "搜索设备"
            //断开连接
            NSHfhPeripherals.shared.disconnect()
            //重置
            rateView.resetLayer()
            trendView.resetLayer()
        default:
            break
        }
    }
}

// MARK: -

fileprivate class HomeContentView: UIView {
    
    //标题高度
    fileprivate let TITLE_HEIGHT_VALUE: CGFloat = 54.0
    //标题
    fileprivate var titleLabel: UILabel!
    //分隔线
    fileprivate var lineView: UIView!
    //背景
    fileprivate var bgLayer = CALayer()
    //缺省提示
    fileprivate var zeroView: UIHfhZeroView!
    
    open var showZero: Bool {
        //显示缺省
        set {
            if nil != zeroView {
                zeroView.isHidden = !newValue
            }
        }
        get {
            if nil != zeroView {
                return !zeroView.isHidden
            }
            return false
        }
    }
    
    open func loadCustomView(_ title: String) -> Void {
        
        //当前size值
        let size = self.frame.size
        //边距参考
        let lrVal: CGFloat = 15.0
        //标题
        titleLabel = UILabel(frame: CGRect(x: lrVal, y: 0.0, width: size.width - 2.0 * lrVal, height: TITLE_HEIGHT_VALUE))
        titleLabel.font = UIFont.systemFont(ofSize: 16.0)
        titleLabel.attributedText = NSHfhFunc.attributeImage("db_temp_title_tag", with: title,
                                                                 whImg: 0.5 * TITLE_HEIGHT_VALUE, imgyOffset: -8.0)
        titleLabel.textColor = UIColor.white
        //分隔线
        lineView = UIView(frame: CGRect(x: 0.0, y: titleLabel.frame.maxY,
                                        width: frame.size.width, height: NSHfhVar.whSeparator))
        lineView.backgroundColor = NSHfhFunc.colorHex(intVal: NSHfhVar.eeColor)
        //提示
        zeroView = UIHfhZeroView(frame: CGRect(x: 0.0, y: titleLabel.frame.maxY,
                                               width: size.width, height: size.height - titleLabel.frame.maxY))
        zeroView.loadCustomView("zero_fly", text: "未连接设备，请先连接设备") { (zeroView: UIHfhZeroView) in
            print("can refresh")
        }
        zeroView.ratio = 0.4
        //添加
        self.addSubview(titleLabel)
        self.addSubview(lineView)
        self.addSubview(zeroView)
        //阴影
        //self.shadowCorner()
        //背景颜色
        //self.backgroundColor = UIColor.white
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 4.0
        self.layer.borderColor = UIColor.white.cgColor
    }
    
    open func clear() -> Void {
        
        //是否有列表？
        guard let tempLayers = bgLayer.sublayers else {
            return
        }
        for layer in tempLayers {
            layer.removeFromSuperlayer()
        }
    }
}

// MARK: -

fileprivate class HomeRateView: HomeContentView {
    
    //背景及进度
    private var bgShapeLayer: CAShapeLayer!, prgShapeLayer: CAShapeLayer!
    //上下左右的值
    private let insets = UIEdgeInsets(top: 10.0, left: 15.0, bottom: 20.0, right: 15.0)
    //线条宽度
    private let lineWidth: CGFloat = 10.0
    //中心点
    private var centerPt: CGPoint!
    //半径
    private var radiusVal: CGFloat = 0.0
    //当前温度
    private var valueLabel: UILabel!
    //阈值
    private var low: CGFloat = 0.0, high: CGFloat = 0.0
    //当前最小大温度
    private var min: CGFloat = 0.0, max: CGFloat = 0.0
    //比例值
    private var ratio: CGFloat = 0.0
    //报警音乐播放
    private var audioPlayer: AVAudioPlayer!
    
    open var temperature: CGFloat {
        //当前温度值
        set {
            //温度不能小于最小，也不能大于最大
            let currTemperature = resetTemperature(newValue)
            //温度值
            let tempVal = attrText(String(format: "%0.1f°C", currTemperature.v), color: currTemperature.c)
            valueLabel.attributedText = tempVal.v
            //进度条
            updateProgress(currTemperature.vf * ratio, color: tempVal.c)
            //显示
            bgShapeLayer.isHidden = false
            zeroView.isHidden = true
            valueLabel.isHidden = false
        }
        get {
            return 0.0
        }
    }
    
    open var startResize: CGSize {
        //修改RECT值
        set {
            //RECT值
            var rect1 = bgLayer.frame, rect2 = lineView.frame
            rect1.size = CGSize(width: newValue.width - insets.left - insets.right,
                                height: newValue.height - TITLE_HEIGHT_VALUE - insets.top - insets.bottom)
            rect2.size.width = newValue.width
            bgLayer.frame = rect1
            lineView.frame = rect2
            //缺省
            zeroView.startResize = newValue
            //中心点及半径
            resetPt(rect1.size)
            //值
            let whLabel: CGFloat = 2.0 * (radiusVal - lineWidth)
            var rect3 = valueLabel.frame
            rect3.origin.x = 0.5 * (self.frame.size.width - whLabel)
            rect3.origin.y = rect1.origin.y + 0.5 * (rect1.size.height - whLabel)
            rect3.size.width = whLabel
            rect3.size.height = whLabel
            valueLabel.frame = rect3
            //背景层
            resetbgShaperLayer()
        }
        get {
            return self.frame.size
        }
    }

    override func loadCustomView(_ title: String) -> Void {
        super.loadCustomView(title)
        
        //当前size值
        let size = self.frame.size
        //高度
        let hTotal = size.height - TITLE_HEIGHT_VALUE
        //修改layer的RECT值
        bgLayer.frame = CGRect(x: insets.left, y: TITLE_HEIGHT_VALUE + insets.top + 0.06 * hTotal,
                               width: size.width - insets.left - insets.right, height: hTotal - insets.top - insets.bottom)
        //中心点及半径
        resetPt(bgLayer.frame.size)
        //背景层
        resetbgShaperLayer()
        //添加
        self.layer.addSublayer(bgLayer)
        //label视图
        labelViews(in: size)
    }
    
    open func resetData() -> Void {
        
        //本地设置
        let usrDefault = UserDefaults.standard
        //是否为空？
        guard let tempData = usrDefault.dictionary(forKey: NSHfhVar.SETTING_VALUES_KEY) else {
            return
        }
        //当前最小大温度，注：这里最小温度还是按0.0进行计算
        //min = tempData[NSHfhVar.MIN_TMPT_KEY] as? CGFloat ?? 0.0
        max = tempData[NSHfhVar.MAX_TMPT_KEY] as? CGFloat ?? 0.0
        //阈值
        high = tempData[NSHfhVar.HIGH_TMPT_KEY] as? CGFloat ?? 0.0
        low = tempData[NSHfhVar.LOW_TMPT_KEY] as? CGFloat ?? 0.0
        //比例
        ratio = 1.0 / (abs(min) + abs(max))
    }
    
    open func resetLayer() -> Void {
        
        //显示
        zeroView.isHidden = false
        valueLabel.isHidden = true
        resetbgShaperLayer()
    }

    private func resetPt(_ size: CGSize) -> Void {
        
        //中心点
        centerPt = CGPoint(x: 0.5 * size.width, y: 0.5 * size.height)
        //半径（以最小的值取半径）
        var minVal = size.width
        if size.height < minVal { minVal = size.height
        }
        radiusVal = 0.45 * minVal
    }
    
    private func resetbgShaperLayer() -> Void {
        
        //是否为空？
        if nil != prgShapeLayer {
            prgShapeLayer.removeFromSuperlayer()
            prgShapeLayer = nil
        }
        //先删除层
        if nil != bgShapeLayer {
            bgShapeLayer.removeFromSuperlayer()
            bgShapeLayer = nil
        }
        //4分之pi值
        let pi4Val: CGFloat = CGFloat.pi / 4.0
        bgShapeLayer = shapeLayer(UIColor.lightGray, start: 3.0 * pi4Val, end: pi4Val)
        bgShapeLayer.isHidden = true
        //添加
        bgLayer.addSublayer(bgShapeLayer)
    }
    
    private func resetTemperature(_ value: CGFloat) -> (v: CGFloat, vf: CGFloat, c: Int) {
        
        var tempVal = value
        //温度不能小于最小，也不能大于最大
        if value < min {
            tempVal = min
        }
        else if value > max {
            tempVal = max
        }
        //当前颜色
        var tempColor = NSHfhVar.themeColor
        //如果超过最大值，则红色显示；如果小于最小值，则用绿色表示，正常用系统主色
        if tempVal >= high {
            tempColor = 0xFF0000
            alarmMusic("alarm_high")
        }
        else if tempVal < low {
            tempColor = 0x00FF00
            alarmMusic("alarm_low")
        }
        //注：如果温度小于0，则在进行ABS计算时会将值处理小，如：-15为最小值，-5为当前测得值，但如果按-5显示肯定是错了！
        //则正常显示应该是：-5-(-15)，即显示值为10时，才与效果相同
        var vfVal = tempVal
        //是否小于0？
        if tempVal < 0.0 {
            vfVal = tempVal - min
        }
        //返回
        return (tempVal, vfVal, tempColor)
    }
    
    private func alarmMusic(_ file: String) -> Void {
        
        //获取要播放音频文件的URL
        guard let fileURL = Bundle.main.url(forResource: file, withExtension: ".mp3") else {
            return
        }
        guard let tempAudioPlayer = try? AVAudioPlayer(contentsOf: fileURL) else {
            return
        }
        audioPlayer = tempAudioPlayer
        audioPlayer.volume = 1.0
        audioPlayer.numberOfLoops = 0
        //开始播放
        audioPlayer.play()
    }
    
    private func updateProgress(_ value: CGFloat/*必须在0~1之间*/, color: UIColor) -> Void {
        
        //是否为空？
        if nil != prgShapeLayer {
            prgShapeLayer.removeFromSuperlayer()
            prgShapeLayer = nil
        }
        //4分之pi值
        let pi4Val: CGFloat = CGFloat.pi / 4.0
        let startVal = 3.0 * pi4Val
        //进度
        prgShapeLayer = shapeLayer(color, start: startVal, end: startVal + value * (3.0 * CGFloat.pi / 2.0))
        //先删除之前动画
        let tempKey = "progressAnimation"
        prgShapeLayer.removeAnimation(forKey: tempKey)
        //创建Animation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.5
        animation.isAdditive = true
        //设置layer的animation
        prgShapeLayer.add(animation, forKey: tempKey)
        //添加
        bgLayer.addSublayer(prgShapeLayer)
    }

    private func shapeLayer(_ strokeColor: UIColor, start: CGFloat, end: CGFloat) -> CAShapeLayer {
        
        let layer = CAShapeLayer()
        //背景路径
        let bgBezierPath = UIBezierPath(arcCenter: centerPt, radius: radiusVal - lineWidth, startAngle: start,
                                        endAngle: end, clockwise: true)
        layer.path = bgBezierPath.cgPath
        layer.fillColor = nil
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = lineWidth
        layer.lineCap = kCALineCapRound
        //返回
        return layer
    }

    private func labelViews(in size: CGSize) -> Void {
        
        //值大小
        let whLabel: CGFloat = 2.0 * (radiusVal - lineWidth)
        //RECT值
        let rect = CGRect(x: 0.5 * (size.width - whLabel), y: bgLayer.frame.origin.y, width: whLabel, height: bgLayer.frame.size.height)
        //当前温度
        valueLabel = UILabel(frame: rect)
        valueLabel.numberOfLines = 0
        valueLabel.textAlignment = .center
        //添加
        self.addSubview(valueLabel)
    }
    
    private func attrText(_ text: String, color: Int) -> (v: NSAttributedString, c: UIColor) {
        
        //间距
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        paragraphStyle.alignment = .center
        //温度颜色
        let tempColor = NSHfhFunc.colorHex(intVal: color)
        //值
        let tempVal = NSMutableAttributedString(string: text, attributes:
            [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 26.0),
             NSAttributedStringKey.foregroundColor: tempColor, NSAttributedStringKey.paragraphStyle: paragraphStyle
            ])
        tempVal.append(NSAttributedString(string: "\r\n当前温度", attributes:
            [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0),
             NSAttributedStringKey.foregroundColor: NSHfhFunc.colorHex(intVal: NSHfhVar.txt99Color)
            ]))
        //返回
        return (tempVal, tempColor)
    }
}

// MARK: -

fileprivate class HomeTrendView: HomeContentView {

    //上下左右的值
    private let insets = UIEdgeInsets(top: 30.0, left: 54.0, bottom: 34.0, right: 15.0)
    //图表
    private var tView: TradeView!
    //y、x轴
    private var yAxisArray = Array<UILabel>(), xAxisArray = Array<UILabel>()
    private var yAxisView: UIView!, xAxisView: UIView!
    //网格
    private var gridView: UIView!
    private var vGridsArray = Array<UIView>(), hGridsArray = Array<UIView>()
    
    open var updateData: CGFloat {
        //更新
        set {
            tView.appendData = newValue
            //是否需要刷新？
            if tView.ptsCount > 1 {
                //显示、隐藏
                tView.isHidden = false
                zeroView.isHidden = true
                //坐标轴
                yAxisView.isHidden = false
                for yAxis in yAxisArray { yAxis.isHidden = false
                }
                //刷新
                tView.setNeedsDisplay()
            }
        }
        get {
            return 0.0
        }
    }
    
    open var startResize: CGSize {
        //修改RECT值
        set {
            //RECT值
            var rect1 = tView.frame, rect2 = lineView.frame, rect3 = yAxisView.frame
            rect1.size = CGSize(width: newValue.width - insets.left - insets.right,
                               height: newValue.height - TITLE_HEIGHT_VALUE - insets.top - insets.bottom)
            rect2.size.width = newValue.width
            rect3.size.height = rect1.size.height + 10.0/*参见创建时设定值*/
            tView.frame = rect1
            lineView.frame = rect2
            yAxisView.frame = rect3
            //修改y轴标签
            let hUnit: CGFloat = rect1.size.height / CGFloat(yAxisArray.count - 1)
            let yVal: CGFloat = tView.frame.origin.y - 0.5 * insets.top
            for i in 0 ..< yAxisArray.count {
                let tempLabel = yAxisArray[i]
                var rect = tempLabel.frame
                rect.origin.y = yVal + CGFloat(i) * hUnit
                tempLabel.frame = rect
            }
            //缺省
            zeroView.startResize = self.frame.size
            //网格
            gridViews()
        }
        get {
            return self.frame.size
        }
    }
    
    override func loadCustomView(_ title: String) -> Void {
        super.loadCustomView(title)
        
        //当前size值
        let size = self.frame.size
        //高度
        let hTotal = size.height - TITLE_HEIGHT_VALUE
        //趋势图
        tView = TradeView(frame: CGRect(x: insets.left, y: TITLE_HEIGHT_VALUE + insets.top, width: size.width - insets.left - insets.right,
                                        height: hTotal - insets.top - insets.bottom))
        tView.isHidden = true
        tView.backgroundColor = UIColor.black
        //添加
        self.addSubview(tView)
        //y轴
        yAxisViews(in: size)
        //x轴：一定要在y轴创建后面
        //xAxisViews(in: size)
        //网络，注：一定要在y轴创建后面
        gridViews()
    }
    
    open func resetLayer() -> Void {
        
        //显示、隐藏
        tView.isHidden = true
        zeroView.isHidden = false
        gridView.isHidden = true
        //坐标轴
        yAxisView.isHidden = true
        for yAxis in yAxisArray { yAxis.isHidden = true
        }
        //移除所有点
        tView.clear()
        //刷新
        tView.setNeedsDisplay()
    }
    
    private func xAxisViews(in size: CGSize) -> Void {
        
        //x轴坐标个数
        let xAxisCount = tView.MAX_COUNT / 4
        let wUnit = tView.frame.size.width / CGFloat(xAxisCount)
        let xVal: CGFloat = insets.left, yVal: CGFloat = tView.frame.maxY
        for i in 0 ..< xAxisCount {
            let tempLabel = UILabel(frame: CGRect(x: xVal + CGFloat(i) * wUnit, y: yVal, width: wUnit, height: insets.bottom))
            tempLabel.textColor = UIColor.white
            tempLabel.textAlignment = .center
            tempLabel.font = UIFont.systemFont(ofSize: 12.0)
            tempLabel.text = "00:00"
            //保存、添加
            xAxisArray.append(tempLabel)
            self.addSubview(tempLabel)
        }
        //直线
        xAxisView = UIView(frame: CGRect(x: yAxisView.frame.origin.x, y: yVal + 0.5, width: tView.frame.size.width, height: 1.0))
        xAxisView.backgroundColor = UIColor.white
        //添加
        self.addSubview(xAxisView)
    }
    
    private func yAxisViews(in size: CGSize) -> Void {
        
        //是否有列表？
        if yAxisArray.count > 0 {
            return
        }
        //创建个数
        let yArray = ["0 ", "10 ", "20 ", "30 ", "40 ", "50 "]
        let yAxisCount: Int = yArray.count
        //平均高度
        let hUnit: CGFloat = tView.frame.size.height / CGFloat(yAxisCount - 1)
        let yVal: CGFloat = tView.frame.origin.y - 0.5 * insets.top
        for i in 0 ..< yAxisCount {
            let tempLabel = UILabel(frame: CGRect(x: 0.0, y: yVal + CGFloat(i) * hUnit, width: insets.left - 8.0, height: insets.top))
            tempLabel.textColor = UIColor.white
            tempLabel.textAlignment = .right
            tempLabel.font = UIFont.systemFont(ofSize: 14.0)
            tempLabel.text = yArray[yAxisCount - i - 1]
            tempLabel.isHidden = true
            //保存、添加
            yAxisArray.append(tempLabel)
            self.addSubview(tempLabel)
        }
        //直线
        yAxisView = UIView(frame: CGRect(x: insets.left, y: tView.frame.origin.y - 5.0/*按实际效果调整，下同*/, width: 1.0,
                                         height: tView.frame.size.height + 10.0))
        yAxisView.isHidden = true
        yAxisView.backgroundColor = UIColor.white
        //添加
        self.addSubview(yAxisView)
    }
    
    private func gridViews() -> Void {
        
        //删除所有对象
        for i in hGridsArray {
            i.removeFromSuperview()
        }
        for i in vGridsArray {
            i.removeFromSuperview()
        }
        hGridsArray.removeAll()
        vGridsArray.removeAll()
        //是否为空？
        if nil != gridView {
            gridView.removeFromSuperview()
            gridView = nil
        }
        //线条总数
        let tempCount = tView.MAX_COUNT / 2
        let stepVal = 2.0 * tView.stepVal
        //网格
        gridView = UIView(frame: CGRect(origin: yAxisView.frame.origin,
                                        size: CGSize(width: CGFloat(tempCount) * stepVal + NSHfhVar.whSeparator,
                                                     height: yAxisView.frame.size.height)))
        gridView.isHidden = true
        //竖线大小
        let lSize = CGSize(width: NSHfhVar.whSeparator, height: gridView.frame.height)
        //创建
        for i in 0 ..< tempCount {
            let lineView = UIView(frame: CGRect(origin: CGPoint(x: CGFloat(i + 1) * stepVal, y: 0.0), size: lSize))
            lineView.backgroundColor = UIColor.white
            //保存、添加
            vGridsArray.append(lineView)
            gridView.addSubview(lineView)
        }
        //横线线大小
        let hSize = CGSize(width: gridView.frame.size.width, height: NSHfhVar.whSeparator)
        let hStepVal = 5.0 + 0.5 * yAxisArray.first!.frame.size.height
        for i in 0 ..< yAxisArray.count {
            let lineView = UIView(frame: CGRect(origin:
                CGPoint(x: 0.0, y: yAxisArray[i].frame.origin.y - tView.frame.origin.y + hStepVal), size: hSize))
            lineView.backgroundColor = UIColor.white
            //保存、添加
            hGridsArray.append(lineView)
            gridView.addSubview(lineView)
        }
        //添加
        self.addSubview(gridView)
    }
}

// MARK: -

fileprivate class TradeView: UIView {
    
    //起点y值
    private var yOffset: CGFloat = 0.0, yRatio: CGFloat = 0.0
    //当前最小大温度
    private var min: CGFloat = 0.0, max: CGFloat = 0.0
    //步长
    private(set) var stepVal: CGFloat = 10.0
    //线条绘制颜色
    private let strokeColor = NSHfhFunc.colorHex(intVal: NSHfhVar.themeColor).cgColor
    //最大值
    private(set) var MAX_COUNT: Int = 0
    //数据列表
    private var valuesArray = Array<CGFloat>()
    //点数
    private(set) var ptsCount: Int = 0
    
    override var frame: CGRect {
        //计算几个值
        didSet {
            let size = self.frame.size
            //个数
            MAX_COUNT = Int(size.width / stepVal)
            //起始y值
            yOffset = size.height
            //重置值
            resetData()
        }
    }
    
    open var appendData: CGFloat {
        //添加点
        set {
            valuesArray.append(newValue)
            //是否超过最大值？
            if ptsCount > MAX_COUNT {
                valuesArray.removeFirst()
            }
            //点数
            ptsCount = valuesArray.count
        }
        get {
            return 0.0
        }
    }
    
    open func clear() -> Void {
        
        //移除所有点
        valuesArray.removeAll()
        //点数
        ptsCount = 0
    }
    
    private func resetData() -> Void {
        
        //本地设置
        let usrDefault = UserDefaults.standard
        //是否为空？
        guard let tempData = usrDefault.dictionary(forKey: NSHfhVar.SETTING_VALUES_KEY) else {
            return
        }
        //当前最小大温度，注：这里最小温度还是按0.0进行计算
        //min = tempData[NSHfhVar.MIN_TMPT_KEY] as? CGFloat ?? 0.0
        max = tempData[NSHfhVar.MAX_TMPT_KEY] as? CGFloat ?? 0.0
        //比例
        yRatio = yOffset / (abs(min) + abs(max))
    }
    
    override func draw(_ rect: CGRect) {
        
        //是否为0？
        if ptsCount < 1 {
            return
        }
        //是否成功？
        guard let ctx1 = UIGraphicsGetCurrentContext() else {
            return
        }
        ctx1.setStrokeColor(strokeColor)
        ctx1.setLineCap(.round)
        ctx1.setLineJoin(.round)
        ctx1.setLineWidth(3.0)
        //直线
        let tempPath = lineDraw()
        ctx1.addPath(tempPath)
        ctx1.strokePath()
    }
    
    private func lineDraw() -> CGMutablePath {
        
        //路径
        let paths = CGMutablePath()
        //设置起始点
        paths.move(to: CGPoint.init(x: 0.0, y: yOffset - valuesArray.first! * yRatio))
        //添加路径
        for i in 1 ..< valuesArray.count {
            paths.addLine(to: CGPoint.init(x: CGFloat(i) * stepVal, y: yOffset - valuesArray[i] * yRatio))
        }
        //返回
        return paths
    }
}
