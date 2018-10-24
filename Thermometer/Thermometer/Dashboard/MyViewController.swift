//
//  MyViewController.swift
//  Thermometer
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

class MyViewController: UIHfhTableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //整个背景
    private var headerbgView: UIView!
    //头像
    private var hdImageView: UIImageView!
    //登录名称
    private var userNameLabel: UILabel!
    //登录按钮
    private var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        //创建视图
        initViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //自定义navBar样式
        super.navigationStyle(transparent: true)
        //名称
        let tempVal = NSHfhVar.userInfo["pName"] as? String ?? ""
        userNameLabel.text = "" != tempVal ? tempVal : "匿名"
        //头像
        hdImageView.image = img()
    }
    
    override func resizeViewController(with size: CGSize) -> Void {

        //RECT值
        var rect1 = self.tableView.frame, rect2 = self.headerbgView.frame, rect3 = self.logoutButton.frame
        var rect4 = hdImageView.frame, rect5 = userNameLabel.frame
        rect1.size = size
        rect2.size.width = size.width
        rect3.size.width = size.width
        rect4.origin.x = 0.5 * (size.width - rect4.size.width)
        rect5.size.width = size.width
        //修改
        self.tableView.frame = rect1
        headerbgView.frame = rect2
        logoutButton.frame = rect3
        hdImageView.frame = rect4
        userNameLabel.frame = rect5
        //子视图RECT值
        let tempArray = self.tableView.visibleCells
        for cell in tempArray {
            (cell as! UIHfhSImgNmeCell).startResize = CGSize(width: size.width, height: self.hCell)
        }
    }

    // MARK: - Custom Methods
    
    private func initViews() -> Void {
        
        //加载显示内容
        if let pathString = Bundle.main.path(forResource: "MyViewController", ofType: "plist") {
            //加载
            let tempArray = NSArray(contentsOfFile: pathString) as! Array<Array<Dictionary<String, AnyObject>>>
            dataArray = tempArray
        }
        //RECT值
        let rect = CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: NSHfhVar.scHeight)
        //创建tableView
        super.showTableView(with: rect)
        self.tableView.showsVerticalScrollIndicator = false
        //y值
        let yVal = NSHfhVar.hStatusBar + NSHfhVar.hNaviBar
        //tableView的headerView
        let tbhView = UIView(frame: CGRect(x: 0.0, y: 0.0,
                                           width: NSHfhVar.scWidth, height: 0.4 * min(NSHfhVar.scWidth, NSHfhVar.scHeight)))
        tbhView.backgroundColor = NSHfhFunc.colorHex(intVal: NSHfhVar.themeColor)
        //背景
        headerbgView = UIView(frame: CGRect(x: 0.0, y: -yVal,
                                            width: NSHfhVar.scWidth, height: tbhView.frame.size.height + yVal))
        headerbgView.backgroundColor = NSHfhFunc.colorHex(intVal: NSHfhVar.themeColor)
        //添加
        tbhView.addSubview(headerbgView)
        //设置
        self.tableView.tableHeaderView = tbhView
        //头像账号
        myAccountViews(in: tbhView)
        //退出登录
        logoutViews()
    }
    
    private func myAccountViews(in bgView: UIView) -> Void {
        
        //参考边距、label的height值
        let lrVal: CGFloat = 10.0, hLabel: CGFloat = 24.0
        //背景rect值
        let rect = bgView.frame
        //头像大小、label大小
        let hdImgWH = 0.7 * rect.size.height
        //头像
        hdImageView = UIImageView(frame: CGRect(x: 0.5 * (rect.size.width - hdImgWH),
                                                y: 0.5 * (rect.size.height - hdImgWH - lrVal - hLabel - NSHfhVar.hNaviBar),
                                                width: hdImgWH, height: hdImgWH))
        hdImageView.clipsToBounds = true
        hdImageView.layer.cornerRadius = 0.5 * hdImgWH
        hdImageView.layer.borderColor = UIColor.white.cgColor
        hdImageView.layer.borderWidth = 4.0
        //hdImageView.isUserInteractionEnabled = true
        //用户名称
        userNameLabel = UILabel(frame: CGRect(x: 0.0, y: hdImageView.frame.origin.y + hdImgWH + lrVal,
                                              width: NSHfhVar.scWidth, height: hLabel))
        userNameLabel.textColor = UIColor.white
        userNameLabel.font = UIFont.systemFont(ofSize: 15.0)
        userNameLabel.textAlignment = .center
        //添加
        bgView.addSubview(hdImageView)
        bgView.addSubview(userNameLabel)
        //添加手势
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(headGestureRecognizer(_:)))
        hdImageView.addGestureRecognizer(recognizer)
    }
    
    private func logoutViews() -> Void {
        
        //按钮高宽度
        let hButton: CGFloat = 54.0, wButton = NSHfhVar.scWidth
        //边距参考
        let lrVal: CGFloat = 20.0
        //tableView的FooterView
        let tbfView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: lrVal + hButton))
        //退出登录
        logoutButton = UIButton(type: .custom)
        logoutButton.frame = CGRect(x: 0.5 * (NSHfhVar.scWidth - wButton), y: lrVal, width: wButton, height: hButton)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        logoutButton.clipsToBounds = true
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed(_:)), for: .touchUpInside)
        logoutButton.setTitleColor(NSHfhFunc.colorHex(intVal: 0xF55555), for: .normal)
        logoutButton.setTitle("退出登录", for: .normal)
        logoutButton.setBackgroundImage(NSHfhFunc.imageWithColor(NSHfhFunc.colorHex(intVal: 0xD9D9D9)),
                                        for: .highlighted)
        logoutButton.setBackgroundImage(NSHfhFunc.imageWithColor(UIColor.white), for: .normal)
        //添加
        tbfView.addSubview(logoutButton)
        //设置tableView的FooterView
        self.tableView.tableFooterView = tbfView
    }
    
    @objc private func headGestureRecognizer(_ sender: UITapGestureRecognizer) -> Void {
        
        //图片上传选择
        let alertController = UIAlertController(title: "", message: "请选择头像来源", preferredStyle: .actionSheet)
        //拍照
        let camera = UIAlertAction(title: "拍照", style: .default) { [unowned self] (alterAction: UIAlertAction) -> Void in
            self.pickerImageSourceType(.camera)
        }
        //从相册中选择
        let photoLibrary = UIAlertAction(title: "从相册中选择", style: .default) { [unowned self] (alterAction: UIAlertAction) -> Void in
            self.pickerImageSourceType(.photoLibrary)
        }
        //取消
        let cancle = UIAlertAction(title: "取消", style: .cancel) { (alterAction: UIAlertAction) -> Void in
            
        }
        //ipad使用，不加ipad上会崩溃
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender.view!
            popoverController.sourceRect = sender.view!.bounds
        }
        //添加
        alertController.addAction(camera)
        alertController.addAction(photoLibrary)
        alertController.addAction(cancle)
        //显示
        self.navigationController?.present(alertController, animated: true, completion: { () -> Void in
            
        })
    }
    
    @objc private func logoutButtonPressed(_ sender: UIButton) -> Void {
        
        //是否确定注销？
        let alertController = UIAlertController(title: "询问", message: "确认退出登录？", preferredStyle: .alert)
        //确定
        let trueAction = UIAlertAction(title: "退出", style: .destructive, handler: { (UIAlertAction) -> Void in
            //写登录标志
            NSHfhVar.userInfo["logined"] = "0" as AnyObject
            //保存
            if true != NSHfhFunc.saveData(NSHfhVar.userInfo, file: NSHfhVar.fileName2LoginUser) {
                print("userInfo保存失败")
            }
            //跳转到首页
            self.tabBarController?.selectedIndex = 0
            //显示登录
            NotificationCenter.default.post(name: NSHfhVar.notiLogin, object: self)
        })
        //取消
        let cancleAction = UIAlertAction(title: "取消", style: .cancel) { (UIAlertAction) -> Void in}
        //添加
        alertController.addAction(cancleAction)
        alertController.addAction(trueAction)
        //显示
        self.navigationController?.present(alertController, animated: true, completion: { () -> Void in})
    }
    
    private func pickerImageSourceType(_ sourceType: UIImagePickerControllerSourceType) -> Void {
        
        //判断能否打开相册(或是相机)？
        guard true == UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            return
        }
        //加载相册或是相册
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        imagePickerController.modalTransitionStyle = .coverVertical
        imagePickerController.allowsEditing = true
        //显示
        self.navigationController?.present(imagePickerController, animated: true, completion: { () -> Void in
            
        })
    }
    
    private func img() -> UIImage? {
        
        /*//头像
        if let imgData = NSHfhFunc.readData2Document(with: "\(NSHfhVar.userInfo["id"]!)" + NSHfhVar.hdImg2LoginUser) {
            if let tempImg = UIImage(data: imgData) {
                return tempImg
            }
        }*/
        //默认头像
        return UIImage(named: "db_my_head_default")
    }
    
    private func uploadImage(_ imgData: Data) -> Void {
        
        print("继续完善，敬请期待...")
    }
    
    // MARK: - UIImagePickerController Delegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        //关闭相册
        picker.dismiss(animated: true) { () -> Void in
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //当前选择图片
        let img = info[UIImagePickerControllerEditedImage] as! UIImage
        //关闭相册
        picker.dismiss(animated: true) { () -> Void in
            //头像是否为空？
            guard let imgData = UIImageJPEGRepresentation(img, 0.1) else {
                return
            }
            //上传图片
            self.uploadImage(imgData)
        }
    }
    
    // MARK: - UIScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) -> Void {
        
        var rect = headerbgView.frame
        rect.origin.y = scrollView.contentOffset.y
        rect.size.height = (self.tableView.tableHeaderView?.frame.size.height)! - scrollView.contentOffset.y
        //修改
        headerbgView.frame = rect;
    }
    
    // MARK: - TableView DataSource Delegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //重用CELL
        let sImgNmeCellIndentifer = "SImgNmeTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: sImgNmeCellIndentifer)
        //返回结果
        let newCell: UIHfhSImgNmeCell!
        //是否为空？
        if cell != nil {
            newCell = cell as! UIHfhSImgNmeCell
        }
        else {
            //创建
            newCell = UIHfhSImgNmeCell(style: .default, reuseIdentifier: sImgNmeCellIndentifer)
            //创建视图
            newCell.loadViewInSize(CGSize(width: NSHfhVar.scWidth, height: self.hCell))
        }
        //显示数据
        newCell.showData(self.dataArray[indexPath.section][indexPath.row], with: indexPath)
        //返回
        return newCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) -> Void {
        
        //当前ROW信息
        let rowDict = self.dataArray[indexPath.section][indexPath.row]
        //名称是否为空？
        if let nextClass = rowDict["nextClass"] as? String {
            //获取类名
            if let viewController = NSHfhFunc.viewControllerFromName(nextClass) as? UIHfhBaseViewController {
                //标题
                viewController.objStr = rowDict["name"] as! String
                //下一步时隐藏底部tabBar
                viewController.hidesBottomBarWhenPushed = true
                //显示
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
        //取消选中
        super.deselectIndexPath(indexPath)
    }
}
