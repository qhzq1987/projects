//
//  UIHfhCellsView.swift
//  UIHfhCellsView
//
//  Created by HeFahu on 2018/5/5.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

class UIHfhCellsView: UIView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //边距参考
    private let LR_VALUE: CGFloat = 15.0, CODE_TAG_VALUE: Int = 66
    //cell对象
    private var cellsArray = Array<UIView>()
    //textField对象
    private var textFieldsArray = Array<ValueTextField>()
    //当前编辑对象
    private var currTextField: ValueTextField!
    //分隔线
    private var linesArray = Array<UIView>()
    //下一步按钮
    private var nextButton: UIButton!
    //tableView
    private var tableView: UITableView!
    //列表数据
    private var dataArray = Array<String>()
    
    //闭包
    typealias ReturnClosure = (_ view: UIHfhCellsView, _ type: UIHfhCellViewType, _ indexPath: IndexPath?) -> Void
    //回调
    private var returnClosure: ReturnClosure?
    
    open var reloadData: Array<String> {
        //刷新数据
        set {
            dataArray.removeAll()
            for i in newValue {
                dataArray.append(i)
            }
            //RECT值
            var rect = tableView.frame
            rect.size.height = 44.0 * CGFloat(dataArray.count)
            tableView.frame = rect
            //刷新数据
            tableView.reloadData()
        }
        get {
            return dataArray
        }
    }
    
    open var startResize: CGSize {
        //修改RECT值
        set {
            //RECT
            var rect1 = nextButton.frame, rect2 = self.frame
            rect2.size.width = newValue.width
            rect1.size.width = newValue.width - 2.0 * rect1.origin.x
            nextButton.frame = rect1
            self.frame = rect2
            //其他RECT值
            for cell in cellsArray {
                var rect = cell.frame
                rect.size.width = newValue.width
                cell.frame = rect
            }
            for textField in textFieldsArray {
                var rect = textField.frame
                rect.size.width = newValue.width - rect.origin.x - rect1.origin.x
                textField.frame = rect
            }
            for line in linesArray {
                var rect = line.frame
                rect.size.width = newValue.width
                line.frame = rect
            }
            //tableView
            resizeTableView()
        }
        get {
            return self.frame.size
        }
    }
    
    open func loadCustomView(_ data: Array<Array<Dictionary<String, AnyObject>>>,
                             sht: Dictionary<String, String> = [:], with closure: @escaping ReturnClosure) -> Void {
        
        //当前size值
        let size = self.frame.size
        //CELL高度
        let hCell: CGFloat = 54.0
        //y值
        var yVal: CGFloat = 0.0
        //创建
        for i in 0 ..< data.count {
            let rows = data[i]
            //累加section的高度
            yVal += stitleView(in: size, y: yVal, text: sht["\(i)"] ?? "")
            for j in 0 ..< rows.count {
                //RECT值
                let rect = CGRect(x: 0.0, y: yVal, width: size.width, height: hCell)
                let indexPath = IndexPath(row: j, section: i)
                cellTypeView(with: rect, in: rows[j], at: indexPath)
                //y值累加
                yVal += rect.size.height
            }
        }
        //创建tableView
        tableView = UITableView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: 0.0), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = NSHfhFunc.colorHex(intVal: NSHfhVar.eeColor)
        tableView.layer.borderWidth = NSHfhVar.whSeparator
        tableView.layer.borderColor = tableView.separatorColor?.cgColor
        //添加
        self.addSubview(tableView)
        //保存
        returnClosure = closure
    }
    
    open func regular() -> (resCode: Bool/*false-失败，true-成功*/, msg: String) {
        
        for i in 0 ..< cellsArray.count {
            let textField = textFieldsArray[i]
            let tempVal = textField.text ?? ""
            //是否为空的标志？
            if "" == tempVal {
                //是否可为空？
                if "1" != textField.notnull {
                    continue
                }
                return (false, "\(textField.name)不能为空")
            }
            //是否有规则？
            switch textField.regular {
            case "P":
                //手机号码第1位为1，其余的10都为数字即可
                let predicate = NSPredicate(format: "SELF MATCHES %@", "^[1]+\\d{10}$")
                let tempVal = predicate.evaluate(with: tempVal)
                //是否合法？
                if true != tempVal {
                    return (false, "\(textField.name)错误，请确认")
                }
            case "C":
                //验证码
                let codeView = cellsArray[i].viewWithTag(CODE_TAG_VALUE) as! UIHfhCodeView
                let tempVal = codeView.code.uppercased()
                //是否相等？
                if tempVal.uppercased() != tempVal {
                    return (false, "\(textField.name)错误，请确认")
                }
            default:
                break
            }
        }
        //验证成功
        return (true, "")
    }
    
    open func nextView(with title: String, normal img1: UIImage, highlighted img2: UIImage) -> Void {
        
        //按钮高宽度
        let hButton: CGFloat = 44.0, wButton = self.frame.size.width - 2.0 * LR_VALUE
        //y值
        let yVal: CGFloat = cellsArray.last?.frame.maxY ?? 0.0
        //按钮
        nextButton = UIButton(type: .custom)
        nextButton.frame = CGRect(x: 0.5 * (self.frame.width - wButton), y: yVal + 2.0 * LR_VALUE/* 上边距 */,
            width: wButton, height: hButton)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        nextButton.setTitle(title, for: .normal)
        nextButton.setTitleColor(UIColor.white, for: .normal)
        nextButton.clipsToBounds = true
        nextButton.layer.cornerRadius = 5.0
        nextButton.addTarget(self, action: #selector(nextButtonPressed(_:)), for: .touchUpInside)
        nextButton.setBackgroundImage(img1, for: .normal)
        nextButton.setBackgroundImage(img2, for: .highlighted)
        //添加
        self.addSubview(nextButton)
        //层级
        self.bringSubview(toFront: tableView)
    }
    
    open func hideKeyboard() -> Void {
        
        //关闭键盘
        for textField in textFieldsArray {
            textField.resignFirstResponder()
        }
        //隐藏
        tableView.isHidden = true
    }
    
    open func data() -> Dictionary<String, String> {
        
        //所有值
        var tempData = Dictionary<String, String>()
        for textField in textFieldsArray {
            tempData[textField.valueKey] = textField.text ?? ""
        }
        //返回
        return tempData
    }
    
    private func resizeTableView() -> Void {
        
        //当前tableView，如果隐藏就不进行处理
        if true == tableView.isHidden {
            return
        }
        //转换坐标
        let pt = currTextField.convert(currTextField.frame.origin, to: self)
        //RECT值
        var rect3 = tableView.frame
        rect3.size.width = currTextField.frame.size.width
        rect3.origin.y = pt.y + currTextField.frame.size.height
        rect3.origin.x = currTextField.frame.origin.x
        //修改
        tableView.frame = rect3
    }
    
    private func cellTypeView(with frame: CGRect, in data: Dictionary<String, AnyObject>, at indexPath: IndexPath) -> Void {
        
        //CELL类型
        let typeVal: String = data["cellType"] as? String ?? ""
        //CELL视图
        var tempView: (c: UIView, v: ValueTextField)!
        switch typeVal {
        //CELL类型可自行扩展或是自定义
        case "C":
            tempView = codeCellViews(with: frame, in: data)
        default:
            tempView = valueCellViews(with: frame, in: data)
        }
        //保存
        cellsArray.append(tempView.c)
        textFieldsArray.append(tempView.v)
        //背景颜色
        tempView.c.backgroundColor = UIColor.white
        //添加
        self.addSubview(tempView.c)
        //textField对象属性
        attribute2TextField(tempView.v, in: data, at: indexPath)
        //分隔线
        lineViews(data, in: tempView.c)
    }
    
    private func lineViews(_ data: Dictionary<String, AnyObject>, in bgView: UIView) -> Void {
        
        //是否添加分隔线？
        if "1" == data["noneSeparator"] as? String {
            return
        }
        //线条颜色
        let color: CGFloat = 238.0 / 255.0
        //线条高宽值
        let whSeparator: CGFloat = 0.5
        //分隔线是否需要左移？
        let tempVal = ("1" != data["xSeparator"] as? String) ? 0.0 : LR_VALUE
        //size值
        let size = bgView.frame.size
        //分隔线
        let lineView = UIView(frame: CGRect(x: tempVal, y: size.height - whSeparator, width: size.width, height: whSeparator))
        lineView.backgroundColor = UIColor(red: color, green: color, blue: color, alpha: 1.0)
        //添加、保存
        bgView.addSubview(lineView)
        linesArray.append(lineView)
    }
    
    private func valueCellViews(with frame: CGRect, in data: Dictionary<String, AnyObject>) -> (UIView, ValueTextField) {
        
        //背景
        let bgView = UIView(frame: frame)
        //标题宽度
        let wLabel: CGFloat = 94.0
        //标题
        let nameLabel = UILabel(frame: CGRect(x: LR_VALUE, y: 0.0, width: wLabel, height: frame.size.height))
        nameLabel.font = UIFont.systemFont(ofSize: 16.0)
        nameLabel.text = data["name"] as? String
        //宽度
        let wTextField = frame.size.width - nameLabel.frame.maxX - LR_VALUE
        //textField
        let tempTextField = textField(CGRect(x: nameLabel.frame.maxX, y: 0.0, width: wTextField, height: frame.size.height),
                                      in: data)
        //添加
        bgView.addSubview(nameLabel)
        bgView.addSubview(tempTextField)
        //返回
        return (bgView, tempTextField)
    }
    
    private func codeCellViews(with frame: CGRect, in data: Dictionary<String, AnyObject>) -> (UIView, ValueTextField) {
        
        //背景
        let bgView = UIView(frame: frame)
        //标题宽度
        let wLabel: CGFloat = 94.0
        //标题
        let nameLabel = UILabel(frame: CGRect(x: LR_VALUE, y: 0.0, width: wLabel, height: frame.size.height))
        nameLabel.font = UIFont.systemFont(ofSize: 16.0)
        nameLabel.text = data["name"] as? String
        //按钮大小
        let sizeCode = CGSize(width: 74.0, height: 0.6 * frame.size.height)
        //RECT值
        let rect = CGRect(origin: CGPoint(x: frame.size.width - sizeCode.width - LR_VALUE,
                                          y: 0.5 * (frame.size.height - sizeCode.height)), size: sizeCode)
        //创建
        let codeView = UIHfhCodeView(frame: rect)
        codeView.reset()
        codeView.tag = CODE_TAG_VALUE
        //宽度
        let wTextField = codeView.frame.origin.x - nameLabel.frame.maxX - 2.0 * LR_VALUE
        //textField
        let tempTextField = textField(CGRect(x: nameLabel.frame.maxX, y: 0.0, width: wTextField, height: frame.size.height), in: data)
        //添加
        bgView.addSubview(nameLabel)
        bgView.addSubview(tempTextField)
        bgView.addSubview(codeView)
        //返回
        return (bgView, tempTextField)
    }
    
    private func stitleView(in size: CGSize, y: CGFloat, text: String) -> CGFloat {
        
        //宽度
        let wLabel: CGFloat = size.width - 2.0 * LR_VALUE
        //标题高度
        let hLabel: CGFloat = 38.0
        //是否为空？
        if "" != text {
            //标题
            let tempLabel = UILabel(frame: CGRect(x: LR_VALUE, y: y, width: wLabel, height: hLabel))
            tempLabel.text = text
            tempLabel.font = UIFont.systemFont(ofSize: 14.0)
            //添加
            self.addSubview(tempLabel)
            //返回
            return hLabel
        }
        //默认
        return 15.0
    }
    
    private func textField(_ frame: CGRect, in data: Dictionary<String, AnyObject>) -> ValueTextField {
        
        //创建
        let textField = ValueTextField(frame: frame)
        textField.delegate = self
        textField.isUserInteractionEnabled = "1" != (data["isReadOnly"] as? String)
        textField.placeholder = data["placeholder"] as? String
        textField.isSecureTextEntry = "1" == (data["isSecure"] as? String)
        textField.text = data["value"] as? String
        textField.clearButtonMode = .whileEditing
        textField.font = UIFont.systemFont(ofSize: 16.0)
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(closeKeyboard(_:)), for: .editingDidEndOnExit)
        //返回
        return textField
    }
    
    private func keyboardType(to textField: UITextField, in data: Dictionary<String, AnyObject>) -> Void {
        
        //键盘类型
        guard let keyboardType = data["keyboardType"] as? String else {
            return
        }
        //判断类型
        switch keyboardType {
        case "A":
            textField.keyboardType = .asciiCapable
        case "C":
            //所有字母大写
            textField.autocapitalizationType = .allCharacters
            textField.keyboardType = .asciiCapable
        case "N":
            textField.keyboardType = .numberPad
        case "P":
            textField.keyboardType = .phonePad
        case "E":
            textField.keyboardType = .emailAddress
        default:
            break
        }
    }
    
    private func textAlignment(to textField: UITextField, in data: Dictionary<String, AnyObject>) -> Void {
        
        //对齐类型
        guard let textAlignment = data["textAlignment"] as? String else {
            return
        }
        //判断类型
        switch textAlignment {
        case "1":
            textField.textAlignment = NSTextAlignment.center
        case "2":
            textField.textAlignment = NSTextAlignment.right
        default:
            break
        }
    }
    
    private func attribute2TextField(_ textField: ValueTextField,
                                     in data: Dictionary<String, AnyObject>, at indexPath: IndexPath) -> Void {
        
        //textField对象属性
        textField.indexPath = indexPath
        textField.valueKey = data["valueKey"] as? String ?? ""
        textField.name = data["name"] as? String ?? ""
        textField.regular = data["regular"] as? String ?? ""
        textField.notnull = data["notnull"] as? String ?? "0"
        textField.maxLength = data["maxLength"] as? Int ?? 0
        textField.listData = data["listData"] as? String ?? ""
        //键盘类型
        keyboardType(to: textField, in: data)
        //对齐方式
        textAlignment(to: textField, in: data)
    }
    
    @objc private func closeKeyboard(_ sender: UITextField) -> Void {
        
        //关闭键盘
        sender.resignFirstResponder()
    }
    
    @objc private func nextButtonPressed(_ sender: UIButton) -> Void {
        
        //回调是否为空？
        if let tempReturnClosure = returnClosure {
            tempReturnClosure(self, .next, nil)
        }
    }
    
    // MARK: - TextField Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        //当前对象
        let tempTextField = textField as! ValueTextField
        //是否显示列表？
        if "1" != tempTextField.listData {
            //隐藏
            tableView.isHidden = true
            return true
        }
        //保存
        currTextField = tempTextField
        //转换坐标
        let pt = tempTextField.convert(tempTextField.frame.origin, to: self)
        //修改RECT值
        var rect = tableView.frame
        rect.size.width = tempTextField.frame.size.width
        rect.origin.y = pt.y + tempTextField.frame.size.height
        rect.origin.x = tempTextField.frame.origin.x
        tableView.frame = rect
        //显示
        tableView.isHidden = false
        //回调是否为空？
        if let tempReturnClosure = returnClosure {
            tempReturnClosure(self, .shouldEdit, tempTextField.indexPath)
        }
        //返回
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        //当前对象
        let tempTextField = textField as! ValueTextField
        //是否显示列表？
        if "1" != tempTextField.listData {
            return true
        }
        //返回
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //当前对象
        let tempTextField = textField as! ValueTextField
        //replacementString是否为空？
        if tempTextField.maxLength > 0 && "" != string {
            //长度是否小于最大长度
            return (textField.text ?? "").count < tempTextField.maxLength
        }
        return true
    }
    
    // MARK: - TableView DataSource Delegate
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return dataArray.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //重用CELL
        let sTableViewCellIndentifer = "STableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: sTableViewCellIndentifer)
        //返回结果
        let newCell: UITableViewCell!
        //是否为空？
        if cell != nil {
            newCell = cell
        }
        else {
            newCell = UITableViewCell(style: .default, reuseIdentifier: sTableViewCellIndentifer)
        }
        //显示值
        newCell.textLabel?.text = dataArray[indexPath.row]
        //返回
        return newCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) -> Void {
        
        //显示内容
        if nil != currTextField {
            currTextField.text = dataArray[indexPath.row]
        }
        //取消选中
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: -

enum UIHfhCellViewType: Int {
    case next
    case shouldEdit
    case unkonw
}

// MARK: -

fileprivate class ValueTextField: UITextField {
    
    //indexPath值
    var indexPath: IndexPath!
    //规则
    var regular: String = ""
    //名称
    var name: String = ""
    //key值
    var valueKey: String = ""
    //最大长度
    var maxLength: Int = 0
    //是否为空？
    var notnull: String = "0"
    //是否有列表？
    var listData: String = ""
}
