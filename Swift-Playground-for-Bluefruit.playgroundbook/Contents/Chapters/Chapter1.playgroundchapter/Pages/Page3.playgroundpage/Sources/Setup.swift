//Newer
//  Created by Trevor Beaton on 12/14/17.
//  Copyright © 2018 Adafruit Industries All rights reserved.
import Foundation
import PlaygroundSupport
import PlaygroundBluetooth


var delegate: UserProcessDelegate?
let commandManager: CommandManager = CommandManager()
let rcBluetooth: RCBluetooth = RCBluetooth()



public func setup(){
    let page = PlaygroundPage.current
    page.needsIndefiniteExecution = true
    let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
    delegate = UserProcessDelegate(pauseHandler: commandManager)
    delegate?.onAssessment = assessment
    proxy?.delegate = delegate
}



public func assessment(_ playgroundValue:PlaygroundValue)->Bool{
    // Assessment

//  var correctSolution:[CommandType] = [  CommandType.COMMAND_MOVE_FORWARD, CommandType.COMMAND_TURN_RIGHT, CommandType.COMMAND_MOVE_FORWARD ]

    var commands:[PlaygroundValue] = [PlaygroundValue]()

    if case let .array(values) = playgroundValue {
        commands = values
    }
    
    //CORRECT SOLUTION = match a specific list of commands with durations
    let solution = ["2000", CommandType.COMMAND_MOVE_FORWARD.rawValue, "500", CommandType.COMMAND_TURN_LEFT.rawValue, "1000", CommandType.COMMAND_MOVE_FORWARD.rawValue]
    var result = false
    var commandCount = 0
    //check for count match
    if solution.count == commands.count {
        //iterate through commands
        for index in 0...(commands.count-1) {
            var testString:String = ""
            //convert integer type to store as string
            if case let .integer(intVal) = commands[index] {
                testString = "\(intVal)"
            }
            //store string type
            else if case let .string(textVal) = commands[index] {
                testString = textVal
            }
            //error - not a string or integer
            else {
                break
            }
            //test against solution
            if testString == solution[index]{
                commandCount += 1
            }
        }
    }
    //check for 100% match
    if commandCount == solution.count {
        result = true
    }
    
//    let result: Bool = RCCommand.solutionChecker(commands, correctSolution)

    var failureHints = [NSLocalizedString("Follow the instructions closely and remember that 1 second equals 1000 milliseconds", comment: "")]

    //Update assessment status
//    PlaygroundPage.current.assessmentStatus = .pass(message: NSLocalizedString("### Pass! \n Now that’s what I call a victory dance!\n\n[**Next Page**](@next)", comment: ""))

    if(result){
        
        PlaygroundPage.current.assessmentStatus = .pass(message: NSLocalizedString("### Yes! You did it...now on to the next lesson?...I think? \n\n[**Next Page**](@next)", comment: ""))
    }
    else{
       // printLog("Fail")
        PlaygroundPage.current.assessmentStatus = .fail(hints: failureHints, solution: nil)
    }
    return result
}
