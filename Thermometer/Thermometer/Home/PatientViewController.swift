//
//  PatientViewController.swift
//  Thermometer
//
//  Created by HeFahu on 2018/5/29.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

class PatientViewController: UIHfhBaseViewController, UIGestureRecognizerDelegate {
    
    //cells视图
    private var cellsView: UIHfhCellsView!
    //科室及病区
    private var departmentData = Array<String>(), zoneData = Array<String>()
    
    //闭包
    typealias ReturnClosure = () -> Void
    //回调
    var loginSuccess: ReturnClosure?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.title = "病人信息"
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //自定义navBar样式
        super.navigationStyle()
        //创建视图
        initViews()
    }
    
    override func resizeViewController(with size: CGSize) -> Void {
        
        //RECT
        var rect = self.scrollView.frame
        rect.size.width = size.width
        self.scrollView.frame = rect
        //子视图RECT值
        cellsView.startResize = size
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //科室
        loadData(&departmentData, file: NSHfhVar.fileName2Department)
        //病区
        loadData(&zoneData, file: NSHfhVar.fileName2Zone)
    }
    
    // MARK: - Custom Methods
    
    private func initViews() -> Void {

        //显示内容
        var dataArray: Array<Array<Dictionary<String, AnyObject>>>!
        //加载显示内容
        if let pathString = Bundle.main.path(forResource: "PatientViewController", ofType: "plist") {
            //加载
            var tempArray = NSArray(contentsOfFile: pathString) as! Array<Array<Dictionary<String, AnyObject>>>
            //起止索引
            let endIndex: Int = tempArray.count - 1
            for sectionIndex in 0 ... endIndex {
                tempArray[sectionIndex] = values2Rows(tempArray[sectionIndex], values: NSHfhVar.userInfo)
            }
            dataArray = tempArray
        }
        //RECT值
        let rect = CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: NSHfhVar.scHeight)
        //创建tableView
        super.showScroll(with: rect)
        //cells视图
        cellsView = UIHfhCellsView(frame: rect)
        cellsView.loadCustomView(dataArray) { [unowned self] (view: UIHfhCellsView, type: UIHfhCellViewType, indexPath: IndexPath?) in
            self.willNext(type, indexPath: indexPath)
        }
        //背景图片
        let img1 = NSHfhFunc.imageWithColor(NSHfhFunc.colorHex(intVal: NSHfhVar.themeColor))
        let img2 = NSHfhFunc.imageWithColor(NSHfhFunc.colorHex(intVal: 0x75ABE5))
        //下一步按钮
        cellsView.nextView(with: "确定", normal: img1, highlighted: img2)
        //添加
        self.scrollView.addSubview(cellsView)
        //添加手势
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboardRecognizer(_:)))
        recognizer.delegate = self
        self.scrollView.addGestureRecognizer(recognizer)
    }
    
    private func willNext(_ type: UIHfhCellViewType, indexPath: IndexPath?) -> Void {
        
        switch type {
        case .next:
            //清除所有值
            NSHfhVar.userInfo.removeAll()
            //关闭键盘
            cellsView.hideKeyboard()
            //当前所有值
            NSHfhVar.userInfo = cellsView.data() as Dictionary<String, AnyObject>
            //科室
            let departmentVal = NSHfhVar.userInfo["department"] as? String ?? ""
            historyData(departmentVal, data: &departmentData, file: NSHfhVar.fileName2Department)
            //病区
            let zoneVal = NSHfhVar.userInfo["zoneSerial"] as? String ?? ""
            historyData(zoneVal, data: &zoneData, file: NSHfhVar.fileName2Zone)
            //关闭自己
            self.closeViewController()
            //回调
            if let tempReturnClosure = self.loginSuccess {
                tempReturnClosure()
            }
        case .shouldEdit:
            //是否为空？
            guard let tempIndexPath = indexPath else {
                return
            }
            //刷新数据
            updateList(to: tempIndexPath)
        default:
            break
        }
    }
    
    private func historyData(_ val: String, data: inout Array<String>, file: String) -> Void {
        
        //是否为空？
        if "" == val {
            return
        }
        //是否存在？
        for i in 0 ..< data.count {
            if data[i] != val {
                continue
            }
            //删除相同值
            data.remove(at: i)
            break
        }
        //添加
        data.insert(val, at: 0)
        //最多显示10条历史记录，是否大于10？
        if data.count > 10 {
            data.removeLast()
        }
        //保存
        if true != NSHfhFunc.saveData(data, file: file) {
            print("historyData保存失败")
        }
    }
    
    private func updateList(to indexPath: IndexPath) -> Void {
        
        switch indexPath.row {
        case 0:
            //科室
            cellsView.reloadData = departmentData
        case 1:
            //病区
            cellsView.reloadData = zoneData
        default:
            break
        }
    }
    
    @objc private func closeKeyboardRecognizer(_ sender: UITapGestureRecognizer) -> Void {
        
        //关闭键盘
        cellsView.hideKeyboard()
    }
    
    private func loadData(_ data: inout Array<String>, file: String) -> Void {
    
        //清空列表
        data.removeAll()
        //是否为空？
        guard let tempData = NSKeyedUnarchiver.unarchiveObject(withFile: NSHfhFunc.documentPath(with: file)) else {
            return
        }
        guard let dataList = tempData as? Array<String> else {
            return
        }
        //保存列表
        for i in dataList {
            data.append(i)
        }
    }
    
    private func values2Rows(_ rows: Array<Dictionary<String, AnyObject>>,
                          values: Dictionary<String, AnyObject>) -> Array<Dictionary<String, AnyObject>> {
        
        //结果
        var tempArray = Array<Dictionary<String, AnyObject>>()
        //起止索引
        let startIndex: Int = 0
        let endIndex: Int = rows.count - 1
        //section下面的row对象
        for rowIndex in startIndex ... endIndex {
            //row
            var row = rows[rowIndex]
            //key是否为空？
            if let valueKey = row["valueKey"] as? String  {
                //值
                row["value"] = values[valueKey]
                //添加
                tempArray.append(row)
            }
        }
        //返回
        return tempArray
    }
    
    // MARK: - UIGestureRecognizer Delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        //如果是tableView，则事件不进行传递
        guard let tempView = touch.view else {
            return true
        }
        //是否点击CELL？
        let tempVal = NSStringFromClass(tempView.classForCoder) != "UITableViewCellContentView"
        //返回
        return tempVal
    }
}
