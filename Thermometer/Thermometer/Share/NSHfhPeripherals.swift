//
//  NSHfhPeripherals.swift
//  NSHfhPeripherals
//
//  Created by HeFahu on 2018/5/15.
//  Copyright © 2018年 HeFahu. All rights reserved.
//

import UIKit
import CoreBluetooth

@objc enum NSHfhPeripheralsReturnType: Int {
    
    case error/*错误*/
    case reloadData/*刷新设备列表*/
    case notify/*订阅*/
    case noServies/*无服务特征值*/
    case connecting/*正在连接中*/
    case reset/*重置*/
    case unknow
}

// MARK: -

@objc protocol NSHfhPeripheralsDelegate: NSObjectProtocol {
    
    @objc optional func peripherals(_ type: NSHfhPeripheralsReturnType, message: String) -> Void
    
    @objc optional func peripherals(updated value: CGFloat) -> Void
    
    @objc optional func peripheralsStateError(_ message: String) -> Void
}

// MARK: -

class CBPeripheralExt: NSObject {
    
    //当前对象
    open var peripheral: CBPeripheral!
    //RSSI
    open var rssiVal: Int = 0
    //是否正在连接？
    open var isConnecting: Bool = false
    //是否已经连接？
    open var isConnected: Bool = false
}

// MARK: -

class NSHfhPeripherals: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //单例实例
    static let shared = NSHfhPeripherals()
    
    //消息
    open var NOTI_VALUE_CHANGED = Notification.Name("ValueChanged")
    //委托
    weak open var delegate: NSHfhPeripheralsDelegate?
    //管理中心
    private var centralManager: CBCentralManager?
    //设备名称
    private let CENTER_BL_NAME: String = "JRD-Medical"
    //列表
    private(set) var peripherals = Array<CBPeripheralExt>()
    //最后读取时间
    private var lastDateTime: Date!
    //当前写读特征值
    open var characteristicF11: CBCharacteristic?, characteristicF15: CBCharacteristic?
    //当前索引
    private(set) var currIndex: Int = -1
    
    //为上防止调用init方法
    override private init() {
     
    }
    
    open var isDataResponse: Bool {
    
        //最后日期是否为空？
        if nil != lastDateTime {
            //注：我们的数据是1秒返回一次，所以这里小于4秒已足够
            //是否有数据返回？
            let tempVal = abs(lastDateTime.timeIntervalSince(Date()))
            //返回
            return tempVal < 4
        }
        //没数据返回
        return false
    }
    
    // MARK: - Custom Methods
    
    open func startManager() -> Void {

        //重置
        reset()
        //是否为空?
        if nil != centralManager {
            centralManager?.delegate = nil
            centralManager = nil
        }
        //实例化
        centralManager = CBCentralManager.init(delegate: self, queue: .main)
    }
    
    open func stopScan() -> Void {
        
        //取消扫描
        centralManager?.stopScan()
    }

    open func willConnectObj(_ index: Int) -> Bool {
        
        //当前对象
        let tempObj = peripherals[index]
        //是否已连接？是否正在连接？
        if true == tempObj.isConnecting || true == tempObj.isConnected {
            return false
        }
        //取消扫描
        centralManager?.stopScan()
        //当前索引
        currIndex = index
        //标志
        tempObj.isConnecting = true
        tempObj.isConnected = false
        //修改状态
        centralManager?.connect(tempObj.peripheral, options: nil)
        //返回
        return true
    }
    
    open func disconnect() -> Void {
        
        //索引是否合法？
        if -1 == currIndex {
            return
        }
        //当前对象
        let tempObj = peripherals[currIndex]
        //是否连接成功？
        if true == tempObj.isConnected {
            //取消订阅
            if let f15 = characteristicF15 {
                tempObj.peripheral.setNotifyValue(false, for: f15)
            }
            tempObj.isConnected = false
            characteristicF15 = nil
            characteristicF11 = nil
        }
        //重置状态
        //tempObj.peripheral.delegate = nil
        tempObj.isConnecting = false
        //取消连接
        //centralManager?.cancelPeripheralConnection(tempObj.peripheral)
        //索引
        currIndex = -1
    }
    
    open func reset() -> Void {
        
        //日期置空
        lastDateTime = nil
        //取消连接
        disconnect()
        //清空所有状态
        peripherals.removeAll()
        //索引
        currIndex = -1
    }
    
    open func clearData() -> Void {
        
        //1.索引是否合法？2.是否有数据？2.写特征是否为空？
        guard currIndex > -1, true == isDataResponse, let f11 = characteristicF11 else {
            return
        }
        /*指令:0X12
         示例:APP 发送 85 58 12 01 00 FF (下行)
         设备返回 85 58 12 01 00 FF(上行)
         */
        let bytes: Array<UInt> = [85, 58, 0x12, 0x01, 0x00, 0xFF]
        let data = Data(bytes: bytes, count: bytes.count)
        //写
        peripherals[currIndex].peripheral.writeValue(data, for: f11, type: .withResponse)
    }
    
    private func resState(_ type: NSHfhPeripheralsReturnType, msg: String = "") -> Void {
        
        //是否为空？
        if let tempDelegate = delegate {
            let tempVal = tempDelegate.responds(to: #selector(tempDelegate.peripherals(_:message:)))
            if false != tempVal  {
                tempDelegate.peripherals!(type, message: msg)
            }
        }
    }
    
    // MARK: - CBCentralManager Delegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        //当前消息
        var messageVal: String = ""
        //判断手机蓝牙状态
        switch central.state {
        //扫描周边设备
        case .poweredOn:
            central.scanForPeripherals(withServices: nil, options: nil)
            //一定要注意这里的‘return’语句
            return
        case .poweredOff:
            messageVal = "蓝牙尚未打开，请打开后再连接"
        case .unauthorized:
            messageVal = "蓝牙未验证，无法连接"
        case .unknown:
            messageVal = "蓝牙状态未知，无法连接"
        case .resetting:
            messageVal = "蓝牙重置中，请稍候再试"
        case .unsupported:
            messageVal = "当前设备不支持蓝牙，请更换设备"
        }
        //是否为空？
        guard let tempDelegate = delegate else {
            return
        }
        let tempVal = tempDelegate.responds(to: #selector(tempDelegate.peripheralsStateError(_:)))
        if false != tempVal  {
            tempDelegate.peripheralsStateError!(messageVal)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //名称是否为空？
        guard let tempName = peripheral.name else {
            return
        }
        //专门连接指定名称设备
        if tempName != CENTER_BL_NAME {
            return
        }
        //是否包含当前设备？
        var exist: Bool = false
        //添加列表
        for tempObj in peripherals {
            if tempObj.peripheral == peripheral {
                exist = true
                break
            }
        }
        //是否存在？
        if true != exist {
            let obj = CBPeripheralExt()
            obj.peripheral = peripheral
            obj.rssiVal = RSSI.intValue
            //添加
            peripherals.append(obj)
        }
        //排序，信号从强至弱
        let resultArray = peripherals.sorted { (obj1: CBPeripheralExt, obj2: CBPeripheralExt) -> Bool in
            return obj1.rssiVal > obj2.rssiVal
        }
        peripherals.removeAll()
        for i in resultArray {
            peripherals.append(i)
        }
        //回调
        resState(.reloadData)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        //委托
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        //是否有错误信息？
        if let tempError = error {
            let tempVal = "连接失败，错误：\(tempError)"
            print(tempVal)
        }
        //日期置空
        lastDateTime = nil
        //更新状态
        resState(.error, msg: "")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        //错误信息
        if let tempError = error {
            let tempVal = "断开连接，错误：\(tempError)"
            print(tempVal)
        }
        //日期置空
        lastDateTime = nil
        //更新状态
        resState(.error, msg: "")
    }
    
    // MARK: - CBPeripheral Delegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        //服务列表是否大于0？
        if peripheral.services?.count ?? 0 < 1 {
            let tempVal = "没有服务，无法进行寻找特征值"
            print(tempVal)
            //断开连接
            disconnect()
            //日期置空
            lastDateTime = nil
            //回调
            return resState(.noServies, msg: tempVal)
        }
        //本例的外设中只有一个服务
        let service = peripheral.services?.last
        //根据UUID寻找服务中的特征
        peripheral.discoverCharacteristics(nil, for: service!)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        //特征列表
        for characteristic: CBCharacteristic in service.characteristics! {
            //查找相关特征值
            let tempVal = characteristic.uuid.uuidString.components(separatedBy: "-")
            if false != tempVal.first!.hasSuffix("FF11"/*移动设备写入的数据通道*/) {
                characteristicF11 = characteristic
            }
            else if false != tempVal.first!.hasSuffix("FF15"/*移动设备读入的数据通道*/) {
                characteristicF15 = characteristic
            }
        }
        //是否有读特征？
        guard let f15 = characteristicF15 else {
            //日期置空
            lastDateTime = nil
            //更新状态
            return resState(.error, msg: "")
        }
        //连接状态
        peripherals[currIndex].isConnected = true
        //读取特征里的数据
        peripheral.readValue(for: f15)
        peripheral.setNotifyValue(true, for: f15)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        //错误信息
        if let tempError = error {
            let tempVal = "订阅失败，错误：\(tempError)"
            print(tempVal)
            //日期置空
            lastDateTime = nil
            //更新状态
            return resState(.error, msg: "")
        }
        //订阅状态
        if true != characteristic.isNotifying {
            print("订阅状态：取消订阅")
        }
        else {
            let tempVal = "订阅状态：订阅成功"
            print(tempVal)
            //更新状态
            resState(.notify, msg: tempVal)
        }
    }
   
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        //数据是否为空？
        guard let dta = characteristic.value else {
            return
        }
        //更新时间
        lastDateTime = Date()
        /*温度
         命令:0X05
         示例:设备返回:85 58 05 05 32 05 1A 08 00 FF(上行) 解析:返回五个数据长度，第一字节保留，第二字节表示保留
         第三字节表示温度整数部分，第四字节表示温度小数部分，第五字节表示温度 正负，如果探头有问题，返回 00 00 03 E8 01,即-1000.
         00 00 1A 08 00 表示温度 26.08
         00 00 0B 02 01 表示温度-11.02
         --------------------------------------------------
         设置采集间隔时间
         命令:0X0B
         示例:APP 发送 85 58 0B 04 30 30 30 35 FF (下行)
         设备返回 85 58 0B 01 00 FF(上行)
         解析:30 30 30 35 为了兼容串口配置，这四个字节为字符型，表示设置采集间隔时间
         5 秒，范围为 0-300 秒。
         30 30 31 30 表示为 10 秒， 30 31 35 30 表示为 150 秒
         --------------------------------------------------
         查询电量
         命令:0X01
         示例:APP 发送 85 58 01 01 00 FF (下行) 设备返回 85 58 01 01 32 FF (上行)
         解析:0X32 表示电量剩余 50%， 0X64 表示电量剩余 100%
         */
        dta.enumerateBytes { (bytes: UnsafeBufferPointer, idx: Data.Index, s: inout Bool) in
            //是否有数据？
            if bytes.count < 10 {
                return
            }
            //命令类型
            switch bytes[2] {
            case 0x05:
                let resultVal: Float = Float(bytes[6]) + Float(bytes[7]) / 100.0
                //print("result = \(resultVal)")
                //发送消息
                NotificationCenter.default.post(name: NOTI_VALUE_CHANGED, object: resultVal)
            case 0x12:
                print("成功：清空设备数据")
            default:
                break;
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
        //错误信息
        if let tempError = error {
            let tempVal = "写入数据失败，错误：\(tempError)"
            return print(tempVal)
        }
        print("成功：写入数据")
    }
}
