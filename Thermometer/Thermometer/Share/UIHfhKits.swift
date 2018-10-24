//
//  UIHfhKits.swift
//  UIHfhKits
//
//  Created by HeFahu on 2018/5/5.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

class UIHfhTextField: UITextField {
    
    //左边tag图片的背景
    private var leftbgView: UIView!
    //左右边的tag图片
    private var ltagImageView: UIImageView!, rtagImageView: UIImageView!
    //边距值
    private var leftVal: CGFloat = 0.0, rightVal: CGFloat = 0.0
    //右边的tag图片背景
    private var rightbgView: UIView!
    //下边线条
    private var bottomLineView: UIView!
    //是否可粘贴？
    open var isPaste: Bool = true
    //是否复制
    open var isCopy: Bool = true
    
    open var leftImage: String {
        //左边的tag图片
        set {
            //图片视图是否为空？
            if nil != ltagImageView {
                return ltagImageView.image = UIImage(named: newValue)
            }
            //size值
            let size = self.frame.size
            //图片大小
            let imgWH = 0.6 * size.height, wVal: CGFloat = imgWH + 7.0 + leftVal
            //左边视图
            if nil != leftbgView {
                var rect = leftbgView.frame;rect.size.width = wVal
                leftbgView.frame = rect
            }
            else {
                currLeftView(with: wVal)
            }
            //图片
            ltagImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.5 * (size.height - imgWH), width: imgWH, height: imgWH))
            ltagImageView.image = UIImage(named: newValue)
            //添加
            leftbgView.addSubview(ltagImageView)
        }
        get {
            return ""
        }
    }
    
    open var rightImage: String {
        //右边的tag图片
        set {
            //图片是否为空？
            guard let image = UIImage(named: newValue) else {
                return
            }
            //图片视图是否为空？
            if nil != rtagImageView {
                return rtagImageView.image = image
            }
            //size值
            let size = self.frame.size, wVal: CGFloat = 30.0 + rightVal
            //右边区域
            if nil != rightbgView {
                var rect = rightbgView.frame;rect.size.width = wVal
                rightbgView.frame = rect
            }
            else {
                currRightView(with: wVal)
            }
            //图片大小
            let imgWH = 0.6 * size.height
            //tag图片
            rtagImageView = UIImageView(frame: CGRect(x: 0.0, y: 0.5 * (size.height - imgWH), width: imgWH, height: imgWH))
            rtagImageView.image = image
            rtagImageView.contentMode = .center
            //添加
            rightbgView.addSubview(rtagImageView)
        }
        get {
            return ""
        }
    }
    
    open var adjustTextLeft: CGFloat {
        //文本的左边距
        set {
            //保存
            leftVal = newValue
            //是否为空？
            if nil == leftbgView {
                return currLeftView(with: newValue)
            }
            var rect = leftbgView.frame
            rect.size.width = ltagImageView.frame.size.width + 7.0 + newValue
            //修改
            leftbgView.frame = rect
        }
        get {
            return nil == leftbgView ? 0.0 : leftbgView.frame.origin.x - 7.0
        }
    }
    
    open var adjustTextRight: CGFloat {
        //文本的左边距
        set {
            //保存
            rightVal = newValue
            //是否为空？
            if nil == rightbgView {
                return currRightView(with: newValue)
            }
            var rect = rightbgView.frame
            rect.size.width = rtagImageView.frame.size.width + 7.0 + newValue
            //修改
            rightbgView.frame = rect
        }
        get {
            return nil == leftbgView ? 0.0 : leftbgView.frame.origin.x - 7.0
        }
    }
    
    open var lineColor: UIColor {
        //下边线条
        set {
            //当前大小
            let size = self.frame.size
            //创建线条
            bottomLineView = UIView(frame: CGRect(x: 0.0, y: size.height - 1.0, width: size.width, height: 1.0))
            bottomLineView.backgroundColor = newValue
            //添加
            super.addSubview(bottomLineView)
        }
        get {
            return bottomLineView.backgroundColor ?? UIColor.white
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        //禁用粘贴功能？
        if action == #selector(paste(_:)) {
            return isPaste
        }
        //禁用复制功能？
        if action == #selector(copy(_:)) || action == #selector(cut(_:)) {
            return isCopy
        }
        //其余的都可进行操作
        return super.canPerformAction(action, withSender: sender)
    }
    
    open func rightView(to action: Selector, with target: Any) -> Void {
        
        //右边view是否为空？
        guard let tempView = super.rightView else {
            return
        }
        //添加
        tempView.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }
    
    private func currLeftView(with width: CGFloat) -> Void {
        
        //左边区域
        leftbgView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: width, height: self.frame.size.height))
        leftbgView.backgroundColor = UIColor.clear
        //设置
        super.leftView = leftbgView
        super.leftViewMode = .always
    }
    
    private func currRightView(with width: CGFloat) -> Void {
        
        //右边区域
        rightbgView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: width, height: self.frame.size.height))
        rightbgView.backgroundColor = UIColor.clear
        //设置
        super.rightView = rightbgView
        super.rightViewMode = .always
    }
}

// MARK: -

class UIHfhUnititView: UIView {
    
    //图片
    private let tagImageView = UIImageView()
    //名称对象
    private let nameLabel = UILabel()
    //badge
    private var badgeLabel: UILabel!
    //取值关键字
    open var valueKey: String = ""
    
    open var font: UIFont {
        //文本字体
        set {
            nameLabel.font = newValue
        }
        get {
            return nameLabel.font
        }
    }
    
    open var textColor: UIColor {
        //文本颜色
        set {
            nameLabel.textColor = newValue
        }
        get {
            return nameLabel.textColor
        }
    }
    
    open var badge: Int {
        //当前右上角标
        set {
            //是否为空？
            if nil == badgeLabel {
                badgeView()
            }
            //显示/隐藏？
            badgeLabel.isHidden = newValue <= 0
            //值
            badgeLabel.text = "\(newValue)"
        }
        get {
            //是否为空？
            if nil != badgeLabel {
                let tempVal = Int(badgeLabel.text ?? "0")!
                return tempVal < 0 ? 0 : tempVal
            }
            return 0
        }
    }
    
    open func loadCustomView(with text: String, imgName: String, rate: CGFloat = 0.3) -> Void {
        
        let size = self.frame.size
        //是否为0？
        if size.width <= 0.1 || size.height <= 0.1 {
            return
        }
        //文本高度、图片大小
        let hLabel: CGFloat = 24.0, whImage = rate * min(size.height, size.width)
        //图片
        tagImageView.frame = CGRect(x: 0.5 * (size.width - whImage), y: 0.5 * (size.height - whImage - hLabel) + 4.0,
                                    width: whImage, height: whImage)
        tagImageView.image = UIImage(named: imgName)
        //文本
        nameLabel.frame = CGRect(x: 0.0, y: tagImageView.frame.maxY, width: size.width, height: hLabel)
        nameLabel.textAlignment = .center
        nameLabel.text = text
        //添加
        self.addSubview(tagImageView)
        self.addSubview(nameLabel)
        //属性
        self.backgroundColor = UIColor.white
    }
    
    private func badgeView() -> Void {
        
        //是否为空？
        if nil != badgeLabel {
            return
        }
        //宽度
        let wLabel: CGFloat = 22.0
        //创建
        badgeLabel = UILabel(frame: CGRect(x: tagImageView.frame.maxX - 0.5 * wLabel, y: tagImageView.frame.origin.y - 3.0,
                                           width: wLabel, height: 14.0))
        badgeLabel.backgroundColor = UIColor.red
        badgeLabel.font = UIFont.systemFont(ofSize: 11.0)
        badgeLabel.textAlignment = .center
        badgeLabel.textColor = UIColor.white
        badgeLabel.clipsToBounds = true
        badgeLabel.layer.cornerRadius = 0.5 * badgeLabel.frame.size.height
        //添加
        self.addSubview(badgeLabel)
    }
}

// MARK: -

class UIHfhDRefreshView: UIView {
    
    //箭头
    private let imageView = UIImageView()
    //文本、时间
    private let (statusLabel, timeLabel) = (UILabel(), UILabel())
    //当前Scroll对象
    private var dragScrollView: UIScrollView!
    //offset的KVO标志
    private var offsetContext: Int = 0x1
    //1.是否可以刷新？2.是否已经在进行刷新？
    private(set) var (canRefreshing, isRequesting) = (false, false)
    //背景
    private let bgView = UIView()
    
    //闭包
    typealias ReturnClosure = (_ refreshView: UIHfhDRefreshView, _ isRrefresh: Bool) -> Void
    //回调
    private var returnClosure: ReturnClosure?
    
    open var isBorder: Bool {
        
        //是否添加边框？
        set {
            if true == newValue {
                bgView.layer.borderWidth = NSHfhVar.whSeparator
                bgView.layer.borderColor = NSHfhFunc.colorHex(intVal: NSHfhVar.eeColor).cgColor
            }
            else {
                bgView.layer.borderWidth = 0.0
            }
        }
        get {
            return bgView.layer.borderWidth > 0.0 ? true : false
        }
    }
    
    open var startResize: CGSize {
        //修改RECT值
        set {
            var rect1 = self.frame, rect2 = bgView.frame
            rect1.size.width = newValue.width
            rect2.size.width = newValue.width
            self.frame = rect1
            bgView.frame = rect2
        }
        get {
            return self.frame.size
        }
    }
    
    open func loadCustomView(in scrollView: UIScrollView, with closure: @escaping ReturnClosure) -> Void {
        
        //当前size值
        let size = self.frame.size
        //初始化
        loadViews(with: size)
        //保存
        dragScrollView = scrollView
        //添加KVO
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &offsetContext)
        scrollView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        //添加
        scrollView.addSubview(self)
        //回调
        returnClosure = closure
    }
    
    open func reset() -> Void {
        
        //最后的刷新时间
        timeLabel.text = "最后刷新时间：" + lastUpdateDate()
        //请求标志
        isRequesting = false
        //可以刷新标志
        canRefreshing = false
    }
    
    private func loadViews(with size: CGSize) -> Void {
        
        //文本高度、箭头大小
        let hLabel: CGFloat = 24.0, whImg = 0.7 * size.height
        //y值
        let yLabel = 0.5 * (size.height - 2.0 * hLabel)
        //背景
        bgView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        bgView.backgroundColor = UIColor.white
        //箭头
        imageView.frame = CGRect(x: 0.08 * size.width, y: 0.5 * (size.height - whImg), width: whImg, height: whImg)
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 1
        imageView.image = UIImage(named: "refresh_arrow")
        //状态
        statusLabel.frame = CGRect(x: 0.0, y: yLabel, width: size.width, height: hLabel)
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        //时间
        timeLabel.frame = CGRect(x: 0.0, y: yLabel + hLabel, width: size.width, height: hLabel)
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 12.0)
        timeLabel.text = lastUpdateDate()
        //添加
        self.addSubview(bgView)
        self.addSubview(imageView)
        self.addSubview(statusLabel)
        self.addSubview(timeLabel)
        //背景颜色
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
    }
    
    private func lastUpdateDate() -> String {
        
        //日期格式
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //返回
        return dateFormatter.string(from: Date())
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //是否为空？
        guard let tempContext = context else {
            //RECT值
            var rect1 = self.frame, rect2 = bgView.frame
            if dragScrollView.frame.size.height > dragScrollView.contentSize.height {
                rect2.origin.y = 0.0
                rect1.origin.y = dragScrollView.frame.size.height
            }
            else {
                rect2.origin.y = -NSHfhVar.whSeparator
                rect1.origin.y = dragScrollView.contentSize.height
            }
            //修改
            self.frame = rect1
            return bgView.frame = rect2
        }
        //是不否为offset标志？
        if tempContext == &offsetContext {
            //处理类型
            dragScrollView.isDragging == true ? offsetUpdated(to: dragScrollView) : offsetFinished(to: dragScrollView)
        }
    }
    
    private func offsetFinished(to scrollView: UIScrollView) -> Void {
        
        //是否可以刷新的标志
        if false == canRefreshing || true == isRequesting {
            return
        }
        //请求标志
        isRequesting = true
        //回调是否为空？
        if let tempReturnClosure = returnClosure {
            tempReturnClosure(self, true)
        }
    }
    
    private func offsetUpdated(to scrollView: UIScrollView) {
        
        //是否正在刷新？
        if true == isRequesting {
            return
        }
        //可以刷新的标志
        canRefreshing = false
        
        //content的高度是是于小于View的高度？
        let tempVal = dragScrollView.contentOffset.y - (dragScrollView.contentSize.height < dragScrollView.frame.size.height ?
            0.0 : (dragScrollView.contentSize.height - dragScrollView.frame.size.height))
        //是否大于0？
        if tempVal < 0.0 {
            return
        }
        //开始上拉
        if tempVal < self.frame.size.height {
            //如果为1，才进行处理
            if imageView.tag > 0 {
                //旋转
                UIView.animate(withDuration: 0.18) {
                    self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 180.0)
                }
                self.imageView.tag = 0
                //文本状态
                statusLabel.text = "上拉刷新"
            }
        }
        else {
            //如果为1，不进行处理
            if imageView.tag < 1 {
                //旋转
                UIView.animate(withDuration: 0.18) {
                    self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                }
                self.imageView.tag = 1
                //文本状态
                statusLabel.text = "松开刷新"
            }
            //可以刷新的标志
            canRefreshing = true
        }
    }
}

// MARK: -

class UIHfhProgressView: UIView {
    
    //进度视图
    private let progressView = UIView()
    //进度值
    open var maxNumber: CGFloat = 1.0
    
    override var frame: CGRect {
        
        didSet {
            //当前size值
            let size = self.frame.size
            //是否为0？
            if size.width <= 0.1 || size.height <= 0.1 {
                return
            }
            //修改进度条RECT值
            var rect = progressView.frame
            rect.size.height = size.height
            //修改
            progressView.frame = rect
        }
    }
    
    open var backgroundTintColor: UIColor {
        //背景颜色
        set {
            self.backgroundColor = newValue
        }
        get {
            return self.backgroundColor ?? UIColor.red
        }
    }
    
    open var trackTintColor: UIColor {
        //进度颜色
        set {
            progressView.backgroundColor = newValue
        }
        get {
            return self.backgroundColor ?? UIColor.blue
        }
    }
    
    open var isCornerRadius: Bool {
        //是否为圆角？
        set {
            //圆角值
            let tempVal = 0.5 * self.frame.size.height
            //设置
            self.layer.cornerRadius = tempVal
            progressView.layer.cornerRadius = tempVal
        }
        get {
            return self.layer.cornerRadius > 0
        }
    }
    
    open func setProgress(_ progress: CGFloat, animated: Bool = true) -> Void {
        
        //当前size值
        let size = self.frame.size
        //修改rect值
        let rect = CGRect(x: 0.0, y: 0.0, width: (progress *  size.width) / maxNumber, height: size.height)
        //动画？
        if true == animated {
            //动画
            UIView.animate(withDuration: 0.8/*整个总时长*/ * Double(progress) / Double(maxNumber), animations: {
                self.progressView.frame = rect
            })
        }
        else {
            progressView.frame = rect
        }
        //添加
        self.addSubview(progressView)
    }
}

// MARK: -

class UIHfhZeroView: UIView {
    
    //图片
    private let imageView = UIImageView()
    //文本
    private let markLabel = UILabel()
    //比例
    private var currRatio: CGFloat = 0.5, currImage: String = ""
    
    //闭包
    typealias ReturnClosure = (_ zeroView: UIHfhZeroView) -> Void
    //回调
    private var returnClosure: ReturnClosure?
    
    open var ratio: CGFloat {
        //图片比例大小
        set {
            currRatio = newValue
            //RECT值
            let tempVal = rects(with: currImage)
            //修改
            markLabel.frame = tempVal.mark
            imageView.frame = tempVal.img
        }
        get {
            return currRatio
        }
    }
    
    open var text: String {
        //提示图片
        set {
            markLabel.text = newValue
        }
        get {
            return markLabel.text ?? ""
        }
    }
    
    open var textColor: UIColor {
        //文本颜色
        set {
            markLabel.textColor = newValue
        }
        get {
            return markLabel.textColor
        }
    }
    
    open var startResize: CGSize {
        //修改RECT值
        set {
            var rect = self.frame
            rect.origin.x = 0.5 * (newValue.width - rect.size.width)
            rect.origin.y = 0.5 * (newValue.height - rect.size.height)
            self.frame = rect
        }
        get {
            return self.frame.size
        }
    }
    
    open func loadCustomView(_ img: String, text: String, with closure: @escaping ReturnClosure) -> Void {
        
        //RECT值
        let tempVal = rects(with: img)
        //RECT值
        imageView.frame = tempVal.img
        imageView.isUserInteractionEnabled = true
        imageView.image = tempVal.objImg
        //文本
        markLabel.frame = tempVal.mark
        markLabel.font = UIFont.systemFont(ofSize: 14.0)
        markLabel.textAlignment = .center
        markLabel.textColor = UIColor(red: 165.0 / 255.0, green: 179.0 / 255.0, blue: 191.0 / 255.0, alpha: 1.0)
        markLabel.text = text
        markLabel.isUserInteractionEnabled = true
        //保存
        returnClosure = closure
        currImage = img
        //添加
        self.addSubview(imageView)
        self.addSubview(markLabel)
        //添加手势
        let imgRecognizer = UITapGestureRecognizer(target: self, action: #selector(retryRecognizer(_:)))
        let markRecognizer = UITapGestureRecognizer(target: self, action: #selector(retryRecognizer(_:)))
        imageView.addGestureRecognizer(imgRecognizer)
        markLabel.addGestureRecognizer(markRecognizer)
    }
    
    @objc private func retryRecognizer(_ sender: UITapGestureRecognizer) -> Void {
        
        //回调是否为空？
        if let tempReturnClosure = returnClosure {
            tempReturnClosure(self)
        }
    }
    
    private func rects(with image: String) -> (img: CGRect, mark: CGRect, objImg: UIImage?) {
        
        //当前size值
        let size = self.frame.size
        //图片大小
        var wImg: CGFloat = 0.0, hImg: CGFloat = 0.0
        let img = UIImage(named: image)
        //size值哪个更小？
        if size.width < size.height {
            wImg = currRatio * size.width
            //是否为空？
            if let tempImg = img {
                hImg = tempImg.size.height * wImg / tempImg.size.width
            }
            else {
                hImg = wImg
            }
        }
        else {
            hImg = currRatio * size.height
            //是否为空？
            if let tempImg = img {
                wImg = tempImg.size.width * hImg / tempImg.size.height
            }
            else {
                wImg = hImg
            }
        }
        //文本高度
        let hLabel: CGFloat = 34.0
        //RECT值
        let rect1 = CGRect(x: 0.5 * (size.width - wImg), y: 0.5 * (size.height - hImg - hLabel), width: wImg, height: hImg)
        let rect2 = CGRect(x: 0.0, y: rect1.maxY, width: size.width, height: hLabel)
        //返回
        return (rect1, rect2, img)
    }
}

// MARK: -

class UIHfhPRefreshView: UIView {
    
    //箭头
    private let imageView = UIImageView()
    //文本、时间
    private let (statusLabel, timeLabel) = (UILabel(), UILabel())
    //当前Scroll对象
    private var dragScrollView: UIScrollView!
    //offset的KVO标志
    private var offsetContext: Int = 0x1
    //1.是否可以刷新？2.是否已经在进行刷新？
    private(set) var (canRefreshing, isRequesting) = (false, false)
    //背景
    private let bgView = UIView()
    
    //闭包
    typealias ReturnClosure = (_ refreshView: UIHfhPRefreshView, _ isRrefresh: Bool) -> Void
    //回调
    private var returnClosure: ReturnClosure?
    
    open var isBorder: Bool {
        
        //是否添加边框？
        set {
            if true == newValue {
                bgView.layer.borderWidth = NSHfhVar.whSeparator
                bgView.layer.borderColor = NSHfhFunc.colorHex(intVal: NSHfhVar.eeColor).cgColor
            }
            else {
                bgView.layer.borderWidth = 0.0
            }
        }
        get {
            return bgView.layer.borderWidth > 0.0 ? true : false
        }
    }
    
    open var startResize: CGSize {
        //修改RECT值
        set {
            var rect1 = self.frame, rect2 = bgView.frame
            rect1.size.width = newValue.width
            rect2.size.width = newValue.width
            self.frame = rect1
            bgView.frame = rect2
        }
        get {
            return self.frame.size
        }
    }
    
    open func loadCustomView(in scrollView: UIScrollView, with closure: @escaping ReturnClosure) -> Void {
        
        //当前size值
        let size = self.frame.size
        //初始化
        loadViews(with: size)
        //添加KVO
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &offsetContext)
        //添加
        scrollView.addSubview(self)
        //保存
        dragScrollView = scrollView
        returnClosure = closure
    }
    
    open func reset() -> Void {
        
        //最后的刷新时间
        timeLabel.text = "最后刷新时间：" + lastUpdateDate()
        //请求标志
        isRequesting = false
        //可以刷新标志
        canRefreshing = false
    }
    
    private func loadViews(with size: CGSize) -> Void {
        
        //文本高度、箭头大小
        let hLabel: CGFloat = 24.0, whImg = 0.7 * size.height
        //y值
        let yLabel = 0.5 * (size.height - 2.0 * hLabel)
        //背景
        bgView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        bgView.backgroundColor = UIColor.white
        //箭头
        imageView.frame = CGRect(x: 0.08 * size.width, y: 0.5 * (size.height - whImg), width: whImg, height: whImg)
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 0
        imageView.image = UIImage(named: "refresh_arrow")
        //状态
        statusLabel.frame = CGRect(x: 0.0, y: yLabel, width: size.width, height: hLabel)
        statusLabel.textAlignment = .center
        statusLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
        //时间
        timeLabel.frame = CGRect(x: 0.0, y: yLabel + hLabel, width: size.width, height: hLabel)
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 12.0)
        timeLabel.text = lastUpdateDate()
        //添加
        self.addSubview(bgView)
        self.addSubview(imageView)
        self.addSubview(statusLabel)
        self.addSubview(timeLabel)
        //背景颜色
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
    }
    
    private func lastUpdateDate() -> String {
        
        //日期格式
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //返回
        return dateFormatter.string(from: Date())
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        //是否为空？
        guard let tempContext = context else {
            return
        }
        //是不否为offset标志？
        if tempContext == &offsetContext {
            //处理类型
            true == dragScrollView.isDragging ? offsetUpdated(to: dragScrollView) : offsetFinished(to: dragScrollView)
        }
    }
    
    private func offsetFinished(to scrollView: UIScrollView) -> Void {
        
        //是否可以刷新的标志
        if false == canRefreshing || true == isRequesting {
            return
        }
        //请求标志
        isRequesting = true
        //回调是否为空？
        if let tempReturnClosure = returnClosure {
            tempReturnClosure(self, true)
        }
    }
    
    private func offsetUpdated(to scrollView: UIScrollView) {
        
        //是否正在刷新？
        if true == isRequesting {
            return
        }
        //可以刷新的标志
        canRefreshing = false
        //是否大于0？
        if dragScrollView.contentOffset.y >= 0.0 {
            return
        }
        //是否可刷新？
        if dragScrollView.contentOffset.y > -self.frame.size.height {
            //旋转
            UIView.animate(withDuration: 0.25) {
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            }
            //文本状态
            statusLabel.text = "下拉刷新"
        }
        else {
            //旋转
            UIView.animate(withDuration: 0.25) {
                self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 180.0)
            }
            //文本状态
            statusLabel.text = "松开刷新"
            //可以刷新的标志
            canRefreshing = true
        }
    }
}

// MARK: -

class UIHfhCodeView: UIView {
    
    //随机线
    private var randomLine = Array<CAShapeLayer>()
    //验证码
    private(set) var code: String = ""
    
    open func reset(_ bitNumber: Int = 4) -> Void {
        
        //先删除之前对象
        clear()
        //随机对象
        let tempArray = ["0","1","2","3","4","5","6","7","8","9", "A","B","C","D","E","F","G","H","I","J",
                         "K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
                         "a","b","c","d","e","f",
                         "g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
        //单位宽度
        let unitWidth = self.frame.size.width / CGFloat(bitNumber)
        //最小字体
        let minFont = (Int)(self.frame.size.height / 3.0), maxFont = minFont + 5
        //随机总数
        let tempCount = tempArray.count
        for i in 0 ..< bitNumber {
            //显示
            let label = UILabel(frame: CGRect(x: CGFloat(i) * unitWidth, y: 0.0, width: 0.0, height: 0.0))
            label.text = tempArray[(Int)(arc4random()) % tempCount]
            label.textAlignment = .center
            label.textColor = randomColor()
            label.font = UIFont.systemFont(ofSize: CGFloat(minFont) + CGFloat((Int)(arc4random()) % maxFont))
            label.clipsToBounds = false
            label.sizeToFit()
            //旋转角度
            label.transform = CGAffineTransform(rotationAngle: randomRotate())
            //添加
            self.addSubview(label)
            //修改RECT值
            resizeNumber(label, unitWidth: unitWidth)
            //值
            code += "\(label.text!)"
        }
        //背景颜色
        self.backgroundColor = randomColor()
        self.clipsToBounds = true
        self.layer.cornerRadius = 3.0
        //添加手势
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resetRecognizer(_:))))
        //线条
        lineLayers()
    }
    
    @objc func resetRecognizer(_ sender: UITapGestureRecognizer) -> Void {
        
        //重新生成
        reset()
    }
    
    private func clear() -> Void {
        
        //删除随机线条
        for layer in randomLine {
            layer.removeFromSuperlayer()
        }
        //删除其他所有视图
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        code = ""
        randomLine.removeAll()
    }
    
    private func lineLayers() -> Void {
        
        //线条数
        let lineCount = 3 + arc4random() % 7
        //高宽最大值
        let (widthMax, heigthMax) = ((UInt32)(self.frame.size.width), (UInt32)(self.frame.size.height))
        for _ in 0 ..< lineCount {
            //路径
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: (Int)(arc4random() % widthMax), y: (Int)(arc4random() % heigthMax)))
            bezierPath.addLine(to: CGPoint(x: (Int)(arc4random() % widthMax), y: (Int)(arc4random() % heigthMax)))
            //layer对象
            let layer = CAShapeLayer()
            layer.lineWidth = 0.5
            layer.strokeColor = randomColor().cgColor
            layer.path = bezierPath.cgPath
            layer.strokeEnd = 1.0
            //添加
            self.layer.addSublayer(layer)
            randomLine.append(layer)
        }
    }
    
    private func randomColor() -> UIColor {
        
        //当前随机颜色
        let tempColor = UIColor(red: (CGFloat)(arc4random() % 256) / 255.0, green: (CGFloat)(arc4random() % 256) / 255.0,
                                blue: (CGFloat)(arc4random() % 256) / 255.0, alpha: 1.0)
        //返回
        return tempColor
    }
    
    private func resizeNumber(_ label: UILabel, unitWidth: CGFloat) -> Void {
        
        //RECT值
        var rect = label.frame
        //修改y值
        let yVal = CGFloat(arc4random()).truncatingRemainder(dividingBy: self.frame.size.height)
        //y的最大值
        let tempVal = self.frame.size.height - rect.size.height
        //修改
        rect.size.width += 3.0
        rect.origin.y = yVal < tempVal ? yVal : tempVal
        rect.origin.x += 0.5 * (unitWidth - rect.size.width)
        label.frame = rect
    }
    
    private func randomRotate() -> CGFloat {
        
        //角度规定0~45度之间，即0~PI/4之间
        let tempRotate = Double(arc4random()).truncatingRemainder(dividingBy: 0.2)
        //正负值
        let tempVal = arc4random() % 2 > 0 ? tempRotate : ((-1.0) * tempRotate)
        //返回
        return CGFloat(tempVal)
    }
}

// MARK: -

class UIHfh5StarsView: UIView {
    
    //间距值
    private let START_SPACE_VALUE: CGFloat = 3.0
    //当前值，注：1星1分，小数点后面保留1位
    private var currScore: CGFloat = 0.0
    //星数
    private var currStarCount: Int = 0
    //类型
    private var currType: UIHfh5StarsType = .custom
    //高亮星背景
    private var highlightedView: UIView!
    
    //闭包
    typealias ReturnClosure = (_ starsView: UIHfh5StarsView, _ scores: CGFloat) -> Void
    //回调
    private var returnClosure: ReturnClosure?
    
    enum UIHfh5StarsType: Int {
        //选择类型依次为：可选择一半、全部、随意
        case half
        case all
        case custom
    }
    
    open var scores: CGFloat {
        //设置值
        set {
            //是否小于0？
            let tempVal = newValue < 0.0 ? 0.0 : newValue
            //是否大于最大值？
            currScore = tempVal > CGFloat(currStarCount) ? CGFloat(currStarCount) : tempVal
            //显示值
            showStar()
        }
        get {
            return currScore
        }
    }
    
    open func loadCustomView(_ type: UIHfh5StarsType = .custom, count: Int = 5, with closure: @escaping ReturnClosure) -> Void {
        
        //当前size值
        let size = self.frame.size
        //高亮星星背景
        highlightedView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: size.height))
        highlightedView.clipsToBounds = true
        //单位宽度
        let wPer: CGFloat = size.width / CGFloat(count)
        let whImg: CGFloat = 0.7 * wPer
        //x、y值
        let xVal: CGFloat = 0.5 * (wPer - whImg), yVal: CGFloat = 0.5 * (size.height - whImg)
        for i in 0 ..< count {
            //灰
            let normalImgView = UIImageView(frame: CGRect(x: CGFloat(i) * wPer + xVal, y: yVal, width: whImg,
                                                          height: whImg))
            normalImgView.image = UIImage(named: "5stars_normal")
            //亮
            let highlightedImgView = UIImageView(frame: normalImgView.frame)
            highlightedImgView.image = UIImage(named: "5stars_highlighted")
            //添加
            self.addSubview(normalImgView)
            highlightedView.addSubview(highlightedImgView)
        }
        //添加
        self.addSubview(highlightedView)
        //背景颜色
        self.backgroundColor = UIColor.white
        //添加手势
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(willChangRecognizer(_:))))
        //保存
        currStarCount = count
        currType = type
        returnClosure = closure
    }
    
    @objc private func willChangRecognizer(_ sender: UITapGestureRecognizer) -> Void {
        
        //点击pt
        let pt = sender.location(in: self)
        //计算值
        currScore = pt.x * CGFloat(currStarCount) / self.frame.size.width
        //更新星值
        showStar()
        //回调是否为空？
        if let tempReturnClosure = returnClosure {
            tempReturnClosure(self, currScore)
        }
    }
    
    private func showStar() -> Void {
        
        //单位宽度
        let wPer: CGFloat = self.frame.size.width / CGFloat(currStarCount)
        //RECT值
        var rect = highlightedView.frame
        //类型
        switch currType {
        case .all:
            rect.size.width = ceil(currScore) * wPer
        case .half:
            let minusVal = CGFloat(currScore) - CGFloat(Int(currScore))
            var tempVal: CGFloat = 0.0
            if minusVal > 0.5 {
                tempVal = 1.0
            }
            else if minusVal > 0.0 {
                tempVal = 0.5
            }
            rect.size.width = (CGFloat(Int(currScore)) + tempVal) * wPer
        default:
            rect.size.width = currScore * wPer
        }
        //RECT值
        highlightedView.frame = rect
    }
}

// MARK: -

class UIHfhTextView: UITextView {
    
    //placehlder
    private var placeholderLabel: UILabel!
    
    override var frame: CGRect {
        //添加placeholder
        didSet {
            if nil != placeholderLabel {
                return
            }
            //添加事件
            NotificationCenter.default.addObserver(self, selector: #selector(valueChangedNoti(_:)),
                                                   name: NSNotification.Name.UITextViewTextDidChange, object: nil)
            //边距参考
            let lrVal: CGFloat = 6.0
            //创建
            placeholderLabel = UILabel(frame: CGRect(x: lrVal, y: 5.0, width: self.frame.size.width - 2.0 * lrVal, height: 22.0))
            placeholderLabel.textColor = UIColor.gray
            //添加
            self.addSubview(placeholderLabel)
        }
    }
    
    override var font: UIFont? {
        //修改字体
        didSet {
            placeholderLabel.font = self.font
        }
    }
    
    open var placeholder: String? {
        //设置placehloder
        set {
            placeholderLabel.text = newValue
        }
        get {
            return placeholderLabel.text
        }
    }
    
    open var placeholderFont: UIFont? {
        //placeholder颜色
        set {
            placeholderLabel.font = newValue
        }
        get {
            return placeholderLabel.font
        }
    }
    
    open var placeholderColor: UIColor? {
        //设定颜色
        set {
            placeholderLabel.textColor = newValue
        }
        get {
            return placeholderLabel.textColor
        }
    }
    
    @objc private func valueChangedNoti(_ noti: Notification) -> Void {
        
        //长度是否为0？
        placeholderLabel.isHidden = self.text.count > 0
    }
}

// MARK: -

class UIHfhSwitch: UIView {
    
    //保存标志
    open var uniqueKey: String = ""
    //颜色
    private var currSliderColor = UIColor.lightGray
    private var currCircleColor = UIColor.gray, currCircleSelectedColor = UIColor.blue
    //是否选中？
    private var currOn: Bool = false
    //圆圈
    private var circleView: UIView!
    //滑杆
    private var sliderView: UIView!
    
    //闭包
    typealias ReturnClosure = (_ hfhSwitch: UIHfhSwitch, _ on: Bool) -> Void
    //回调
    private var returnClosure: ReturnClosure?
    
    open var sliderColor: UIColor {
        //滑杆颜色
        set {
            currSliderColor = newValue
            //是否不为空？
            if nil != sliderView {
                sliderView.backgroundColor = newValue
            }
        }
        get {
            return currSliderColor
        }
    }
    
    open var circleColor: UIColor {
        //圆圈颜色
        set {
            currCircleColor = newValue
            //是否不为空？
            if nil != sliderView {
                circleView.backgroundColor = newValue
            }
        }
        get {
            return currCircleColor
        }
    }
    
    open var circleSelectedColor: UIColor {
        //圆圈选中颜色
        set {
            currCircleSelectedColor = newValue
            //是否不为空？
            if nil != sliderView {
                //选中状态
                updateOn()
            }
        }
        get {
            return currCircleSelectedColor
        }
    }
    
    open var isOn: Bool {
        //是否选中？
        set {
            currOn = newValue
            //是否不为空？
            if nil != sliderView {
                //选中状态
                updateOn()
            }
        }
        get {
            return currOn
        }
    }
    
    open func loadCustomView(with closure: @escaping ReturnClosure) -> Void {
        
        //当前size值
        let size = self.frame.size
        //高度
        let hSlider: CGFloat = 0.4 * size.height, whCircle: CGFloat = 0.8 * min(size.height, size.width)
        //背景条
        sliderView = UIView(frame: CGRect(x: 0.0, y: 0.5 * (size.height - hSlider), width: size.width, height: hSlider))
        sliderView.backgroundColor = currSliderColor
        sliderView.clipsToBounds = true
        sliderView.layer.cornerRadius = 0.5 * hSlider
        //圆圈
        circleView = UIView(frame: CGRect(x: 0.0, y: 0.5 * (size.height - whCircle), width: whCircle, height: whCircle))
        circleView.backgroundColor = currCircleColor
        circleView.clipsToBounds = true
        circleView.layer.cornerRadius = 0.5 * whCircle
        //保存
        returnClosure = closure
        //添加
        self.addSubview(sliderView)
        self.addSubview(circleView)
        //添加手势
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(changeRecognizer(_:)))
        self.addGestureRecognizer(recognizer)
    }
    
    private func updateOn() -> Void {
        
        //RECT值
        var rect = circleView.frame
        //是否选中？
        if true == currOn {
            rect.origin.x = self.frame.size.width - rect.size.width
            circleView.backgroundColor = currCircleSelectedColor
        }
        else {
            rect.origin.x = 0.0
            circleView.backgroundColor = currCircleColor
        }
        
        //动画方式修改
        UIView.animate(withDuration: 0.25) {
            self.circleView.frame = rect
        }
    }
    
    @objc private func changeRecognizer(_ sener: UITapGestureRecognizer) -> Void {
        
        //修改状态
        self.isOn = !currOn
        //回调是否为空？
        if let tempReturnClosure = returnClosure {
            tempReturnClosure(self, currOn)
        }
    }
}

// MARK: -

class UIHfhDateView: UIView, UIScrollViewDelegate {
    
    //scrollView对象
    private var scrollView: UIScrollView!
    //指引
    private var thumbView: UIView!
    //labels对象
    private var ymsArray = Array<UILabel>()
    //日期
    private var datesArray = Array<String>()
    //当前选中索引
    private var currIndex: Int = -1
    
    //闭包
    typealias ReturnClosure = (_ dateView: UIHfhDateView, _ date: String) -> Void
    //回调
    private var returnClosure: ReturnClosure?
    
    open var date: String {
        
        //返回当前日期
        if currIndex > -1 {
            return datesArray[currIndex]
        }
        return ""
    }
    
    open func loadCustomView(months: Int, with closure: @escaping ReturnClosure) -> Void {
        
        //当前size值
        let size = self.frame.size
        //参数值
        let wPer: CGFloat = widthUnit(in: size, days: months)
        //scrollView
        scrollView = UIScrollView(frame: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: CGFloat(months) * wPer, height: size.height)
        //天数
        monthsView(in: size, months: months, unit: wPer)
        //指引高宽度
        let hThumb: CGFloat = 2.0, wThumb: CGFloat = 0.8 * wPer
        //指引
        thumbView = UIView(frame: CGRect(x: CGFloat(months - 1) * wPer + 0.5 * (wPer - wThumb), y: size.height - hThumb,
                                         width: wThumb, height: hThumb))
        thumbView.backgroundColor = NSHfhFunc.colorHex(intVal: NSHfhVar.themeColor)
        //保存
        returnClosure = closure
        //添加
        scrollView.addSubview(thumbView)
        self.addSubview(scrollView)
        //背景颜色
        self.backgroundColor = UIColor.white
        //选中最后一天，即今天
        scrollView.scrollRectToVisible(ymsArray.last!.frame, animated: false)
        selecteChanged(ymsArray.count - 1)
    }
    
    private func selecteChanged(_ index: Int) -> Void {
        
        //是否已有选中？
        if currIndex > -1 {
            let dayLabel = ymsArray[currIndex]
            dayLabel.textColor = NSHfhFunc.colorHex(intVal: NSHfhVar.txt99Color)
        }
        //选中
        let dayLabel = ymsArray[index]
        dayLabel.textColor = thumbView.backgroundColor
        //移动
        var rect = thumbView.frame
        rect.origin.x = dayLabel.frame.origin.x + 0.5 * (dayLabel.frame.size.width - rect.size.width)
        UIView.animate(withDuration: 0.35) {
            self.thumbView.frame = rect
        }
        //保存索引
        currIndex = index
    }
    
    private func widthUnit(in size: CGSize, days: Int) -> CGFloat {
        
        //最小值
        let minVal: CGFloat = 92.0
        var tempCount: CGFloat = 4.0 /*最小为4个，最大值暂时不限*/
        var resultVal: CGFloat = minVal
        while true {
            let wPer: CGFloat = size.width / tempCount
            if wPer <= minVal {
                break
            }
            resultVal = wPer
            tempCount += 1.0
        }
        //天数是小于计算后的数（如：一页显示5个，但日期只显示3个，则必须按3来平分宽度）
        if CGFloat(days) < tempCount {
            resultVal = size.width / CGFloat(days)
        }
        //返回
        return resultVal
    }
    
    private func monthsView(in size: CGSize, months: Int, unit width: CGFloat) -> Void {
        
        //当前年月
        let objCalendar = NSCalendar(calendarIdentifier: .gregorian)!
        let components = objCalendar.components([.year, .month], from: Date())
        //年月
        var yearVal = components.year!, monthVal = components.month!
        //创建
        for i in 0 ..< months {
            let ymLabel = label(with: CGRect(x: CGFloat(i) * width, y: 0.0, width: width, height: size.height),
                                font: 14.0, tag: i)
            //计算日期
            monthVal -= 1
            if monthVal < 1 {
                yearVal -= 1
                monthVal = 12
            }
            //年月
            ymLabel.text = "\(yearVal)年\(monthVal)月"
            //保存
            datesArray.append("\(yearVal)-\(monthVal)")
            ymsArray.append(ymLabel)
            //添加手势
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(selectedRecognizer(_:)))
            ymLabel.addGestureRecognizer(recognizer)
        }
    }
    
    @objc private func selectedRecognizer(_ sender: UITapGestureRecognizer) -> Void {
        
        //是否为空？
        guard let tempLabel = sender.view as? UILabel else {
            return
        }
        //修改选中状态
        selecteChanged(tempLabel.tag)
        //回调是否为空？
        if let tempReturnClosure = returnClosure {
            tempReturnClosure(self, datesArray[currIndex])
        }
    }
    
    private func label(with frame: CGRect, font: CGFloat, tag: Int) -> UILabel {
        
        let tempLabel = UILabel(frame: frame)
        tempLabel.textColor = NSHfhFunc.colorHex(intVal: NSHfhVar.txt99Color)
        tempLabel.clipsToBounds = true
        tempLabel.font = UIFont.systemFont(ofSize: font)
        tempLabel.textAlignment = .center
        tempLabel.isUserInteractionEnabled = true
        tempLabel.tag = tag
        //添加
        scrollView.addSubview(tempLabel)
        //返回
        return tempLabel
    }
}
