//
//  NSHfhFunc.swift
//  NSHfhFunc
//
//  Created by HeFahu on 2018/5/3.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit

class NSHfhFunc: NSObject {
    
    class func viewControllerFromName(_ fileName: String) -> UIViewController? {
        
        //文件名称是否为空？
        if fileName.count > 0 {
            //工程路径
            if let tempPath = Bundle.main.infoDictionary!["CFBundleExecutable"] {
                //转换
                if let clsObject = NSClassFromString((tempPath as! String) + "." + fileName) {
                    //返回
                    return (clsObject as! UIViewController.Type).init()
                }
            }
        }
        //返回
        return nil
    }

    class func colorHex(intVal: Int, alpha: CGFloat = 1.0) -> UIColor {
        
        //16进制整型转换成颜色
        return UIColor(red: ((CGFloat)((intVal & 0xFF0000) >> 16)) / 255.0,
                       green: ((CGFloat)((intVal & 0xFF00) >> 8)) / 255.0, blue: ((CGFloat)(intVal & 0xFF)) / 255.0,
                       alpha: alpha)
    }
    
    class func saveData(_ data: Any, file: String) -> Bool {
        
        return NSKeyedArchiver.archiveRootObject(data, toFile: self.documentPath(with: file))
    }
    
    class func imageWithColor(_ color: UIColor) -> UIImage {
        
        //图片大小
        let rect = CGRect(x: 0.0, y: 0.0, width: 16.0, height: 16.0)
        //创建画布
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            //设定颜色
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
        //生成图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //是否为空？
        guard let tempImage = image else {
            return UIImage()
        }
        //拉伸值
        let tempVal = Int(rect.size.width) / 2
        //拉伸
        let newImage = tempImage.stretchableImage(withLeftCapWidth: tempVal, topCapHeight: tempVal)
        //返回
        return newImage
    }
    
    class func documentPath(with file: String) -> String {
        
        //document路径
        let pathArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if pathArray.count <= 0 {
            return ""
        }
        //文件路径
        let filePath = pathArray[0].appending("/\(file)")
        //返回
        return filePath
    }
    
    class func saveData2Document(_ data: Data, with file: String) -> Void {
        
        //document路径
        let pathArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if pathArray.count <= 0 {
            return
        }
        //文件路径
        let url = URL(fileURLWithPath: pathArray[0].appending("/\(file)"))
        //保存到doc目录下面
        try? data.write(to: url)
    }
    
    class func colorHex(strVal: String, alpha: CGFloat = 1.0) -> UIColor {
        
        //是否够位数？
        if strVal.count < 6 {
            return UIColor.black
        }
        //颜色转换
        let analyzeColor = { (colorVal: String) -> (nextColor: String, value: CGFloat) in
            //索引
            let index = colorVal.index(colorVal.startIndex, offsetBy: 2)
            //颜色值
            var colorNumber: UInt32 = 0
            //转换
            Scanner(string: String(colorVal[..<index])).scanHexInt32(&colorNumber)
            //返回
            return (String(colorVal[index...]), CGFloat(colorNumber) / 255.0)
        }
        //R
        let redColor = analyzeColor(strVal)
        //G
        let greenColor = analyzeColor(redColor.nextColor)
        //B
        let blueColor = analyzeColor(greenColor.nextColor)
        //返回
        return UIColor(red: redColor.value, green: greenColor.value, blue: blueColor.value, alpha: alpha)
    }
    
    class func strRandom(with length: Int = 10) -> String {
        
        //结果
        var resultVal: String = ""
        //1.大写字母(65-90)、2.小字字母(97-112)、3.数字（48-57）
        let upperCaseVal: UInt32 = 90 - 65, lowCaseVal: UInt32 = 112 - 97, numberVal: UInt32 = 57 - 48
        for _ in 1 ... length {
            let typeVal = arc4random() % 3
            switch typeVal {
            case 0:
                //大写字母
                resultVal += String(format: "%c", arc4random() % upperCaseVal + 66)
            case 1:
                //小写字母
                resultVal += String(format: "%c", arc4random() % lowCaseVal + 98)
            default:
                //字母
                resultVal += String(format: "%c", arc4random() % numberVal + 49)
            }
        }
        //返回
        return resultVal
    }
    
    class func stringDate(_ date: Date, with formatter: String) -> String {
        
        //设定时间格式
        let dateFormatter = DateFormatter();dateFormatter.dateFormat = formatter
        //返回
        return dateFormatter.string(from: date)
    }
    
    class func readData2Document(with file: String) -> Data? {
        
        //document路径
        let pathArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if pathArray.count <= 0 {
            return nil
        }
        //文件路径
        let filePath = pathArray[0].appending("/\(file)")
        //返回
        return try? Data(contentsOf: URL(fileURLWithPath: filePath))
    }
    
    class func attributeImage(_ img: String, with text: String, whImg: CGFloat, imgyOffset: CGFloat = -3.0) -> NSAttributedString {
        
        //标题中的tag图片
        let attachment = NSTextAttachment()
        attachment.bounds = CGRect(x: 0.0, y: imgyOffset, width: whImg, height: whImg)
        attachment.image = UIImage(named: img)
        //图片
        let tempVal = NSMutableAttributedString(attributedString: NSAttributedString(attachment: attachment))
        //添加名称
        tempVal.append(NSAttributedString(string: " " + text))
        //显示
        return tempVal
    }
}
