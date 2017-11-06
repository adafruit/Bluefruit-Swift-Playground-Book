//
//  RcCommand.swift
//
//
//  Created by Trevor Beaton on 9/5/17.
//
//

import Foundation
import PlaygroundSupport


public var durationTimer: Int?

public class RCCommand: NSObject {
    
    public var sensorType:String?
    let PAUSE : [Int8] = [ 0x21, 0x42, 0x35, 0x30, 0x37 ] //!B507
    let MOVE_FORWARD : [Int8] = [ 0x21, 0x42, 0x35, 0x31, 0x36 ] //!B516
    let MOVE_BACKWARD : [Int8] = [ 0x21, 0x42, 0x36, 0x31, 0x35 ] //!B615
    let TURN_RIGHT : [Int8] = [ 0x21, 0x42, 0x38, 0x31, 0x33 ] //!B813
    let TURN_LEFT : [Int8] = [ 0x21, 0x42, 0x37, 0x31, 0x34 ] //!B714
   
    let commandManager: CommandManager = CommandManager()
    
    public var commandArray : [String] = []
    
    let rcBluetooth: RCBluetooth = RCBluetooth()
    //let waitTime:TimeIneterval = 2
    //var timer = Timer()
   
    public var duration: Int = 1
    
    public func sendRobotDuration(_ command: PlaygroundValue){
//        Use trimmingCharacters(in:) to remove spaces before and after each element
//        Use Int() to convert each element into an integer.
//        Use flatMap to remove any items that couldn't be converted to Int.
//        Use reduce to sum up the array of Int.

         var testString = "\(command)"
        
        let result = testString.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted)
        //let values = testString.components(separatedBy: ",").flatMap { Int($0.trimmingCharacters(in: .whitespaces)) }
      //  let sum = result.reduce(0, +)
        //print(sum)  // 390
        
        duration = Int(result)!
    //    printLog(newString:  "CHECKING:::::\(sum)")
        printLog(newString: "Result: \(result)")
    }
    
    
    public func durationReset(){
        printLog(newString: "Duration Has Been Reset to 2 Seconds.")
        duration = 2
    }
    
    
    public func sendRobotCommand(_ rcBluetooth: RCBluetooth, _ command: PlaygroundValue){
        switch command {
        case let .string(text):
            var fourBytes : [Int8] = []
        //    duration: Int = 1000
         //   var newfour: String?
            sensorType = nil
            switch(text) {
           case CommandType.COMMAND_PAUSE.rawValue:
                fourBytes = PAUSE
                duration = 1
             //   printLog(newString: "\(durationTimer!)")
            case CommandType.COMMAND_MOVE_FORWARD.rawValue:
                 fourBytes = MOVE_FORWARD
                 printLog(newString: "Forward Duration: \(duration)")
                // duration = 2
                break
            case CommandType.COMMAND_MOVE_BACKWARD.rawValue:
                fourBytes = MOVE_BACKWARD
                printLog(newString: "Backward Duration: \(duration)")
                //duration = 2
                break
            case CommandType.COMMAND_TURN_RIGHT.rawValue:
                 fourBytes = TURN_RIGHT
                 printLog(newString: "Right Duration: \(duration)")
                 //duration = 2
                break
            case CommandType.COMMAND_TURN_LEFT.rawValue:
                fourBytes = TURN_LEFT
                printLog(newString: "Left Duration: \(duration)")
                //duration = 2
            default:
                break
            }
            if sensorType == nil {
                let data : Data = NSData(bytes: fourBytes, length: fourBytes.count*4) as Data
                rcBluetooth.sendRcData(data, duration)
            }
            else{
                printLog(newString: "Data was not sent.")
            }
            break
        default:
            break
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
//This is to be deleted
    //the solution checker must be checked and called from somewhere.
    
    public static func solutionChecker(_ commands:[PlaygroundValue], _ correctSolution:[CommandType])->Bool{ // Don't pass in robot connect command into this
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

