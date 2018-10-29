//
//  AppDelegate.swift
//  Thermometer
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        //读取用户信息
        if let tempData = NSKeyedUnarchiver.unarchiveObject(withFile: NSHfhFunc.documentPath(with: NSHfhVar.fileName2LoginUser)) {
            if let userInfo = tempData as? Dictionary<String, AnyObject> {
                NSHfhVar.userInfo = userInfo
            }
        }
        //数据库
        database()
        //最大最小值
        mmValues()
        //返回
        return true
    }
    
    private func database() -> Void {
        
        //数据库
        let path = NSHfhFunc.documentPath(with: "thermometer.db")
        let db = FMDatabase(path: path)
        //打开是否成功？
        if true != db.open() {
            return print("db open fail.")
        }
        //创建表
        let sql = "create table if not exists t_temperature ('temperature' float, 'createTime' varchar(20) NOT NULL"
            + ", 'tdate' varchar(20) NOT NULL"
            + ", 'department' varchar(50), 'zoneSerial' varchar(20), 'pName' varchar(20))"
        let result = db.executeStatements(sql)
        if true != result {
            return print("create table fail.")
        }
        //关闭数据库
        db.close()
    }
    
    private func mmValues() -> Void {
        
        //结果
        var resultData = Dictionary<String, Any>()
        //是否为空？
        if let tempData = UserDefaults.standard.dictionary(forKey: NSHfhVar.fileName2AlarmSetting) {
            resultData = tempData
        }
        //当前值
        NSHfhVar.isAlarm = resultData["isAlarm"] as? Bool ?? true
        NSHfhVar.alarmMin = resultData["alarmMin"] as? CGFloat ?? NSHfhVar.lowBoundary
        NSHfhVar.alarmMax = resultData["alarmMax"] as? CGFloat ?? NSHfhVar.highBoundary
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
