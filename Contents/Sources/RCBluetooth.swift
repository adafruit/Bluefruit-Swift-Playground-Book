//Newer
import Foundation
import CoreBluetooth
import PlaygroundSupport
import PlaygroundBluetooth



public var printString = ""
public var bleStatus: String?
public var bleStatus2: String?



public func printLog(newString: String) {
    let appendString = "\n"
    printString = newString + appendString
    NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Print"), object: nil)
}


public class RCBluetooth: NSObject, PlaygroundBluetoothCentralManagerDelegate, CBPeripheralDelegate {

    var timer = Timer()
    var duration:Int = 2000
    var characteristicASCIIValue = NSString()
    var txCharacteristic : CBCharacteristic?
    var rxCharacteristic : CBCharacteristic?
    public var onCharacteristicsDiscovered:((CBPeripheral)->Void)?  // Robot connected
    public var centralManager: PlaygroundBluetoothCentralManager?
    private var blePeripheral: CBPeripheral?
    private let data = NSMutableData()
    var forwardString = "!B516"
    var stopString = "!B507"
    var backString = "!B615"
    var backStopString = "!B606"
    var rightString = "!B813"
    var rightStop = "!B804"
    var leftString = "!B714"
    var leftStop = "!B705"
    let txCharMax: Int = 20

    public var onCharacteristicsUpdated:((Data)->Void)?
    public var isConnected: Bool = false
   
    public var onDataWritten:(()->Void)?
    public override init() {
        super.init()
        centralManager = PlaygroundBluetoothCentralManager(services: [BLEService_UUID], queue: .global())
        centralManager!.delegate = self

    }
    
    //Handles BLE state change.
    public func centralManagerStateDidChange(_ centralManager: PlaygroundBluetoothCentralManager) {
        
        if centralManager.state == .poweredOn {
            isConnected = true
            printLog(newString: "Bluetooth is Enabled.")
        } else {
  
            printLog(newString: "Bluetooth is Disabled. Turn On Bluetooth in Control Panel.")

        }
    }

    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDiscover peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double)  {
        
        // printLog (newString: "Discovered: \(peripheral.name) at \(rssi)")
        
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, willConnectTo peripheral: CBPeripheral) {
        // Handle peripheral connection attempts (prior to connection being made).
    }
    
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didConnectTo peripheral: CBPeripheral) {
        // Handle successful peripheral connection.
        peripheral.delegate = self
        // Make sure we get the discovery callbacks
        peripheral.discoverServices([BLEService_UUID])
        blePeripheral = peripheral
        
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didFailToConnectTo peripheral: CBPeripheral, error: Error?) {
        // Handle failed peripheral connection.
    }
    
    public func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDisconnectFrom peripheral: CBPeripheral, error: Error?) {
        // Handle peripheral disconnection.
        blePeripheral = nil
    }
    
    // Write function
    public func sendRcData(_ data: Data, _ duration: Int){
        blePeripheral!.writeValue(data, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
       // printLog(newString: "Data sent: \(data)")
       DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(duration) ) {
            self.onDataWritten?()
             self.stopForward()
        }
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
            //   printLog(newString:  "didDiscoverServices: \(service)" )
            peripheral.discoverCharacteristics([BLE_Characteristic_uuid_Tx, BLE_Characteristic_uuid_Rx], for: service)
        }
        
    }
    
    
    
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
                //Once found, subscribe to the this particular characteristic...
                peripheral.setNotifyValue(true, for: characteristic)
                
               // peripheral.readValue(for: characteristic)
                //print("Rx Characteristic: \(characteristic.uuid)")
            }
            peripheral.discoverDescriptors(for: characteristic)
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

    
    
    
    public func stopAllAction() {
        
        printLog(newString: #function)
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.stopForward), userInfo: nil, repeats: false)
        
        timer.invalidate()
    }
    
    
    public func moveForward(){
    
        printLog(newString: "<Forward>  ")
    
      //  self.timer.invalidate()
    
       // Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.stopForward), userInfo: nil, repeats: false)

        writeValue22(data: forwardString)
    }
    
    
    
    
    public func stopForward(){
        
        printLog(newString: "<Forward Stopped>  ")
        writeValue22(data: stopString)
    }
    
   public  func moveBack(){
        printLog(newString: "<Back>  ")
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.stopBack), userInfo: nil, repeats: false)
       
        //sendRcData(backString)
        }

    
   public func stopBack(){
            printLog(newString: "<Back Stopped>  ")
          //  sendRcData(backStopString)
        }


   public func turnRight(){
        printLog(newString: "<Turning Right>  ")
        
        //sendRcData(rightString)
    }

   public func stopRight(){
        printLog(newString: "<Right Stopped>  ")
       // sendRcData(rightStop)
    }

   public func turnLeft(){
        printLog(newString: "<Turning Left>  ")
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.stopLeft), userInfo: nil, repeats: false)
        
        //sendRcData(leftString)
    }

   public func stopLeft(){
        printLog(newString: "<Left Stopped>  ")
      //  sendRcData(leftStop)
    }

    
    
   
    func sendTouchEvent(_ tag: Int, isPressed: Bool) {
        let message = "!B\(tag)\(isPressed ? "1" : "0")"
        if let data = message.data(using: String.Encoding.utf8) {
            sendDataWithCrc(data)
           
          //  sendRcData(data: forwardString)
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
     //   sendRcData(data: "\(dataWithChecksum)
    }
    
    
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
            print("Notification stopped on (\(characteristic))  Disconnecting")
   
        }
    }
    
    
    
}

extension RCBluetooth : ControllerPadViewControllerDelegate {
    func onSendControllerPadButtonStatus(tag: Int, isPressed: Bool) {
        sendTouchEvent(tag, isPressed: isPressed)
    }
}


