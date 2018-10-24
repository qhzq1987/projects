//
//  DashboardViewController.swift
//  Thermometer
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

class DashboardViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //子viewController对象
        self.viewControllers = viewControllers()
        //不透明
        //self.tabBar.isTranslucent = false
        //bar的背景颜色
        self.tabBar.barTintColor = UIColor.white
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func originImage(with name: String) -> UIImage {
        
        //是否为空？
        guard let img = UIImage(named: name) else {
            return UIImage()
        }
        //返回
        return img.withRenderingMode(.alwaysOriginal)
    }
    
    private func viewControllers() -> Array<UIViewController> {
        
        //属性
        let (nameArray, imgArray) = (["首页", "历史", "我的"], ["db_home", "db_history", "db_my"])
        let higtlightedDict = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 9.0),
                               NSAttributedStringKey.foregroundColor: NSHfhFunc.colorHex(intVal: NSHfhVar.themeColor)]
        let normalDict = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 9.0),
                          NSAttributedStringKey.foregroundColor: UIColor.gray]
        let vcArray = [HomeViewController(), HistoryViewController(), MyViewController()]
        //结果
        var resultArray = Array<UIViewController>()
        for (index, viewController) in vcArray.enumerated() {
            //创建nav对象
            let naviController = UINavigationController(rootViewController: viewController)
            //图标和名称
            naviController.tabBarItem = UITabBarItem(title: nameArray[index],
                                                     image: originImage(with: "\(imgArray[index])_normal"),
                                                     selectedImage: originImage(with: "\(imgArray[index])_highlighted"))
            //调整标题
            naviController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -2.0)
            //保存
            resultArray.append(naviController)
            //添加样式
            naviController.tabBarItem.setTitleTextAttributes(normalDict, for: .normal)
            naviController.tabBarItem.setTitleTextAttributes(higtlightedDict, for: .selected)
        }
        //返回
        return resultArray
    }
}
