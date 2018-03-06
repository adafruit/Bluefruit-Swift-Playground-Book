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

public func random(min:Int, max:Int) ->Int{
    
    let newMax = UInt32(max - min)
    let randomVal = Int(arc4random_uniform(newMax)) + min
    return randomVal
    
}

public func assessment(_ playgroundValue:PlaygroundValue)->Bool{
    // Assessment

//  var correctSolution:[CommandType] = [  CommandType.COMMAND_MOVE_FORWARD, CommandType.COMMAND_TURN_RIGHT, CommandType.COMMAND_MOVE_FORWARD ]

    var commands:[PlaygroundValue] = [PlaygroundValue]()

    if case let .array(values) = playgroundValue {
        commands = values
    }
    
    //CORRECT SOLUTION: all integer values are same & at least 3 valid commands called
    var failureHints = [NSLocalizedString("Include at least 3 movement commands within the dance function.", comment: "")]
    var result = false
    var customFunctionCalled = false
    let possibleCommands = [CommandType.COMMAND_MOVE_FORWARD.rawValue, CommandType.COMMAND_MOVE_BACKWARD.rawValue , CommandType.COMMAND_TURN_LEFT.rawValue, CommandType.COMMAND_TURN_RIGHT.rawValue, CommandType.COMMAND_PAUSE.rawValue]
    var commandCount = 0
    let requiredCommandCount = 3
    var duration = 0
    var durPass = true
    var durCalls = 0
    for index in 0...(commands.count-1) {
        
        //check if integer
        if case let .integer(intVal) = commands[index] {
            if duration == 0 {
                duration = intVal
            }
            else if intVal != duration{
                durPass = false
            }
            else {
                durCalls += 1
            }
        }
        
        //check if string
        if case let .string(textVal) = commands[index] {
            
            //check if custom function was called
            if textVal == CommandType.COMMAND_CUSTOM_FUNCTION.rawValue{
                customFunctionCalled = true
            }
            
            //check if a movement command was called
            for possibleCommand in possibleCommands {
                if textVal == possibleCommand {
                    commandCount += 1
                }
            }
        }
    }
    
    if customFunctionCalled == false {
        failureHints = [NSLocalizedString("Remember to call your custom function after it's defined as described in the instructions.", comment: "")]
    }
    else if commandCount < requiredCommandCount{
        failureHints = [NSLocalizedString("Remember to include at least 3 movement commands within the dance function.", comment: "")]
    }
    else if durPass == false || durCalls < 1  {
        failureHints = [NSLocalizedString("Use the duration variable to set the duration for each movement command.", comment: "")]
    }
    else {
        result = true
    }
    
    
//    let result: Bool = RCCommand.solutionChecker(commands, correctSolution)

    

    //Update assessment status
//    PlaygroundPage.current.assessmentStatus = .pass(message: NSLocalizedString("### Pass! \n Now that’s what I call a victory dance!\n\n[**Next Page**](@next)", comment: ""))

    if(result){
        
        PlaygroundPage.current.assessmentStatus = .pass(message: NSLocalizedString("### Congrats - well done! You have completed all lessons for the MyMiniRacecar! \n\n[**Next Page**](@next)", comment: ""))
    }
    else{
       // printLog("Fail")
        PlaygroundPage.current.assessmentStatus = .fail(hints: failureHints, solution: nil)
    }
    return result
}
