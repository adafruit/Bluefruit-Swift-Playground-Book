//  Created by Trevor Beaton on 12/14/17.
//  Copyright © 2017 Vanguard Logic LLC. All rights reserved.



import UIKit
import CoreBluetooth
import PlaygroundSupport
import Foundation



let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

let BLEService_UUID = CBUUID(string: kBLEService_UUID)

let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)

let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)



public class Constants: NSObject {

        public static let COMMAND_FINISHED = "CommandFinishedtestS"
    
        public static let PROGRAM_FINISHED = "ProgramFinished"
    
    
    public static func commandTextToLocalizedText(_ text:String)->String{
        if(text == ""){
            return ""
        }
        var type:CommandType = CommandType(rawValue: text)!
        return self.commandTypeToLocalizedText(type)
    }
    
    public static func commandTypeToLocalizedText(_ type:CommandType)->String{
        var text:String = ""
        switch(type) {
            
        case .COMMAND_MOVE_FORWARD:
            text = NSLocalizedString("I'm moving forward!", comment: "")
        case .COMMAND_MOVE_BACKWARD:
            text = NSLocalizedString("Backing up!", comment: "")
        case .COMMAND_TURN_RIGHT:
            text = NSLocalizedString("And a quick turn to the right!", comment: "")
        case .COMMAND_TURN_LEFT:
            text = NSLocalizedString("And a quick turn to the left!", comment: "")
            
        default:
            break
        }
        return text
    }
    
    
    
    
    
    
}
