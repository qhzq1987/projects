//
//  UIHfhCells.swift
//  UIHfhCells
//
//  Created by HeFahu on 2018/5/5.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

class UIHfhShadowCornerCell: UITableViewCell {
    
    //CELL大小
    open var selfSize: CGSize!
    //标题的宽度值
    open var widthName: CGFloat!
    //背景
    open var bgView: UIView!
    //箭头指引视图
    open var asyImgView: UIImageView!
    
    open func loadViewInSize(_ size: CGSize, with nameWidth: CGFloat = 44.0) -> Void {
        
        //背景颜色
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.clipsToBounds = true
        self.selectionStyle = .none
        //边距参考
        let lrVal: CGFloat = 10.0, lr15Val: CGFloat = 15.0
        //accessory大小
        let whImg: CGFloat = 16.0
        //背景
        bgView = UIView(frame: CGRect(x: lrVal, y: 0.0, width: size.width - 2.0 * lrVal, height: size.height))
        bgView.layer.cornerRadius = 4.0
        bgView.backgroundColor = UIColor.white
        //保存：标题宽度等
        selfSize = bgView.frame.size
        widthName = nameWidth
        //自定义
        asyImgView = UIImageView(frame: CGRect(x: selfSize.width - whImg - lr15Val, y: 0.5 * (selfSize.height - whImg),
                                               width: whImg, height: whImg))
        asyImgView.image = UIImage(named: "accessory_indicator")
        //添加
        bgView.addSubview(asyImgView)
        self.contentView.addSubview(bgView)
        //更多视图
        viewDidLoad()
    }
    
    open func willShadow() -> Void {
        
        bgView.layer.shadowColor = UIColor.lightGray.cgColor
        bgView.layer.shadowOpacity = 0.2
        bgView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    }
    
    open func viewDidLoad() -> Void {
        
        //被继承加载更多视图
    }
    
    open func showData(_ data: Dictionary<String, AnyObject>, with indexPath: IndexPath) -> Void {
        
        //显示数据
    }
}

// MARK: -

class UIHfhSCImgNmeCell: UIHfhShadowCornerCell {
    
    //tag图标
    private var tagImageView: UIImageView!
    //标题
    private var nameLabel: UILabel!
    
    override func viewDidLoad() -> Void {
        
        //tag图标的大小
        let whImg: CGFloat = 0.5 * self.selfSize.height
        //边距参考
        let lrVal: CGFloat = 15.0
        //标题的x值
        let xNmeLabel: CGFloat = 2.0 * lrVal + whImg
        //tag图标
        tagImageView = UIImageView(frame: CGRect(x: lrVal, y: 0.5 * (self.selfSize.height - whImg), width: whImg,
                                                 height: whImg))
        //标题
        nameLabel = UILabel(frame: CGRect(x: xNmeLabel, y: 0.0, width: self.bgView.frame.size.width - xNmeLabel - lrVal,
                                          height: self.selfSize.height))
        nameLabel.font = UIFont.systemFont(ofSize: 16.0)
        //添加
        self.bgView.addSubview(nameLabel)
        self.bgView.addSubview(tagImageView)
        //添加
        willShadow()
    }
    
    override func showData(_ data: Dictionary<String, AnyObject>, with indexPath: IndexPath) -> Void {
        
        //图标名称是否为空？
        if let tagImage = data["tagImage"] {
            //tag图标
            tagImageView.image = UIImage(named: tagImage as! String)
        }
        //标题
        nameLabel.text = data["name"] as? String
        //是否显示indictor?
        self.asyImgView.isHidden = "1" != data["showIndictor"] as? String
    }
}

// MARK: -

class UIHfhSquareCell: UITableViewCell {
    
    //CELL大小
    open var selfSize: CGSize!
    //标题的宽度值
    open var widthName: CGFloat!
    //分隔线颜色
    private var lineColor: Int = NSHfhVar.eeColor
    //分隔线
    private let separatorView = UIView()
    //顶部线条
    private var headLineView: UIView!
    
    //隐藏/显示分隔线
    open var isHiddenSeparator: Bool {
        
        set {
            separatorView.isHidden = newValue
        }
        get {
            return separatorView.isHidden
        }
    }
    
    //分隔线的x值
    open var xToSeparator: CGFloat {
        
        set {
            var rect = separatorView.frame
            rect.origin.x = newValue
            separatorView.frame = rect
        }
        get {
            return separatorView.frame.origin.x
        }
    }
    
    open var xwidthToSeparator: CGFloat {
        
        set {
            var rect = separatorView.frame
            rect.origin.x = newValue
            rect.size.width = self.selfSize.width - 2.0 * newValue
            separatorView.frame = rect
        }
        get {
            return separatorView.frame.origin.x
        }
    }
    
    open var widthToSeparator: CGFloat {
        
        set {
            var rect = separatorView.frame
            rect.size.width = newValue
            separatorView.frame = rect
        }
        get {
            return separatorView.frame.size.width
        }
    }
    
    //是否创建顶部线条
    open var isHiddenHeaderSeparator: Bool {
        
        set {
            //是否已创建？
            if nil == headLineView {
                //创建
                headLineView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.selfSize.width, height: NSHfhVar.whSeparator))
                headLineView.backgroundColor = NSHfhFunc.colorHex(intVal: lineColor)
                //添加
                self.contentView.addSubview(headLineView)
            }
            //是否需要显示？
            headLineView.isHidden = newValue
        }
        get {
            return headLineView.isHidden
        }
    }
    
    open var separatorLineColor: Int {
        
        //分隔线颜色
        set {
            separatorView.backgroundColor = NSHfhFunc.colorHex(intVal: newValue)
        }
        get {
            return lineColor
        }
    }
    
    open func loadViewInSize(_ size: CGSize, with nameWidth: CGFloat = 44.0) -> Void {
        
        //分隔线
        separatorView.frame = CGRect(x: 0.0,
                                     y: size.height - NSHfhVar.whSeparator, width: size.width, height: NSHfhVar.whSeparator)
        separatorView.backgroundColor = NSHfhFunc.colorHex(intVal: lineColor)
        //保存
        selfSize = size
        //标题宽度
        widthName = nameWidth
        //添加
        self.contentView.addSubview(separatorView)
        //背景颜色
        self.contentView.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.contentView.clipsToBounds = true
        //更多视图
        viewDidLoad()
    }
    
    open func viewDidLoad() -> Void {
        
        //被继承加载更多视图
    }
    
    open func showData(_ data: Dictionary<String, AnyObject>, with indexPath: IndexPath) -> Void {
        
        //显示数据
    }
}

// MARK: -

class UIHfhSNmeOnlyCell: UIHfhSquareCell {
    
    //标题
    private let nameLabel = UILabel()
    
    open var nameText: String? {
        //名称
        set {
            nameLabel.text = newValue
        }
        get {
            return nameLabel.text
        }
    }
    
    override func viewDidLoad() -> Void {
        
        //边距参考
        let lrVal: CGFloat = 15.0
        //标题
        nameLabel.frame = CGRect(x: lrVal, y: 0.0, width: self.selfSize.width - 2.0 * lrVal, height: self.selfSize.height)
        nameLabel.font = UIFont.systemFont(ofSize: 16.0)
        nameLabel.textColor = NSHfhFunc.colorHex(intVal: NSHfhVar.txt33Color)
        //添加
        self.contentView.addSubview(nameLabel)
    }
    
    override func showData(_ data: Dictionary<String, AnyObject>, with indexPath: IndexPath) -> Void {
        
        //标题
        nameLabel.text = data["name"] as? String
    }
}

// MARK: -

class UIHfhSImgNmeCell: UIHfhSquareCell {
    
    //tag图标
    private let tagImageView = UIImageView()
    //标题
    private let nameLabel = UILabel()
    //箭头指引视图
    private let asyImgView = UIImageView()
    
    open var startResize: CGSize {
        //修改RECT值
        set {
            self.selfSize.width = newValue.width
            //RECT值
            var rect = asyImgView.frame
            rect.origin.x = newValue.width - rect.size.width - 15.0/*见创建时设定值*/
            asyImgView.frame = rect
            //分隔线
            self.widthToSeparator = newValue.width
        }
        get {
            return self.selfSize
        }
    }
    
    override func viewDidLoad() -> Void {
        
        //tag图标的大小
        let whImg: CGFloat = 0.4 * self.selfSize.height, whAccessory: CGFloat = 16.0
        //边距参考
        let lrVal: CGFloat = 15.0
        //标题的x值
        let xNmeLabel: CGFloat = 2.0 * lrVal + whImg
        //tag图标
        tagImageView.frame = CGRect(x: lrVal, y: 0.5 * (self.selfSize.height - whImg), width: whImg, height: whImg)
        //标题
        nameLabel.frame = CGRect(x: xNmeLabel,
                                 y: 0.0, width: self.selfSize.width - xNmeLabel - lrVal, height: self.selfSize.height)
        nameLabel.font = UIFont.systemFont(ofSize: 16.0)
        nameLabel.textColor = NSHfhFunc.colorHex(intVal: NSHfhVar.txt33Color)
        //自定义
        asyImgView.frame = CGRect(x: selfSize.width - whAccessory - lrVal, y: 0.5 * (selfSize.height - whAccessory),
                                               width: whAccessory, height: whAccessory)
        asyImgView.image = UIImage(named: "accessory_indicator")
        //是否显示indictor?
        self.accessoryType = .none
        //添加
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(tagImageView)
        self.contentView.addSubview(asyImgView)
    }
    
    override func showData(_ data: Dictionary<String, AnyObject>, with indexPath: IndexPath) -> Void {
        
        //图标名称是否为空？
        if let tagImage = data["tagImage"] {
            //tag图标
            tagImageView.image = UIImage(named: tagImage as! String)
        }
        //标题
        nameLabel.text = data["name"] as? String
        //是否显示indictor?
        self.asyImgView.isHidden = ("1" != data["showIndictor"] as? String)
    }
}

// MARK: -

class UIHfhSNmeValCell: UIHfhSquareCell {
    
    //标题、值
    private let (nameLabel, valueLabel) = (UILabel(), UILabel())
    
    open var shrinkSeparator: Bool {
        //分隔线是否收缩？
        set {
            self.xToSeparator = false == newValue ? 0.0 : nameLabel.frame.origin.x
        }
        get {
            return self.xToSeparator > 0.0
        }
    }
    
    open var startResize: CGSize {
        //修改RECT值
        set {
            self.selfSize.width = newValue.width
            //RECT值
            var rect = valueLabel.frame
            rect.size.width = newValue.width - 2.0 * rect.origin.x
            valueLabel.frame = rect
            //分隔线
            self.widthToSeparator = newValue.width
        }
        get {
            return self.selfSize
        }
    }
    
    override func viewDidLoad() -> Void {
        
        //边距参考
        let lrVal: CGFloat = 15.0
        //标题
        nameLabel.frame = CGRect(x: lrVal, y: 0.0, width: self.selfSize.width - 2.0 * lrVal, height: self.selfSize.height)
        nameLabel.font = UIFont.systemFont(ofSize: 16.0)
        //值
        valueLabel.frame = nameLabel.frame
        valueLabel.font = nameLabel.font
        valueLabel.textAlignment = .right
        //添加
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(valueLabel)
        //不显示indictor
        self.accessoryType = .none
    }
    
    override func showData(_ data: Dictionary<String, AnyObject>, with indexPath: IndexPath) -> Void {
        
        //标题
        let nameVal = data["name"] as? String ?? ""
        //图标名称是否为空？
        if let tagImage = data["tagImage"] as? String {
            //图片大小
            let whImg = 0.3 * self.selfSize.height
            //tag图标
            let attachment = NSTextAttachment()
            attachment.bounds = CGRect(x: 0.0, y: -3.0, width: whImg, height: whImg)
            attachment.image = UIImage(named: tagImage)
            //添加
            let tempVal = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
            //添加名称
            tempVal.append(NSAttributedString(string: " " + nameVal))
            //显示
            nameLabel.attributedText = tempVal
        }
        else {
            nameLabel.text = nameVal
        }
        //样式
        resizeStyle(in: data)
        //值
        let tempVal = data["value"] as? String ?? ""
        //单位
        let unitVal = data["unit"] as? String ?? ""
        //显示
        valueLabel.text = tempVal + unitVal
    }
    
    private func resizeStyle(in data: Dictionary<String, AnyObject>) -> Void {
        
        //RECT值
        var rect = valueLabel.frame
        //是否显示indictor?
        if "1" != data["showIndictor"] as? String {
            self.accessoryType = .none
            rect.size.width = nameLabel.frame.size.width
        }
        else {
            self.accessoryType = .disclosureIndicator
            rect.size.width = self.selfSize.width - 3.0 * nameLabel.frame.origin.x - 8.0
        }
        //修改
        valueLabel.frame = rect
        //分隔线是否需要左移？
        self.xToSeparator = ("1" != data["xSeparator"] as? String) ? 0.0 : nameLabel.frame.origin.x
        //值颜色
        guard let tempVal = data["textColor"] as? String else {
            return valueLabel.textColor = NSHfhFunc.colorHex(intVal: NSHfhVar.txt99Color)
        }
        //自己定义颜色
        valueLabel.textColor = NSHfhFunc.colorHex(strVal: tempVal)
    }
}
