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
    
    //温度key值
    static let LOW_TMPT_KEY = "LowTmpt", HIGH_TMPT_KEY = "HighTmpt"
    static let MIN_TMPT_KEY = "MinTmpt", MAX_TMPT_KEY = "MaxTmpt"
    static let SETTING_VALUES_KEY = "SettingValues"
    //温度的最大值和最小值
    static let MAX_TEMP_VALUE: Float = 50.0, MIN_TEMP_VALUE: Float = 20.0
    
    //用户信息
    static var userInfo = Dictionary<String, AnyObject>()
    //用户文件名
    static let fileName2LoginUser = "lgu.dta"
    //头像：id + 后缀
    static let hdImg2LoginUser = "_hd_img_lgn.dta"
    //科室
    static let fileName2Department = "dpt.dta"
    //病区
    static let fileName2Zone = "zone.dta"
    
    //登录事件
    static let notiLogin = NSNotification.Name("notification_will_login")
    //登录成功
    static let notiLoginSuccess = NSNotification.Name("notification_login_success")
}
