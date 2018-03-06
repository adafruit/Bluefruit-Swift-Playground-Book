//
//  RcCommand.swift
//
//
//  Created by Trevor Beaton on 9/5/17.
//  Copyright © 2018 Adafruit Industries All rights reserved.


import Foundation
import PlaygroundSupport

public var durationTimer: Int?

public class RCCommand: NSObject {
    
    //:- Variables
    private let defaultDuration:Int = 750
    private var _duration:Int = 0   //only to be used by default variable
    var duration:Int {
        //returns default duration if less than or equal to zero
        get {
            if _duration <= 0{ return defaultDuration }
            else { return _duration }
        }
        set {_duration = newValue}
    }
    public var commandArray : [String] = []
    let rcBluetooth: RCBluetooth = RCBluetooth()
    let commandManager: CommandManager = CommandManager()
    
    //:- Motion String Commands
    
    
    let MOVE_BACKWARD : [Int8] = [ 0x21, 0x42, 0x36, 0x31, 0x35 ] //!B615
    let MOVE_FORWARD : [Int8] = [ 0x21, 0x42, 0x35, 0x31, 0x36 ] //!B516
    let TURN_RIGHT : [Int8] = [ 0x21, 0x42, 0x38, 0x31, 0x33 ] //!B813
    let TURN_LEFT : [Int8] = [ 0x21, 0x42, 0x37, 0x31, 0x34 ] //!B714
    let PAUSE : [Int8] = [ 0x21, 0x42, 0x35, 0x30, 0x37 ] //!B507
    
    //:- Functions
    
    public func sendRobotCommand(_ rcBluetooth: RCBluetooth, _ command: PlaygroundValue){
        
        switch command {
        case let .integer(text):
//            printLog("--> sendRobotCommand Int = \(text)")
            duration = text
            break
        case let .string(text):
            var fourBytes : [Int8] = []
            switch(text) {
            case CommandType.COMMAND_PAUSE.rawValue:
                fourBytes = PAUSE
                printLog("Sending: Wait, Duration: \(duration)")
                break
            case CommandType.COMMAND_MOVE_FORWARD.rawValue:
                fourBytes = MOVE_FORWARD
                printLog("Sending: Forward, Duration: \(duration)")
                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Command"), object: ["Command": CommandType.COMMAND_MOVE_FORWARD.rawValue])
                break
            case CommandType.COMMAND_MOVE_BACKWARD.rawValue:
                fourBytes = MOVE_BACKWARD
                printLog("Sending: Back, Duration: \(duration)")
                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Command"), object: ["Command": CommandType.COMMAND_MOVE_BACKWARD.rawValue])
                break
            case CommandType.COMMAND_TURN_RIGHT.rawValue:
                fourBytes = TURN_RIGHT
                printLog("Sending: Right, Duration: \(duration)")
                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Command"), object: ["Command": CommandType.COMMAND_TURN_RIGHT.rawValue])
                break
            case CommandType.COMMAND_TURN_LEFT.rawValue:
                fourBytes = TURN_LEFT
                printLog("Sending: Left, Duration: \(duration)")
                NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Command"), object: ["Command": CommandType.COMMAND_TURN_LEFT.rawValue])
            default:
                break
            }
            
            //Format command for bluetooth and send with duration
            let data : Data = NSData(bytes: fourBytes, length: fourBytes.count*4) as Data
//            scheduleSendData(data, duration: duration) //WORK IN PROGRESS
            rcBluetooth.sendRcData(data, duration)
            //Reset duration after sending a command
            duration = 0
            break
        default:
            //            printLog("sendRobotCommand - command is not duration")
            break
        }
    }
    
    /*// WHEELIE PREVENTION ///////////////
    func scheduleSendData(_ data:Data, duration:Int){
        printLog("--->scheduleSendData 0")
        let timer = Timer.scheduledTimer(
            timeInterval: 3,
            target: self,
            selector: #selector(sendDataFromTimer),
            userInfo: ["theRcBluetooth": rcBluetooth, "theData": data, "theDuration": duration],
            repeats: false)
        
    }
    
    @objc func sendDataFromTimer(timer:Timer){

        let userInfo = timer.userInfo as! Dictionary<String, AnyObject>
        let rcb:RCBluetooth = (userInfo["theRcBluetooth"] as! RCBluetooth)
        let data:Data = (userInfo["theData"] as! Data)
        let duration:Int = (userInfo["theDuration"] as! Int)
        printLog("special delivery = \(data) duration = \(duration)")
        rcb.sendRcData(data, duration)
//        printLog("--->sendDataFromTimer 4")
    }
    */
    
    
    public static func solutionChecker(_ commands:[PlaygroundValue], _ correctSolution:[CommandType])->Bool{
        printLog(#function)
        printLog("Array Count: \(commands.count)")
        var result:Bool = false
        
        if commands.count == correctSolution.count{
            
            for index in 0...(commands.count-1) {
                
                let command:PlaygroundValue = commands[index]
                
                if case let .string(text) = command {
                    
                    if !text.isEqual(correctSolution[index].rawValue){
                        
                        break
                    }
                }
                
                if index==(commands.count-1){
                    
                    result = true
                }
            }
        }
        return result
    }
    
}
