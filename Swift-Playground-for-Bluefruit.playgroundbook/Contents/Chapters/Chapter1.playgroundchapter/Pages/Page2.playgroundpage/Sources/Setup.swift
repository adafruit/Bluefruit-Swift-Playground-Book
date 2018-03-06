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

    //CORRECT SOLUTION = at least 3 valid commands with durations
    var result = false
    var commandCount = 0
    for index in 0...(commands.count-1) {
        if case let .integer(text) = commands[index] {
            commandCount += 1
        }
    }
    if commandCount >= 3 {
        result = true
    }
    
//    let result: Bool = RCCommand.solutionChecker(commands, correctSolution)
    var failureHints = [NSLocalizedString("Remember to include a duration value between the left & right parentheses of each command", comment: "")]

    //Update assessment status
//    PlaygroundPage.current.assessmentStatus = .pass(message: NSLocalizedString("### Pass! \n Now that’s what I call a victory dance!\n\n[**Next Page**](@next)", comment: ""))

    if(result){
        
        PlaygroundPage.current.assessmentStatus = .pass(message: NSLocalizedString("### Excellent! Now, let's build a function ... \n\n[**Next Page**](@next)", comment: ""))
    }
    else{
       // printLog("Fail")
        PlaygroundPage.current.assessmentStatus = .fail(hints: failureHints, solution: nil)
    }
    return result
}
