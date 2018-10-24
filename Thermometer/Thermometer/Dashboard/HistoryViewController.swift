//
//  HistoryViewController.swift
//  Thermometer
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

class HistoryViewController: UIHfhTableViewController {
    
    //日期
    private var dateView: HistoryDateView!
    //缺省提示
    private var zeroView: UIHfhZeroView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.navigationItem.title = "历史"
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //自定义navBar样式
        super.navigationStyle(transparent: false)
        //创建视图
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //更新日期
        let tempArray = dateView.update()
        //删除
        deleteRs(with: tempArray)
        //查询当前日期
        queryRs(with: dateView.date())
    }
    
    override func resizeViewController(with size: CGSize) -> Void {
        
        //RECT
        var rect = self.tableView.frame
        rect.size = size
        self.tableView.frame = rect
        //子视图RECT值
        let tempArray = self.tableView.visibleCells
        for cell in tempArray {
            (cell as! HistoryCell).startResize = size
        }
        //日期
        dateView.startResize = size
        //缺省
        zeroView.startResize = size
    }

    // MARK: - Custom Methods
    
    private func initViews() -> Void {
        
        //为了防止自调整
        let tempView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: NSHfhVar.whSeparator))
        //显示最近几个月的数据
        let tempVal = 7//daysCount(in: 1)
        //日期
        dateView = HistoryDateView(frame: CGRect(x: -NSHfhVar.whSeparator, y: 0.0,
                                                 width: NSHfhVar.scWidth + 2.0 * NSHfhVar.whSeparator, height: 54.0))
        dateView.loadCustomView(days: tempVal) { (historyDateView: HistoryDateView, date: Date) in
            //刷新数据
            self.queryRs(with: NSHfhFunc.stringDate(date, with: "yyyy-MM-dd"))
        }
        dateView.isBorder = true
        //添加
        self.view.addSubview(tempView)
        self.view.addSubview(dateView)
        //减去高度
        let hMinus: CGFloat = NSHfhVar.hStatusBar + NSHfhVar.hNaviBar + (self.tabBarController?.tabBar.frame.size.height)!
        //RECT值
        let rect = CGRect(x: 0.0, y: dateView.frame.maxY,
                          width: NSHfhVar.scWidth, height: NSHfhVar.scHeight - dateView.frame.size.height - hMinus)
        //创建tableView
        super.showTableView(with: rect)
        //提示
        zeroView = UIHfhZeroView(frame: CGRect(x: 0.0, y: 0.0, width: rect.size.width, height: rect.size.height))
        zeroView.loadCustomView("zero_unspecified", text: "暂无历史温度记录") { (zeroView: UIHfhZeroView) in
            print("can refresh")
        }
        zeroView.ratio = 0.5
        zeroView.isHidden = true
        //添加
        self.tableView.addSubview(zeroView)
    }

    private func daysCount(in month: Int) -> Int {
        
        //参考日期
        let refDate = Date()
        //日历对象
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        var comps = calendar.components([.year, .month, .day], from: refDate)
        comps.year = comps.year! - month / 12
        var tempMonth = comps.month! - month % 12
        if tempMonth < 1 {
            tempMonth = 13 + tempMonth
        }
        comps.month = tempMonth
        //计算天数
        let components = calendar.components([.day], from: calendar.date(from: comps)!,
                                             to: refDate, options: NSCalendar.Options.wrapComponents)
        //返回
        return abs(1 + components.day!)
    }
    
    private func deleteRs(with dates: Array<String>) -> Void {
        
        //数据库
        let path = NSHfhFunc.documentPath(with: "thermometer.db")
        let db = FMDatabase(path: path)
        //打开是否成功？
        if true != db.open() {
            return print("db open fail.")
        }
        //删除
        let sql = "delete from 't_temperature' where 'tdate' < \(dates.first!)"
        let result = db.executeStatements(sql)
        if true != result {
            print("delete fail. error = \(db.lastError().localizedDescription)")
        }
        //关闭数据库
        db.close()
    }
    
    private func queryRs(with date: String) -> Void {
        
        //数据库
        let path = NSHfhFunc.documentPath(with: "thermometer.db")
        let db = FMDatabase(path: path)
        //打开是否成功？
        if true != db.open() {
            return print("db open fail.")
        }
        //先删除所有的
        self.dataArray.removeAll()
        //查询
        let result = db.executeQuery("select * from 't_temperature' where tdate = ?", withArgumentsIn: [date])
        var tempArray = Array<Dictionary<String, AnyObject>>()
        while false != result?.next() {
            let tempData = ["temperature": result?.double(forColumn: "temperature") as Any,
                            "createTime": result?.string(forColumn: "createTime") as Any,
                            "department": result?.string(forColumn: "department") as Any,
                            "zoneSerial": result?.string(forColumn: "zoneSerial") as Any,
                            "pName": result?.string(forColumn: "pName") as Any ] as Dictionary<String, AnyObject>
            tempArray.append(tempData)
        }
        //关闭数据库
        db.close()
        //添加
        self.dataArray.append(tempArray)
        //刷新tableView
        self.tableView.reloadData()
        //缺省
        zeroView.isHidden = tempArray.count > 0
    }
    
    // MARK: - TableView DataSource Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //重用CELL
        let sHistoryCellIndentifer = "SHistoryTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: sHistoryCellIndentifer)
        //返回结果
        let newCell: HistoryCell!
        //是否为空？
        if cell != nil {
            newCell = cell as! HistoryCell
            newCell.startResize = CGSize(width: NSHfhVar.scWidth, height: self.hCell)
        }
        else {
            //创建
            newCell = HistoryCell(style: .default, reuseIdentifier: sHistoryCellIndentifer)
            newCell.loadViewInSize(CGSize(width: NSHfhVar.scWidth, height: self.hCell))
        }
        //显示数据
        newCell.showData(self.dataArray[indexPath.section][indexPath.row], with: indexPath)
        //返回
        return newCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.1
    }
}

// MARK: -

fileprivate class HistoryCell: UIHfhSquareCell {
    
    //labelsArray对象，依次为：序号、温度、时间、科室、病区、姓名
    private var labelsArray = Array<UILabel>()
    //分隔线
    private var linesArray = Array<UIView>()
    
    private var ratio: Array<CGFloat> {
        
        //比例值
        let tempArray: Array<CGFloat> = [0.07, 0.13, 0.2, 0.23, 0.2, 0.17]
        //返回
        return tempArray
    }
    
    open var startResize: CGSize {
        //修改RECT值
        set {
            self.selfSize.width = newValue.width
            //参考边距
            let lrVal: CGFloat = 15.0
            //宽度值
            let ratioWidth = self.selfSize.width - 2.0 * lrVal
            //x值
            var xVal: CGFloat = lrVal
            //比例值
            let ratioArray: Array<CGFloat> = self.ratio
            for i in 0 ..< ratioArray.count {
                let tempWidth = ratioArray[i] * ratioWidth
                //RECT值
                var rect1 = labelsArray[i].frame, rect2 = linesArray[i].frame
                rect1.origin.x = xVal
                rect1.size.width = tempWidth
                rect2.origin.x = xVal
                //修改
                labelsArray[i].frame = rect1
                linesArray[i].frame = rect2
                //累加
                xVal += tempWidth
            }
            //分隔线
            self.widthToSeparator = newValue.width
        }
        get {
            return self.selfSize
        }
    }
    
    override func viewDidLoad() -> Void {
        
        //参考边距
        let lrVal: CGFloat = 15.0
        //宽度值
        let ratioWidth = self.selfSize.width - 2.0 * lrVal
        //x值
        var xVal: CGFloat = lrVal
        //比例值
        let ratioArray: Array<CGFloat> = self.ratio
        for i in 0 ..< ratioArray.count {
            let tempWidth = ratioArray[i] * ratioWidth
            let tempLabel = label(with: CGRect(x: xVal, y: 0.0, width: tempWidth, height: self.selfSize.height), line: i > 0)
            //累加
            xVal += tempWidth
            //保存
            labelsArray.append(tempLabel)
        }
    }
    
    override func showData(_ data: Dictionary<String, AnyObject>, with indexPath: IndexPath) -> Void {
        
        //依次为：序号、温度、时间、科室、病区、姓名
        //序号
        labelsArray.first!.text = "\(indexPath.row + 1)"
        //温度
        labelsArray[1].text = String(format: "%0.1f°C", data["temperature"] as? CGFloat ?? 0.0)
        labelsArray[2].text = data["createTime"] as? String ?? "-"
        labelsArray[3].text = data["department"] as? String ?? "-"
        labelsArray[4].text = data["zoneSerial"] as? String ?? "-"
        labelsArray[5].text = data["pName"] as? String ?? "-"
        
    }

    private func label(with frame: CGRect, font: CGFloat = 14.0,
                       textAlignment: NSTextAlignment = .center, textColor: Int = NSHfhVar.txt99Color, line: Bool) -> UILabel {
        
        //创建
        let tempLabel = UILabel(frame: frame)
        tempLabel.font = UIFont.systemFont(ofSize: font)
        tempLabel.textColor = NSHfhFunc.colorHex(intVal: textColor)
        tempLabel.textAlignment = textAlignment
        //分隔线高度
        let hLine: CGFloat = 0.4 * self.selfSize.height
        //分隔线
        let lineView = UIView(frame: CGRect(x: tempLabel.frame.origin.x, y: 0.5 * (frame.size.height - hLine),
                                            width: NSHfhVar.whSeparator, height: hLine))
        lineView.backgroundColor = NSHfhFunc.colorHex(intVal: NSHfhVar.eeColor)
        lineView.isHidden = !line
        //保存
        linesArray.append(lineView)
        //添加
        self.contentView.addSubview(tempLabel)
        self.contentView.addSubview(lineView)
        //返回
        return tempLabel
    }
}

// MARK: -

fileprivate class HistoryDateView: UIView {
    
    //scrollView对象
    private var scrollView: UIScrollView!
    //指引
    private var thumbView: UIView!
    //labels对象
    private var daysArray = Array<UILabel>()
    //当前选中索引
    private var currIndex: Int = -1
    //日期
    open var datesArray = Array<Date>()
    
    //闭包
    typealias ReturnClosure = (_ dateView: HistoryDateView, _ date: Date) -> Void
    //回调
    private var returnClosure: ReturnClosure?
    
    open var isBorder: Bool {
        //是否添加边框？
        set {
            if true != newValue {
                return
            }
            //添加边框
            self.layer.borderWidth = NSHfhVar.whSeparator
            self.layer.borderColor = NSHfhFunc.colorHex(intVal: NSHfhVar.eeColor).cgColor
        }
        get {
            return self.layer.borderWidth > 0.0
        }
    }
    
    open var startResize: CGSize {
        //修改RECT值
        set {
            //RECT值
            var rect1 = self.frame, rect2 = scrollView.frame
            rect1.size.width = newValue.width
            rect2.size.width = newValue.width
            self.frame = rect1
            scrollView.frame = rect2
        }
        get {
            return self.frame.size
        }
    }
    
    open var firstDate: Date {
        //第一个日期
        return datesArray.count > 0 ? datesArray[0] : Date()
    }
    
    open func loadCustomView(days: Int, with closure: @escaping ReturnClosure) -> Void {
        
        //当前size值
        let size = self.frame.size
        //参数值
        let wPer: CGFloat = widthUnit(in: size, days: days)
        //scrollView
        scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: CGFloat(days) * wPer, height: size.height)
        //天数
        daysView(in: size, days: days, unit: wPer)
        //指引高宽度
        let hThumb: CGFloat = 2.0, wThumb: CGFloat = 0.8 * wPer
        //指引
        thumbView = UIView(frame: CGRect(x: CGFloat(days - 1) * wPer + 0.5 * (wPer - wThumb), y: size.height - hThumb,
                                         width: wThumb, height: hThumb))
        thumbView.backgroundColor = NSHfhFunc.colorHex(intVal: NSHfhVar.themeColor)
        //保存
        returnClosure = closure
        //添加
        scrollView.addSubview(thumbView)
        self.addSubview(scrollView)
        //背景颜色
        self.backgroundColor = UIColor.white
        //选中最后一天，即今天
        scrollView.scrollRectToVisible(daysArray.last!.frame, animated: false)
        selecteChanged(daysArray.count - 1)
    }
    
    open func update() -> Array<String> {
        
        //数量
        let tempCount = daysArray.count
        //列表是否为空？
        if tempCount < 1 {
            return []
        }
        //返回结果
        var resultArray = Array<String>()
        //星期
        let time24Interval = -24.0 * 60.0 * 60.0
        let objCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        let refDate = Date()
        //清空日期
        datesArray.removeAll()
        //创建
        for i in 0 ..< tempCount {
            //计算日期
            let tempDate = refDate.addingTimeInterval(TimeInterval(tempCount - i - 1) * time24Interval)
            let components = objCalendar.components([.year, .month, .day, .weekday], from: tempDate)
            //天
            daysArray[i].text = "\(components.month!)月\(components.day!)日"
            //保存
            datesArray.append(tempDate)
            resultArray.append(String(format: "%0.4d-%0.2d-%0.2d", components.year!, components.month!, components.day!))
        }
        //返回
        return resultArray
    }
    
    open func date(with fromatter: String = "yyyy-MM-dd") -> String {
        
        //返回日期
        return NSHfhFunc.stringDate(datesArray[currIndex], with: fromatter)
    }
    
    private func selecteChanged(_ index: Int) -> Void {
        
        //是否已有选中？
        if currIndex > -1 {
            let dayLabel = daysArray[currIndex]
            dayLabel.textColor = NSHfhFunc.colorHex(intVal: NSHfhVar.txt99Color)
        }
        //选中
        let dayLabel = daysArray[index]
        dayLabel.textColor = thumbView.backgroundColor
        //移动
        var rect = thumbView.frame
        rect.origin.x = dayLabel.frame.origin.x + 0.5 * (dayLabel.frame.size.width - rect.size.width)
        UIView.animate(withDuration: 0.35) {
            self.thumbView.frame = rect
        }
        //保存索引
        currIndex = index
    }
    
    private func widthUnit(in size: CGSize, days: Int) -> CGFloat {
        
        //最小值
        let minVal: CGFloat = 74.0
        var tempCount: CGFloat = 5.0 /*最小为5个，最大值暂时不限*/
        var resultVal: CGFloat = minVal
        while true {
            let wPer: CGFloat = size.width / tempCount
            if wPer <= minVal {
                break
            }
            resultVal = wPer
            tempCount += 1.0
        }
        //天数是小于计算后的数（如：一页显示5个，但日期只显示3个，则必须按3来平分宽度）
        if CGFloat(days) < tempCount {
            resultVal = size.width / CGFloat(days)
        }
        //返回
        return resultVal
    }
    
    private func daysView(in size: CGSize, days: Int, unit width: CGFloat) -> Void {
        
        /*//星期
        let time24Interval = -24.0 * 60.0 * 60.0
        let objCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        let refDate = Date()*/
        //创建
        for i in 0 ..< days {
            let dayLabel = label(with: CGRect(x: CGFloat(i) * width, y: 0.0, width: width, height: size.height),
                                 font: 14.0, tag: i)
            /*//计算日期
            let tempDate = refDate.addingTimeInterval(TimeInterval(days - i - 1) * time24Interval)
            let components = objCalendar.components([.year, .month, .day, .weekday], from: tempDate)
            //天
            dayLabel.text = "\(components.month!)月\(components.day!)日"
            //保存
            datesArray.append(tempDate)*/
            daysArray.append(dayLabel)
            //添加手势
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(selectedRecognizer(_:)))
            dayLabel.addGestureRecognizer(recognizer)
        }
    }
    
    @objc private func selectedRecognizer(_ sender: UITapGestureRecognizer) -> Void {
        
        //是否为空？
        guard let tempLabel = sender.view as? UILabel else {
            return
        }
        //修改选中状态
        selecteChanged(tempLabel.tag)
        //回调是否为空？
        if let tempReturnClosure = returnClosure {
            tempReturnClosure(self, datesArray[currIndex])
        }
    }
    
    private func label(with frame: CGRect, font: CGFloat, tag: Int) -> UILabel {
        
        let tempLabel = UILabel(frame: frame)
        tempLabel.textColor = NSHfhFunc.colorHex(intVal: NSHfhVar.txt66Color)
        tempLabel.clipsToBounds = true
        tempLabel.font = UIFont.systemFont(ofSize: font)
        tempLabel.textAlignment = .center
        tempLabel.isUserInteractionEnabled = true
        tempLabel.tag = tag
        //添加
        scrollView.addSubview(tempLabel)
        //返回
        return tempLabel
    }
}
