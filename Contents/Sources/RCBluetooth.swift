import Foundation
import CoreBluetooth
import PlaygroundSupport
import PlaygroundBluetooth



public var printString = ""
public var bleStatus: String?
public var bleStatus2: String?



public func printLog(newString: String) {
    printString = newString
    NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Print"), object: nil)
}


public class RCBluetooth: NSObject, PlaygroundBluetoothCentralManagerDelegate, CBPeripheralDelegate {

    var characteristicASCIIValue = NSString()
    var txCharacteristic : CBCharacteristic?
    var rxCharacteristic : CBCharacteristic?
    
    public var centralManager: PlaygroundBluetoothCentralManager?
    private var blePeripheral: CBPeripheral?
    private let data = NSMutableData()
    var forwardString = "!B51"
    var stopString = "!B50"
    var backString = "!B615"
    var backStopString = "!B606"
    var rightString = "!B813"
    var rightStop = "!B804"
    var leftString = "!B714"
    var stopLeft = "!B705"
    let txCharMax: Int = 20
    fileprivate var txWriteType = CBCharacteristicWriteType.withResponse
    
    
    //    public func sendData(_ data:Data, _ duration:Int){
//        discoveredPeripheral!.writeValue(data, for: txCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
//        myPrint("Command Sent: \(data)")
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(duration) ) {
//            self.onDataWritten?()
//        }
//    }
//    
    
    
    
    // Data
//    var dataBuffer = [UartDataChunk]()
   // var dataBufferEnabled = Config.uartShowAllUartCommunication
    
    
    public override init() {
        super.init()
        centralManager = PlaygroundBluetoothCentralManager(services: [BLEService_UUID], queue: .global())
        centralManager!.delegate = self

    }
    
    //Handles BLE state change.
    public func centralManagerStateDidChange(_ centralManager: PlaygroundBluetoothCentralManager) {
        
        if centralManager.state == .poweredOn {
            NotificationCenter.default.addObserver(self, selector: #selector(writeValue2),name:NSNotification.Name(rawValue: "Go"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(writeValue3),name:NSNotification.Name(rawValue: "Stop"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(writeValue4),name:NSNotification.Name(rawValue: "GoBack"), object: nil)
                
            NotificationCenter.default.addObserver(self, selector: #selector(writeValue5),name:NSNotification.Name(rawValue: "StopBack"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(writeValue6),name:NSNotification.Name(rawValue: "GoRight"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(writeValue7),name:NSNotification.Name(rawValue: "StopRight"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(writeValue8),name:NSNotification.Name(rawValue: "GoLeft"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(writeValue9),name:NSNotification.Name(rawValue: "StopLeft"), object: nil)
            
            stringToData(string: forwardString)
            
            
        //    printLog(newString: #function)
            
            bleStatus = "Bluetooth Enabled"
        } else {
            bleStatus = "Bluetooth Disabled"
        }
    }

    
    
    
    
    // Write function
    func writeValue(data: String){
        let data = (data as NSString).data(using: String.Encoding.utf8.rawValue)
        if let blePeripheral = blePeripheral{
            if let txCharacteristic = txCharacteristic {
                blePeripheral.writeValue(data!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }

    func writeValue2(){
        //printLog(newString: #function)
       let message = forwardString
        if let data = message.data(using: String.Encoding.utf8) {
            sendDataWithCrc(data)
        }

    }
    
    func writeValue3(){
       // printLog(newString: #function)
        writeValue(data: stopString + "7")
    }
    
    func writeValue4(){
            printLog(newString: #function)
            writeValue(data: backString)
        }
        
    func writeValue5(){
            printLog(newString: #function)
            writeValue(data: backStopString)
        }
        

    func writeValue6(){
        printLog(newString: #function)
        writeValue(data: rightString)
    }
    
    func writeValue7(){
        printLog(newString: #function)
        writeValue(data: rightStop)
    }

    func writeValue8(){
        printLog(newString: #function)
        writeValue(data: leftString)
    }
    
    func writeValue9(){
        printLog(newString: #function)
        writeValue(data: stopLeft)
    }

    
    
   
    func sendTouchEvent(_ tag: Int, isPressed: Bool) {
        let message = "!B\(tag)\(isPressed ? "1" : "0")"
        if let data = message.data(using: String.Encoding.utf8) {
            sendDataWithCrc(data)
           
          //  writeValue(data: forwardString)
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
        writeValue(data: "!B516")
    }
    
    
    
    // Write function
//       func sendingValue(sentData: Data) {
//       var sentData = sentData
//       var offset = 0
//       let chunkSize = 20
//       let data = Data(bytesNoCopy: UnsafeMutablePointer<UInt8>(UnsafeMutablePointer<UInt8>(mutating: (self.data as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.data.count))+offset), count: chunkSize, deallocator: .none)
//        
//        if let blePeripheral = blePeripheral{
//           
//            if let txCharacteristic = txCharacteristic {
//                blePeripheral.writeValue(data!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
//            }
//        }
//    }
//
    
    
    
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDiscover peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double)  {
        print( "Discovered: \(peripheral.name) at \(rssi)")
        
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, willConnectTo peripheral: CBPeripheral) {
        // Handle peripheral connection attempts (prior to connection being made).
    }
    
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didConnectTo peripheral: CBPeripheral) {
        // Handle successful peripheral connection.
     // print("Peripheral:\(peripheral.name) connected")
        peripheral.delegate = self
        // Make sure we get the discovery callbacks
        peripheral.discoverServices([BLEService_UUID])
        // Search only for services that match our service UUID
        blePeripheral = peripheral
        
       //  bleStatus = "Peripheral info: \(blePeripheral)"
        
        
    }
    
   
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didFailToConnectTo peripheral: CBPeripheral, error: Error?) {
        // Handle failed peripheral connection.
        bleStatus = "Failed To Connect"
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDisconnectFrom peripheral: CBPeripheral, error: Error?) {
        // Handle peripheral disconnection.
        blePeripheral = nil
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            
            return
        }
        guard let services = peripheral.services else {
            return
        }
        for service in services { // Find the characteristic we want in services
            
            peripheral.discoverCharacteristics([BLE_Characteristic_uuid_Tx],  for: service)
        
        }
   // bleStatus = "Peripheral services: \(services)"
    }

    
    
//    public func sendCommandData(_ data:Data, _ duration:Int){
//        blePeripheral!.writeValue(data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
//        //Add a debug log here
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(duration) ) {
//            self.onDataWritten?()
//        }
//    }
//
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?){
        guard error == nil else {
            return
        }
        bleStatus = "sent"
    }

    // Callback on data arrival via notification on the characteristic
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if characteristic == rxCharacteristic {
            
            if let ASCIIstring = NSString(data: characteristic.value!, encoding: String.Encoding.utf8.rawValue) {
                characteristicASCIIValue = ASCIIstring
                print("Stored Value: \(characteristicASCIIValue)")
                
                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: nil)
                
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        print("*******************************************************")
        print("Function: \(#function), line: \(#line)")
        
        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        
        print("Found \(characteristics.count) characteristics!")
        
        for characteristic in characteristics {
            //looks for the right characteristic
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Rx)  {
                rxCharacteristic = characteristic
                
                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: rxCharacteristic!)
                
                peripheral.readValue(for: characteristic)
                print("Rx Characteristic: \(characteristic.uuid)")
            }
            
            if characteristic.uuid.isEqual(BLE_Characteristic_uuid_Tx){
                txCharacteristic = characteristic
                print("Tx Characteristic: \(characteristic.uuid)")
                
            }
            peripheral.discoverDescriptors(for: characteristic)
        }
        bleStatus2 = "did something"
    }
}

extension RCBluetooth : ControllerPadViewControllerDelegate {
    func onSendControllerPadButtonStatus(tag: Int, isPressed: Bool) {
        sendTouchEvent(tag, isPressed: isPressed)
    }
}


