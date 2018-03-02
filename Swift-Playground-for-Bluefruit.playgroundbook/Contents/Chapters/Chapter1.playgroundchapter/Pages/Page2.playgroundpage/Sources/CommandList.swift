//
// CommandList.swift
//
//  Created by Trevor Beaton on 12/14/17.
//  Copyright © 2018 Adafruit Industries All rights reserved.

import Foundation
import PlaygroundSupport

public func moveForward(){
    commandManager.moveForward()
}

public func moveBack(){
    commandManager.moveBack()
}

public func turnRight(){
    commandManager.turnRight()
}

public func turnLeft(){
    commandManager.turnLeft()
}

public func wait() {
    commandManager.pause()
}

public func exitProgram() {
  commandManager.exitProgram()
}

//public func wheelie(){
//    commandManager.moveBack()
//    commandManager.moveForward()
//}

public func dance(){
    commandManager.turnLeft()
    commandManager.turnLeft()
    commandManager.turnRight()
    commandManager.turnRight()
    commandManager.turnLeft()
    commandManager.turnLeft()
    commandManager.turnRight()
    commandManager.turnRight()
    commandManager.pause()
    commandManager.moveBack()
    commandManager.moveForward()
    commandManager.turnRight()
    commandManager.turnRight()
}

/*
 create a function reference that takes the duration time and sends it to the command manager function that will be sent to the RCCommand.Duration
 */

    public func moveForward(_ seconds: Int) {
        let page = PlaygroundPage.current
        if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
            let message = PlaygroundValue.integer(seconds)
            proxy.send(message)
            commandManager.moveForward()
        }
    }

    public func moveBack(_ seconds: Int) {
        let page = PlaygroundPage.current
        if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
            let message = PlaygroundValue.integer(seconds)
            proxy.send(message)
            commandManager.moveBack()
        }
    }

    public func turnLeft(_ seconds: Int) {
        let page = PlaygroundPage.current
        if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
            let message = PlaygroundValue.integer(seconds)
            proxy.send(message)
            commandManager.turnLeft()
        }
    }

    public func turnRight(_ seconds: Int) {
        let page = PlaygroundPage.current
        if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
            let message = PlaygroundValue.integer(seconds)
            proxy.send(message)
            commandManager.turnRight()
        }
}
    
    public func wait(_ seconds: Int) {
        let page = PlaygroundPage.current
        if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
            let message = PlaygroundValue.integer(seconds)
            proxy.send(message)
            commandManager.pause()
        }
}
