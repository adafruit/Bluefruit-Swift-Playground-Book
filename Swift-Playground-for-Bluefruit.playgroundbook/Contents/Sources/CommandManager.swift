//
//  CommandManager.swift
//  
//
//  Created by Trevor Beaton on 12/14/17.
//  Copyright © 2018 Adafruit Industries All rights reserved.

import Foundation
import PlaygroundSupport

public enum CommandType: String {
    
    case COMMAND_MOVE_FORWARD   =  "command_moveForward"
    case COMMAND_MOVE_BACKWARD  =  "command_moveBackward"
    case COMMAND_TURN_RIGHT     =  "command_turnRight"
    case COMMAND_TURN_LEFT      =  "command_turnLeft"
    case COMMAND_PAUSE          =  "command_pause"
    case COMMAND_EXIT_PROGRAM   =  "ExitProgram"
    case COMMAND_CUSTOM_FUNCTION =  "CustomFunction"
    
}

public protocol CommandPauseDelegate {
    var isReadyForMoreCommands: Bool { get set }
    var returnValue: Bool { get set }
    
}

extension CommandPauseDelegate {
    /// Waits until `isReadyForMoreCommands` is set to true.
    func wait() {
        repeat {
            RunLoop.main.run(mode: .defaultRunLoopMode, before: Date(timeIntervalSinceNow: 0.1))
        } while !isReadyForMoreCommands
    }
}

public class CommandManager: CommandPauseDelegate {
    
    public var isReadyForMoreCommands = true
    public var returnValue = false
    var command: PlaygroundValue = .string("")
    var userInt: Int?
  
    public init(){
    }
  
  
  
    public func sendCommand(_ commandData:PlaygroundValue) {
      printLog("SendCommand")
      let page = PlaygroundPage.current
        if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
            proxy.send(commandData)
        }
        // Spin the runloop until the LiveView process has completed the current command.
        isReadyForMoreCommands = false
         wait()
    }
    
    
    public func moveForward(){
        command = .string(CommandType.COMMAND_MOVE_FORWARD.rawValue)
        sendCommand(command)
      
    }
    
    public func moveBack(){
        command = .string(CommandType.COMMAND_MOVE_BACKWARD.rawValue)
        sendCommand(command)
      
    }
    
    public func turnRight(){
        command = .string(CommandType.COMMAND_TURN_RIGHT.rawValue)
        sendCommand(command)
      
    }
    
    public func turnLeft(){
        command = .string(CommandType.COMMAND_TURN_LEFT.rawValue)
        sendCommand(command)
    }
    
    public func exitProgram(){
        command = .string(CommandType.COMMAND_EXIT_PROGRAM.rawValue)
        sendCommand(command)
    }
    
    public func customFunctionCalled(){
        command = .string(CommandType.COMMAND_CUSTOM_FUNCTION.rawValue)
        sendCommand(command)
    }
    
    public func pause(){
        command = .string(CommandType.COMMAND_PAUSE.rawValue)
        sendCommand(command)
    }
    
    public func testForward(){
        command = .string(CommandType.COMMAND_MOVE_FORWARD.rawValue)
        sendCommand(command)
    }
 
    public func intTaker(){
    printLog("Hello")
    }
}
