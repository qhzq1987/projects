//
//  AccountViewController.swift
//  Thermometer
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

class AccountViewController: UIHfhTableViewController {
    
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
    }
    
    override func resizeViewController(with size: CGSize) -> Void {
        
        //RECT
        var rect = self.tableView.frame
        rect.size = size
        self.tableView.frame = rect
        //子视图RECT值
        let tempArray = self.tableView.visibleCells
        for cell in tempArray {
            (cell as! UIHfhSNmeValCell).startResize = size
        }
    }
    
    // MARK: - Custom Methods
    
    private func initViews() -> Void {
        
        //加载显示内容
        if let pathString = Bundle.main.path(forResource: "AccountViewController", ofType: "plist") {
            //加载
            let tempArray = NSArray(contentsOfFile: pathString) as! Array<Array<Dictionary<String, AnyObject>>>
            dataArray = tempArray
            //默认值
            super.value2Data(NSHfhVar.userInfo)
        }
        //RECT值
        let rect = CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: NSHfhVar.scHeight)
        //创建tableView
        super.showTableView(with: rect)
    }
    
    private func rightItem() -> UIBarButtonItem {
        
        let hVal: CGFloat = 44.0
        //背景
        let bgView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth / 4.0, height: hVal))
        //文本
        let tempLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: bgView.frame.size))
        tempLabel.textAlignment = .right
        tempLabel.textColor = UIColor.white
        tempLabel.font = UIFont.systemFont(ofSize: 14.0)
        tempLabel.text = "更新"
        //添加
        bgView.addSubview(tempLabel)
        //添加事件
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightBarItemRecognizer(_:))))
        //返回
        return UIBarButtonItem(customView: bgView)
    }
    
    @objc private func rightBarItemRecognizer(_ sender: UITapGestureRecognizer) -> Void {
        
        print("提交")
    }
    
    // MARK: - TableView DataSource Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //重用CELL
        let sNmeValCellIndentifer = "SNmeValTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: sNmeValCellIndentifer)
        //返回结果
        let newCell: UIHfhSNmeValCell!
        //是否为空？
        if cell != nil {
            newCell = cell as! UIHfhSNmeValCell
        }
        else {
            //创建
            newCell = UIHfhSNmeValCell(style: .default, reuseIdentifier: sNmeValCellIndentifer)
            //创建视图
            newCell.loadViewInSize(CGSize(width: NSHfhVar.scWidth, height: self.hCell))
            newCell.selectionStyle = .none
        }
        //显示数据
        newCell.showData(self.dataArray[indexPath.section][indexPath.row], with: indexPath)
        //返回
        return newCell
    }
}
