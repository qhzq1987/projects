//
//  UIHfhViewController.swift
//  UIHfhViewController
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2017年 HeFahu. All rights reserved.
//

import UIKit

class UIHfhBaseViewController: UIViewController {
    
    //数据传递，其格式自定义，解析时按封装格式取值即可
    open var objData: Dictionary<String, AnyObject>!
    //单个字符
    open var objStr: String = ""
    //可能会用到滚动区域
    open var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //背景颜色
        self.view.backgroundColor = NSHfhFunc.colorHex(intVal: NSHfhVar.backgroundColor)
        //屏幕大小
        NSHfhVar.scWidth = UIScreen.main.bounds.size.width
        NSHfhVar.scHeight = UIScreen.main.bounds.size.height
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        //屏幕大小
        NSHfhVar.scWidth = size.width
        NSHfhVar.scHeight = size.height
        //是否进入viewDidLoad？
        if true != self.isViewLoaded {
            return
        }
        //调整rect值
        resizeViewController(with: size)
    }
    
    // MARK: - Custom Methods
    
    open func navigationStyle(transparent: Bool = false) -> Void {
        
        //当前navBar对象
        guard let navigationBar = self.navigationController?.navigationBar else {
            return
        }
        //是否需要透明bar图片？
        let img = true == transparent ? imageWithColor() : imageWithColor(NSHfhFunc.colorHex(intVal: NSHfhVar.themeColor))
        //加载图片
        let bgImg = img.resizableImage(withCapInsets: UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0), resizingMode: .stretch)
        //自定义Nav的背景色（用自定义图片来填充）
        navigationBar.setBackgroundImage(bgImg, for: .default)
        //去掉navBar的投影
        navigationBar.shadowImage = UIImage()
        //设置状态栏的样式
        navigationBar.barStyle = .blackOpaque
        //标题字体大小
        let dict = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 19.0)]
        navigationBar.titleTextAttributes = dict
        //隐藏系统自带返回按钮
        self.navigationItem.hidesBackButton = true
    }
    
    open func backItemNavigation(_ title: String = "") -> Void {
        
        //整个背景
        let bgView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 74.0, height: 44.0))
        bgView.backgroundColor = UIColor.clear
        //image高度
        let whImg = 0.5 * bgView.frame.size.height
        //返回按钮
        let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.5 * (bgView.frame.size.height - whImg),
                                                  width: whImg, height: whImg))
        imageView.image = UIImage(named: "navi_bar_back")
        //是否有文本？
        if "" != title {
            let tempLabel = UILabel(frame: CGRect(x: imageView.frame.maxX + 15.0,
                                                  y: 0.0, width: 144.0, height: bgView.frame.size.height))
            tempLabel.text = title
            tempLabel.font = UIFont.systemFont(ofSize: 18.0)
            tempLabel.textColor = UIColor.white
            //添加
            bgView.addSubview(tempLabel)
        }
        //添加返回手势
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer(_:))))
        bgView.addSubview(imageView)
        //设置
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: bgView)
        //隐藏系统自带的返回按钮
        self.navigationItem.hidesBackButton = true
    }
    
    open func showScroll(with frame: CGRect) -> Void {
        
        //创建
        scrollView = UIScrollView(frame: frame)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        //contentSize
        scrollView.contentSize = CGSize(width: frame.size.width, height: frame.size.height + 0.5)
        //添加
        self.view.addSubview(scrollView)
    }
    
    @objc private func tapGestureRecognizer(_ sender: UITapGestureRecognizer) -> Void {
        
        //是否可以返回？
        if true == viewControllWillDisappear() {
            closeViewController()
        }
    }
    
    open func viewControllWillDisappear() -> Bool {
        
        return true
    }
    
    open func closeViewController() -> Void {
        
        //naviController对象
        guard let naviController = self.navigationController else {
            return
        }
        //关闭自己
        if nil == naviController.popViewController(animated: true) {
            //如pop失败，则用dismiss关闭
            naviController.dismiss(animated: true, completion: {
                
            })
        }
    }
    
    open func resizeViewController(with size: CGSize) -> Void {
        
        //重写
    }
    
    // MARK: -
    
    private func imageWithColor(_ color: UIColor = UIColor.clear) -> UIImage {
        
        //图片大小
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 64.0)
        //创建画布
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
        //生成图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //是否为空？
        guard let tempImage = image else {
            return UIImage()
        }
        //返回
        return tempImage
    }
}

// MARK: -
// MARK: - TableView

class UIHfhTableViewController: UIHfhBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    //tableView
    public var tableView: UITableView!
    //tableView展示数据
    public var dataArray = Array<Array<Dictionary<String, AnyObject>>>()
    public var shtArray: Array<String>!
    //row的高度
    public var hCell: CGFloat = 54.0
    //section之间的高度
    private let FOOTER_HEIGHT_VALUE: CGFloat = 0.1, HEADER_HEIGHT_VAULE: CGFloat = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    // MARK: - Custom Methods
    
    open func showTableView(with frame: CGRect) -> Void {
        
        //创建tableView
        tableView = UITableView(frame: frame, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = NSHfhFunc.colorHex(intVal: NSHfhVar.backgroundColor)
        //添加
        self.view.addSubview(tableView)
    }
    
    open func deselectIndexPath(_ indexPath: IndexPath) -> Void {
        
        //取消选中
        self.perform(#selector(deselectRow(_:)), with: indexPath, afterDelay: 0.25)
    }
    
    @objc private func deselectRow(_ indexPath: IndexPath) -> Void {
        
        //取消选中
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: -
    
    open func value2Data(_ values: Dictionary<String, AnyObject>) -> Void {
        
        //起止索引
        let startIndex: Int = 0
        let endIndex: Int = dataArray.count - 1
        //rows信息
        for sectionIndex in startIndex ... endIndex {
            //更新
            dataArray[sectionIndex] = values2Rows(dataArray[sectionIndex], values: values)
        }
    }
    
    open func validate() -> (result: Bool, msg: String) {
        
        //起止索引
        let startIndex: Int = 0
        let endIndex: Int = dataArray.count - 1
        //rows信息
        for index in startIndex ... endIndex {
            //结果
            let tempVal = validate2Rows(dataArray[index])
            //是否成功？
            if false == tempVal.result {
                return tempVal
            }
        }
        //返回
        return (true, "")
    }
    
    open func values2Rows(_ rows: Array<Dictionary<String, AnyObject>>,
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
            if let valueKey = row["valueKey"] as? String {
                //值
                row["value"] = values[valueKey]
                //添加
                tempArray.append(row)
            }
        }
        //返回
        return tempArray
    }
    
    private func validate2Rows(_ rows: Array<Dictionary<String, AnyObject>>) -> (result: Bool, msg: String) {
        
        //起止索引
        let startIndex: Int = 0
        let endIndex: Int = rows.count - 1
        //section下面的row对象
        for rowIndex in startIndex ... endIndex {
            //row
            var row = rows[rowIndex]
            //是否为空的标志？
            if ("1" == (row["notnull"] as? String) ?? "") && ("" == (row["value"] as? String) ?? "") {
                return (false, "\(row["name"]!)不能为空")
            }
        }
        //返回
        return (true, "")
    }
    
    // MARK: - TableView DataSource Delegate
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        return dataArray.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArray[section].count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return hCell
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        //header高度
        return HEADER_HEIGHT_VAULE
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        //创建
        let headerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: HEADER_HEIGHT_VAULE))
        headerView.backgroundColor = UIColor.clear
        //返回
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return FOOTER_HEIGHT_VALUE
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        //创建
        let footerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: FOOTER_HEIGHT_VALUE))
        footerView.backgroundColor = UIColor.clear
        //返回
        return footerView
    }
}
