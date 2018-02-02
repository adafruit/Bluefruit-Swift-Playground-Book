//
//  RCBluetooth.swift
//
//  Created by Trevor Beaton on 12/14/17.
//  Copyright © 2017 Vanguard Logic LLC. All rights reserved.
//

import Foundation
import CoreBluetooth
import PlaygroundSupport
import PlaygroundBluetooth


//Global variables and print funtion for debugging
public var printString = ""
public var bleStatus: String?
public var bleStatus2: String?
public func printLog(newString: String) {
    let appendString = "\n"
    printString = newString + appendString
    NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Print"), object: nil)
}

public class RCBluetooth: NSObject, PlaygroundBluetoothCentralManagerDelegate, CBPeripheralDelegate {

  
    // Mark:- Data
  
  
    var timer = Timer()
    var duration: Int = 2000
    var txCharacteristic : CBCharacteristic?
    var rxCharacteristic : CBCharacteristic?
    var characteristicASCIIValue = NSString()
  
    //Public variables
    public var onDataWritten:(()->Void)?
    public var isConnected: Bool = false
    public var onCharacteristicsUpdated:((Data)->Void)?
    public var centralManager: PlaygroundBluetoothCentralManager?
    public var onCharacteristicsDiscovered:((CBPeripheral)->Void)?
  
    //Private variables
    private var blePeripheral: CBPeripheral?
    private let data = NSMutableData()
  
    //Motion String Commands
    var forwardString = "!B516"
    var stopString = "!B507"
    var backString = "!B615"
    var backStopString = "!B606"
    var rightString = "!B813"
    var rightStop = "!B804"
    var leftString = "!B714"
    var leftStop = "!B705"
    let txCharMax: Int = 20

    public override init() {
        super.init()
      //Creates a central manager that supports communicating with Bluetooth peripherals
      centralManager = PlaygroundBluetoothCentralManager(services: [BLEService_UUID], queue: .global())
      centralManager!.delegate = self
    }
  
  
    //:- Methods for Connectivity
  
  
    //Tells the delegate that the state of the central manager has changed.
    public func centralManagerStateDidChange(_ centralManager: PlaygroundBluetoothCentralManager) {
        if centralManager.state == .poweredOn {
            isConnected = true
            printLog(newString: "Bluetooth is Enabled.")
       }else {
            printLog(newString: "Bluetooth is Disabled. Turn On Bluetooth in Control Panel.")
        }
    }
  
    // Tells the delegate that a peripheral has been discovered during scanning.
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDiscover peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double)  {
    }
  
    // Tells the delegate that the central manager is about to attempt to establish a connection with a peripheral.
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, willConnectTo peripheral: CBPeripheral) {
    }
    
    // Tells the delegate that the central manager established a connection with a peripheral.
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didConnectTo peripheral: CBPeripheral) {
        peripheral.delegate = self
        // Make sure we get the discovery callbacks
        peripheral.discoverServices([BLEService_UUID])
        blePeripheral = peripheral
    }
  
    // Tells the delegate that the central manager failed to establish a connection with a peripheral.
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didFailToConnectTo peripheral: CBPeripheral, error: Error?) {
    }
  
    // Tells the delegate that the central manager disconnected from a peripheral.
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDisconnectFrom peripheral: CBPeripheral, error: Error?) {
        blePeripheral = nil
    }
  
    // Invoked when you discover the peripheral’s available services.
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            // Find the characteristic we want in services
            peripheral.discoverCharacteristics([BLE_Characteristic_uuid_Tx, BLE_Characteristic_uuid_Rx], for: service)
        }
    }
  
    // Invoked when you discover the characteristics of a specified service.
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            //looks for the right characteristic
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx) {
                txCharacteristic = characteristic
                isConnected = true
                onCharacteristicsDiscovered?(peripheral)
            }
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
                peripheral.setNotifyValue(true, for: characteristic)
            }
                peripheral.discoverDescriptors(for: characteristic)
        }
    }
  
    // Invoked when you write data to a characteristic descriptor’s value.
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
      guard error == nil else {
      return
    }
    //onDataWritten?()
  }
  
    // Callback on data arrival via notification on the characteristic
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    guard error == nil else {
      printLog(newString: "Error discovering services: \(error!.localizedDescription)")
      return
    }
    if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx) {
      onCharacteristicsUpdated?(characteristic.value!)
    }
  }
  
    // The peripheral checks whether our subscribe/unsubscribe happened or not
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    guard error == nil else {
      //   myPrint("Error changing notification state: \(error!.localizedDescription)")
      return
    }
    if (characteristic.isNotifying) {
      print("Notification began on \(characteristic)")
    } else {
      print("Notification stopped on (\(characteristic)) Disconnecting")
    }
  }
  
  // Sends our motion commands and duration time to bluetooth device using a write characteristic.
  public func sendRcData(_ data: Data, _ duration: Int){
    blePeripheral!.writeValue(data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(duration) ) {
      self.onDataWritten?()
      self.stopForward()
    }
  }
  
    // Write function
    public func writeValue22(data: String){
      let data = (data as NSString).data(using: String.Encoding.utf8.rawValue)
          if let blePeripheral = blePeripheral{
            if let txCharacteristic = txCharacteristic {
                blePeripheral.writeValue(data!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
  
  func stringToData(string: String) {
    let data = string.data(using: String.Encoding.utf8,allowLossyConversion: true)
    sendDataWithCrc(data!)
  }
  
  func sendDataWithCrc(_ data : Data) {
    
    let len = data.count
    var dataBytes = [UInt8](repeating: 0, count: len)
    var crc: UInt8 = 0
    (data as NSData).getBytes(&dataBytes, length: len)
    
    for i in dataBytes {    //add all bytes
      crc = crc &+ i
    }
    crc = ~crc  //invert
    
    var dataWithChecksum = NSData(data: data) as Data
    dataWithChecksum.append(&crc, count: 1)
    sendCommand = "\(dataWithChecksum)"
  }
  
  
  // Mark:- Motion Functions
  
  
    public func moveForward(){
      printLog(newString: "<Forward>")
      writeValue22(data: forwardString)
    }
    
    public func stopForward(){
      printLog(newString: "<Forward Stopped>")
      writeValue22(data: stopString)
    }
    
    public  func moveBack(){
    printLog(newString: "<Back>")
    writeValue22(data: backString)
  }

    public func stopBack(){
      printLog(newString: "<Back Stopped>")
      writeValue22(data: backStopString)
    }

    public func turnRight(){
      printLog(newString: "<Turning Right>")
      writeValue22(data: rightString)
    }

    public func stopRight(){
      printLog(newString: "<Right Stopped>")
      writeValue22(data: rightStop)
    }

    public func turnLeft(){
        printLog(newString: "<Turning Left>")
         writeValue22(data: leftString)
    }

    public func stopLeft(){
      printLog(newString: "<Left Stopped>")
      writeValue22(data: leftStop)
    }

    func sendTouchEvent(_ tag: Int, isPressed: Bool) {
        let message = "!B\(tag)\(isPressed ? "1" : "0")"
        if let data = message.data(using: String.Encoding.utf8) {
            sendDataWithCrc(data)
        }
    }
}

extension RCBluetooth : ControllerPadViewControllerDelegate {
    func onSendControllerPadButtonStatus(tag: Int, isPressed: Bool) {
        sendTouchEvent(tag, isPressed: isPressed)
    }
}


