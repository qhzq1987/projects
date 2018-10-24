//
//  AboutUsViewController.swift
//  Thermometer
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

class AboutUsViewController: UIHfhBaseViewController {
    
    //应用名称、版本号
    private var appNameLabel: UILabel!, versionLabel: UILabel!
    //logo
    private var logoImageView: UIImageView!
    //简介
    private var briefLabel: UILabel!, companyLabel: UILabel!, copyrightLabel: UILabel!
    
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
        
        //RECT值
        var rect1 = appNameLabel.frame, rect2 = versionLabel.frame, rect3 = self.scrollView.frame
        var rect4 = logoImageView.frame, rect5 = briefLabel.frame
        var rect6 = companyLabel.frame, rect7 = copyrightLabel.frame
        rect1.size.width = size.width
        rect2.size.width = size.width
        rect3.size = size
        rect3.size.height = size.height - 0.0
        rect4.origin.x = 0.5 * (size.width - rect4.size.width)
        //计算简介
        let tempVal = sizeText(briefText(), in: size.width - 2.0 * rect5.origin.x)
        rect5.size = tempVal.size
        briefLabel.frame = rect5
        //公司和版权
        rect6.size.width = size.width
        rect6.origin.y = size.height - rect6.size.height - 30.0/*创建是设定值*/
        rect7.size.width = size.width
        rect7.origin.y = rect6.origin.y - rect7.size.height
        //修改
        appNameLabel.frame = rect1
        versionLabel.frame = rect2
        self.scrollView.frame = rect3
        logoImageView.frame = rect4
        companyLabel.frame = rect6
        copyrightLabel.frame = rect7
        //contentSize值
        self.scrollView.contentSize = CGSize(width: size.width, height: size.height + 0.5)
    }
    
    // MARK: - Custom Methods
    
    private func initViews() -> Void {
        
        //减去高度
        let hMinus: CGFloat = NSHfhVar.hStatusBar + NSHfhVar.hNaviBar
        //背景区域
        super.showScroll(with: CGRect(x: 0.0, y: 0.0, width: NSHfhVar.scWidth, height: NSHfhVar.scHeight - hMinus))
        //底部：copyright和单位名称
        _ = copyrightWithCompanyViews(in: scrollView)
        //边距参考
        let lrVal: CGFloat = 15.0
        //logo图片大小、图片y值
        let logoImage = UIImage(named: "system_logo")!
        //图片大小
        let yImg: CGFloat = 0.1 * max(NSHfhVar.scWidth, NSHfhVar.scHeight), wImg: CGFloat = 0.2 * min(NSHfhVar.scWidth, NSHfhVar.scHeight)
        let hImg: CGFloat = logoImage.size.height * wImg / logoImage.size.width
        //文本高度
        let hLabel: CGFloat = 16.0
        //logo
        logoImageView = UIImageView(frame: CGRect(x: 0.5 * (NSHfhVar.scWidth - wImg), y: yImg, width: wImg,
                                                  height: hImg))
        logoImageView.image = UIImage(named: "system_logo")
        //名称
        appNameLabel = label(with: CGRect(x: 0.0, y: logoImageView.frame.origin.y + wImg + hLabel, width: NSHfhVar.scWidth,
                                          height: 2.0 * hLabel), font: 20.0, textAlignment: .center)
        //版本号
        versionLabel = label(with: CGRect(x: 0.0, y: appNameLabel.frame.origin.y + appNameLabel.frame.size.height,
                                          width: NSHfhVar.scWidth, height: hLabel), font: 14.0, textAlignment: .center)
        //简介
        let tempVal = sizeText(briefText(), in: NSHfhVar.scWidth - 2.0 * lrVal)
        briefLabel = label(with: CGRect(origin: CGPoint(x: lrVal, y: versionLabel.frame.maxY + 2.0 * lrVal),
                                        size: tempVal.size), font: 15.0,
                                                             textAlignment: .left, textColor: NSHfhVar.txt66Color)
        briefLabel.attributedText = tempVal.attrText
        //添加
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(briefLabel)
        //名称、版本
        let infoData = Bundle.main.infoDictionary!
        appNameLabel.text = infoData["CFBundleDisplayName"] as? String
        versionLabel.text = infoData["CFBundleVersion"] as? String
    }
    
    private func copyrightWithCompanyViews(in view: UIView) -> CGFloat {
        
        //label
        let ccLabel = { (rect: CGRect, text: String, bgView: UIView) -> UILabel in
            //创建
            let label = UILabel(frame: rect)
            label.text = text
            label.font = UIFont.systemFont(ofSize: 11.0)
            label.textAlignment = .center
            label.textColor = NSHfhFunc.colorHex(intVal: NSHfhVar.txt99Color)
            //添加
            bgView.addSubview(label)
            //返回
            return label
        }
        let btVal: CGFloat = 10.0, hVal: CGFloat = 20.0
        //公司名称
        companyLabel = ccLabel(CGRect(x: 0.0, y: view.frame.size.height - btVal - hVal, width: view.frame.size.width,
                                      height: hVal), "江苏吉瑞达电子有限公司版权所有", view)
        //copyright
        copyrightLabel = ccLabel(CGRect(x: 0.0, y: companyLabel.frame.origin.y - hVal, width: view.frame.size.width,
                                        height: hVal), "Copyright © 2010-2018", view)
        //返回y值
        return copyrightLabel.frame.origin.y
    }
    
    private func briefText() -> String {
        
        let tempVal = "　　江苏吉瑞达电子有限公司是专门从事可靠性高精密医用传感器探头的生产企业，产品行销全世界。既有标准产品，也可根据客户要求定做。"
            + "年产能力超亿只，所有生产工艺都在本企业内控制，有10万级无尘车间，是美国FDA 注册企业。"
            + "\r\n"
            + "　　吉瑞达医检是我公司为推动医用监护无线化而开发的智能医疗检测监护产品，方便医护操作，改善监护设备周边环境。"
        //返回
        return tempVal
    }
    
    private func label(with frame: CGRect, font: CGFloat, textAlignment: NSTextAlignment, textColor: Int = 0) -> UILabel {
        
        //创建
        let tempLabel = UILabel(frame: frame)
        tempLabel.textColor = NSHfhFunc.colorHex(intVal: textColor)
        tempLabel.numberOfLines = 0
        tempLabel.font = UIFont.systemFont(ofSize: font)
        tempLabel.textAlignment = textAlignment
        //添加
        scrollView.addSubview(tempLabel)
        //返回
        return tempLabel
    }
    
    private func sizeText(_ text: String, in w: CGFloat) -> (size: CGSize, attrText: NSAttributedString) {
        
        //行高
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        //属性
        let attr = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0),
                    NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        //字符串
        let tempVal = NSAttributedString(string: text, attributes: attr)
        let tempSize = CGSize(width: w, height: CGFloat(Int.max))
        let rect = tempVal.boundingRect(with: tempSize, options: .usesLineFragmentOrigin, context: nil)
        //返回
        return (rect.size, tempVal)
    }
}
