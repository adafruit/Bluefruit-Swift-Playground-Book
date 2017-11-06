
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

public func wheelie(){
    commandManager.moveBack()
    
    commandManager.moveForward()
    
}

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
       // let message2: PlaygroundValue = .string(CommandType.COMMAND_MOVE_FORWARD.rawValue)

        proxy.send(message)
        commandManager.moveForward()
    }
}

public func moveBack(_ seconds: Int) {
    let page = PlaygroundPage.current
    if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
        let message = PlaygroundValue.integer(seconds)
       // let message2: PlaygroundValue = .string(CommandType.COMMAND_MOVE_BACKWARD.rawValue)

        proxy.send(message)
        commandManager.moveBack()
    }
}

public func turnLeft(_ seconds: Int) {
    let page = PlaygroundPage.current
    if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
        let message = PlaygroundValue.integer(seconds)
        //let message2: PlaygroundValue = .string(CommandType.COMMAND_TURN_LEFT.rawValue)
        
        proxy.send(message)
        commandManager.turnLeft()
    }
}


public func turnRight(_ seconds: Int) {
    let page = PlaygroundPage.current
    if let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy {
        let message = PlaygroundValue.integer(seconds)
        //let message2: PlaygroundValue = .string(CommandType.COMMAND_TURN_RIGHT.rawValue)
        
        proxy.send(message)
        commandManager.turnRight()
    }
}







