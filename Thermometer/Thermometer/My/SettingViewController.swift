//
//  SettingViewController.swift
//  Thermometer
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

private var setData = Dictionary<String, Any>()

class SettingViewController: UIHfhBaseViewController, UITextFieldDelegate {
    
    //报警开关
    private var alarmSwitch: UIHfhSwitch!
    //阈值
    private var minTextField: UITextField!, maxTextField: UITextField!
    private var minSlider: UISlider!, maxSlider: UISlider!
    private var minBorderView: UIView!, maxBorderView: UIView!
    //背景
    private var bgView: UIView!
    
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
    
    override func viewControllWillDisappear() -> Bool {
        
        //值
        NSHfhVar.alarmMin = CGFloat(minSlider.value)
        NSHfhVar.alarmMax = CGFloat(maxSlider.value)
        NSHfhVar.isAlarm = alarmSwitch.isOn
        //本地设置
        let usrDefault = UserDefaults.standard
        //是否为空？
        let tempData = ["alarmMin": NSHfhVar.alarmMin, "alarmMax": NSHfhVar.alarmMax, "isAlarm": NSHfhVar.isAlarm]
            as [String : Any]
        //保存
        usrDefault.setValue(tempData, forKey: NSHfhVar.fileName2AlarmSetting)
        usrDefault.synchronize()
        //返回
        return true
    }
    
    override func resizeViewController(with size: CGSize) -> Void {
        
        //RECT
        var rect1 = self.scrollView.frame, rect2 = bgView.frame, rect3 = alarmSwitch.frame
        rect1.size = size
        rect2.size.width = size.width
        rect3.origin.x = size.width - rect3.size.width - 15.0
        //修改
        self.scrollView.frame = rect1
        bgView.frame = rect2
        alarmSwitch.frame = rect3
        //修改contentSize值
        self.scrollView.contentSize = CGSize(width: size.width, height: size.height + 0.5)
        //阈值区域
        resizeMinMax(in: size)
    }
    
    // MARK: - Custom Methods
    
    private func initViews() -> Void {
        
        //RECT值
        let rect = CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: NSHfhVar.scHeight)
        //创建tableView
        super.showScroll(with: rect)
        //单位高度
        let hUnit: CGFloat = 54.0
        //间距参考
        let lrVal: CGFloat = 10.0
        //背景
        bgView = UIView(frame: CGRect(x: 0.0, y: lrVal, width: NSHfhVar.scWidth, height: 3.0 * hUnit))
        bgView.backgroundColor = UIColor.white
        bgView.clipsToBounds = true
        //列表项
        itemViews(hUnit)
        //添加
        self.scrollView.addSubview(bgView)
        //初始值
        upateValues()
        //打开还是关闭？
        resizeView(NSHfhVar.isAlarm)
    }
    
    private func itemViews(_ hUnit: CGFloat) -> Void {
        
        //switch的大小
        let wSwitch: CGFloat = 54.0, hSwitch: CGFloat = 0.6 * hUnit
        //文本宽度
        let wLabel: CGFloat = 84.0
        //温度值的高度
        let hValue: CGFloat = 0.7 * hUnit
        //间距参考
        let lrVal: CGFloat = 15.0
        //温度区域的x值
        let xVal: CGFloat = lrVal + wLabel, yVal: CGFloat = 0.5 * (hUnit - hValue)
        let wVal: CGFloat = bgView.frame.size.width - lrVal - xVal
        //是否报警？
        let alarmLabel = label(with: CGRect(x: lrVal, y: 0.0, width: wLabel, height: hUnit), text: "开启报警")
        alarmSwitch = UIHfhSwitch(frame: CGRect(x: bgView.frame.size.width - lrVal - wSwitch, y: 0.5 * (hUnit - hSwitch),
                                                width: wSwitch, height: hSwitch))
        alarmSwitch.loadCustomView { [unowned self] (hfhSwitch: UIHfhSwitch, isOn: Bool) in
            //打开还是关闭？
            NSHfhVar.isAlarm = isOn
            //修改RECT值
            self.resizeView(isOn)
        }
        alarmSwitch.isOn = NSHfhVar.isAlarm
        //分隔线
        let lineView = UIView(frame: CGRect(x: 0.0, y: alarmLabel.frame.maxY,
                                            width: bgView.frame.size.width, height: NSHfhVar.whSeparator))
        lineView.backgroundColor = NSHfhFunc.colorHex(intVal: NSHfhVar.eeColor)
        //低温阈值
        let minLabel = label(with: CGRect(x: lrVal, y: alarmLabel.frame.maxY, width: wLabel, height: hUnit), text: "低温阈值")
        let minVal = valueSliderViews(with: CGRect(x: xVal, y: minLabel.frame.origin.y + yVal, width: wVal,
                                                   height: hValue), tag: -1)
        minTextField = minVal.t
        minSlider = minVal.s
        minBorderView = minVal.b
        //高温阈值
        let maxLabel = label(with: CGRect(x: lrVal, y: minLabel.frame.maxY, width: wLabel, height: hUnit), text: "高温阈值")
        let maxVal = valueSliderViews(with: CGRect(x: xVal, y: maxLabel.frame.origin.y + yVal, width: wVal,
                                                   height: hValue), tag: 1)
        maxTextField = maxVal.t
        maxSlider = maxVal.s
        maxBorderView = maxVal.b
        //添加
        bgView.addSubview(alarmSwitch)
        bgView.addSubview(lineView)
    }
    
    private func resizeView(_ isOn: Bool, with animating: Bool = true) -> Void {
        
        //单位高度
        let hUnit: CGFloat = 54.0
        //高度值
        var tempVal: CGFloat = 1.0
        if false != isOn {
            tempVal = 3.0
        }
        //RECT值
        var rect = bgView.frame
        rect.size.height = tempVal * hUnit
        //动画方式？
        if true == animating {
            UIView.animate(withDuration: 0.25) { self.bgView.frame = rect
            }
        }
        else {
            bgView.frame = rect
        }
    }
    
    private func upateValues() -> Void {
        
        //当前最小大温度
        minSlider.minimumValue = Float(NSHfhVar.lowBoundary)
        minSlider.maximumValue =  Float(NSHfhVar.highBoundary)
        maxSlider.minimumValue = minSlider.minimumValue
        maxSlider.maximumValue = minSlider.maximumValue
        //阈值
        minSlider.value = Float(NSHfhVar.alarmMin)
        maxSlider.value = Float(NSHfhVar.alarmMax)
        //显示默认值
        minTextField.text = String(format: "%0.1f", minSlider.value)
        maxTextField.text = String(format: "%0.1f", maxSlider.value)
    }
    
    private func valueSliderViews(with frame: CGRect, tag: Int) -> (t: UITextField, s: UISlider, b: UIView) {
        
        //背景
        let tempView = UIView(frame: frame)
        tempView.backgroundColor = UIColor.white
        tempView.layer.cornerRadius = 4.0
        tempView.layer.borderWidth = NSHfhVar.whSeparator
        tempView.layer.borderColor = NSHfhFunc.colorHex(intVal: NSHfhVar.themeColor).cgColor
        tempView.clipsToBounds = true
        //文本宽度
        let wTextField: CGFloat = 50.0
        //文本
        let tempTextField = textField(with: CGRect(x: 0.0, y: 0.0, width: wTextField, height: frame.size.height))
        //slider
        let tempSlider = slider(with: CGRect(x: tempTextField.frame.maxX, y: 0.0,
                                             width: frame.size.width - tempTextField.frame.maxX - 8.0, height: frame.size.height),
                                tag: tag)
        //添加
        tempView.addSubview(tempTextField)
        tempView.addSubview(tempSlider)
        bgView.addSubview(tempView)
        //返回
        return (tempTextField, tempSlider, tempView)
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) -> Void {
        
        //高还是低？
        switch sender.tag {
        case -1:
            //低
            minTextField.text = String(format: "%0.1f", sender.value)
        default:
            maxTextField.text = String(format: "%0.1f", sender.value)
        }
    }
    
    private func resizeMinMax(in size: CGSize) -> Void {
        
        //RECT值
        var rect1 = minBorderView.frame, rect2 = minSlider.frame, rect3 = maxBorderView.frame, rect4 = maxSlider.frame
        rect1.size.width = size.width - rect1.origin.x - 15.0/*参见创建时设置值*/
        rect2.size.width = rect1.size.width - minTextField.frame.maxX - 8.0/*参见创建时设置值*/
        rect3.size.width = rect1.size.width
        rect4.size.width = rect2.size.width
        //修改
        minBorderView.frame = rect1
        minSlider.frame = rect2
        maxBorderView.frame = rect3
        maxSlider.frame = rect4
    }
    
    private func label(with frame: CGRect, text: String, font: CGFloat = 16.0, textColor: Int = 0) -> UILabel {
        
        //创建
        let tempLabel = UILabel(frame: frame)
        tempLabel.text = text
        tempLabel.textColor = NSHfhFunc.colorHex(intVal: textColor)
        tempLabel.font = UIFont.systemFont(ofSize: font)
        //添加
        bgView.addSubview(tempLabel)
        //返回
        return tempLabel
    }
    
    private func textField(with frame: CGRect) -> UITextField {
        
        //创建
        let textField = UITextField(frame: frame)
        textField.font = UIFont.systemFont(ofSize: 16.0)
        textField.keyboardType = .decimalPad
        textField.delegate = self
        textField.textAlignment = .center
        //添加
        bgView.addSubview(textField)
        //返回
        return textField
    }
    
    private func slider(with frame: CGRect, tag: Int) -> UISlider {
        
        //创建
        let tempSlider = UISlider(frame: frame)
        tempSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        tempSlider.tag = tag
        tempSlider.minimumTrackTintColor = NSHfhFunc.colorHex(intVal: NSHfhVar.themeColor)
        //添加
        bgView.addSubview(tempSlider)
        //返回
        return tempSlider
    }
}
