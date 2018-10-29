//
//  NSHfhVar.swift
//  NSHfhVar
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

class NSHfhVar: NSObject {

    //屏幕size值
    static var (scWidth, scHeight) = (UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    //温度的最小值和最大值
    static let (lowBoundary, highBoundary) = (CGFloat(20.0), CGFloat(50.0))
    
    //文本色
    static let txt33Color: Int = 0x333333, txt66Color: Int = 0x666666, txt99Color: Int = 0x999999
    //系统线条（分隔线、边框）色
    static let eeColor: Int = 0xEEEEEE
    //系统主题色、背景色
    static let themeColor: Int = 0x68B2FF, backgroundColor: Int = 0xF6F6F6
    
    //线条宽（高）度
    static let whSeparator: CGFloat = 0.5
    //navi的高度
    static let hNaviBar: CGFloat = 44.0
    //statusBar的高度
    static let hStatusBar: CGFloat = UIApplication.shared.statusBarFrame.size.height
    
    //1.是否报警？2.最低、高温度报警
    static var isAlarm: Bool = true
    static var alarmMin: CGFloat = 0.0, alarmMax: CGFloat = 50.0
    
    //用户信息
    static var userInfo = Dictionary<String, AnyObject>()
    //用户文件名
    static let fileName2LoginUser = "lgu.dta"
    //科室
    static let fileName2Department = "dpt.dta"
    //病区
    static let fileName2Zone = "zone.dta"
    //报警设置
    static let fileName2AlarmSetting = "alarmsetting.dta"
    
    //登录成功
    static let notiLoginSuccess = NSNotification.Name("notification_login_success")
    //登录事件
    static let notiLogin = NSNotification.Name("notification_will_login")
}
