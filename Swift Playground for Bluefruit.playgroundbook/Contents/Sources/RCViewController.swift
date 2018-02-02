//
//  RCViewController.swift
//
//  Copyright © 2017 Vanguard Logic LLC. All rights reserved.
//  Created by Trevor Beaton on 8/22/17.
//
//

import Foundation
import UIKit
import WebKit
import CoreBluetooth
import PlaygroundSupport
import PlaygroundBluetooth

protocol ControllerPadViewControllerDelegate: class {
    func onSendControllerPadButtonStatus(tag: Int, isPressed: Bool)
}

var sendCommand : String?

public class RCViewController: UIViewController, UITextViewDelegate {
    //Data
    //Page ID
    var page:Int = 1
    //Data
    var bleView: PlaygroundBluetoothConnectionView!
    let bleViewDelegate = ConnectionViewDelegate()
    var btViewConstraints = [NSLayoutConstraint]()
    var isLandscape:Bool = true
    var isPortraitMode:Bool = true
    var rcBluetooth: RCBluetooth = RCBluetooth()
    var rcCommand: RCCommand = RCCommand()
    var commandsForAssessment:[PlaygroundValue] = [PlaygroundValue]()
    private let buttonPrefix = "!B"

    
    //Button Setup
    public var commentText:UITextView!
    var forwardButton : UIButton!
    var backButton: UIButton!
    var leftButton: UIButton!
    var rightButton: UIButton!
    var blePeripheral: CBPeripheral!
    
    // Data
    weak var delegate: ControllerPadViewControllerDelegate?
    
    func updateTextView() {
        let newLine = "\n"
        var newText = commentText.text!
        newText += printString
        commentText.text = newText
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public convenience init(_ page:Int = 1) {
        self.init(nibName: nil, bundle: nil)
        self.page = page
    }
    
    public override func  viewDidLoad() {
        super.viewDidLoad()
      
      
      rcBluetooth.onDataWritten = onCommandCompleted
        UISetup()
        self.commentText.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView),name:NSNotification.Name(rawValue: "Print"), object: nil)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator){
        super.viewWillTransition(to: size, with: coordinator)
        print("viewWillTransition:\(size)")
        if(size.width>size.height){
            setupPortraitView(size)
        }
        else{
            setupLandscapeView(size)
        }
    }

    fileprivate func sendTouchEvent(_ tag: Int, isPressed: Bool) {
        if let delegate = delegate {
        delegate.onSendControllerPadButtonStatus(tag: tag, isPressed: isPressed)
        }
    }
    
    
    // MARK: - Actions
    func onTouchDownForward(_ sender: UIButton) {
        sendTouchEvent(sender.tag, isPressed: true)
        let isPressed = true
       rcBluetooth.moveForward()
    }
    
  
    func onTouchUpForward(_ sender: UIButton) {
      let isPressed = false
        sendTouchEvent(sender.tag, isPressed: true)
      rcBluetooth.stopForward()
    
    }
    
    func onTouchDownBack(_ sender: UIButton) {
        sendTouchEvent(sender.tag, isPressed: true)
        let isPressed = true
      rcBluetooth.moveBack()
    }
    
    
    func onTouchUpBack(_ sender: UIButton) {
      sendTouchEvent(sender.tag, isPressed: true)
      let isPressed = false
        rcBluetooth.stopBack()
    }
    
    
    func onTouchDownRight(_ sender: UIButton) {
        sendTouchEvent(sender.tag, isPressed: true)
        let isPressed = true
        rcBluetooth.turnRight()
    }
    
    
    func onTouchUpRight(_ sender: UIButton) {
        let isPressed = false
        rcBluetooth.stopRight()
    }

    
    func onTouchDownLeft(_ sender: UIButton) {
        sendTouchEvent(sender.tag, isPressed: true)
        let isPressed = true
        rcBluetooth.turnLeft()
    }
    
    
    func onTouchUpLeft(_ sender: UIButton) {
        let isPressed = false
        rcBluetooth.stopLeft()

    }
    
    func addCommandToAssessmentArray(_ command:PlaygroundValue){
        printLog(newString: " addCommandToAssessmentArray: Phase #1 - Function is called")
        
        if(self.commandsForAssessment.count <= 30){
            self.commandsForAssessment.append(command)
            printLog(newString: " addCommandToAssessmentArray: Phase #2")
        }
        printLog(newString: " addCommandToAssessmentArray: Phase #3")
    }
    
    func processCommand(_ command:PlaygroundValue){
        printLog(newString: #function)
        rcCommand.sendRobotCommand(rcBluetooth, command)
    }
    
    func processCommandForDuration(_ item:PlaygroundValue){
        printLog(newString: #function)
        rcCommand.sendRobotDuration(item)
    }
    
    
    func onCommandCompleted(){
        printLog(newString: "Command Completed")
        self.sendMessage(.string(Constants.COMMAND_FINISHED))
    }
    
    func onCommandCompleted2(){
      commentText.text = "Test"
    }
    
    func UISetup() {
    
        
        isLandscape = (self.view.frame.width > self.view.frame.height)
        
        //Connecting Bluetooth View
        bleView = PlaygroundBluetoothConnectionView(centralManager: rcBluetooth.centralManager!)
        bleView.delegate = bleViewDelegate
        bleView.dataSource = bleViewDelegate
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
        self.rcBluetooth.centralManager!.connectToLastConnectedPeripheral()
        }
        self.view.addSubview(bleView)

        
        // Setup debug log
        commentText = UITextView(frame: CGRect(x: 0, y: 350, width: 520, height: 320))
        commentText.isEditable = false
        commentText.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        commentText.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        commentText.font = UIFont.init(name: "Menlo", size: 15)
        commentText.textAlignment = .left
        commentText.textContainer.lineBreakMode = .byWordWrapping
        commentText.layer.borderWidth = 0
        commentText.layer.cornerRadius = 18
      
        view.addSubview(commentText)
        
      
        forwardButton = UIButton(frame: CGRect(x: 320, y: 70, width: 83, height: 60))
        forwardButton.setTitle("Forward", for: .normal)
        forwardButton.setTitleColor(UIColor.white, for: .normal)
        forwardButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
      
      // Rounded button
      
      forwardButton.layer.borderWidth = 0
      
      forwardButton.layer.cornerRadius = 18
      
      forwardButton.tag = 5
  
        forwardButton.addTarget(self, action: #selector(onTouchDownForward(_:)), for: .touchDown)
       
        forwardButton.addTarget(self, action: #selector(onTouchUpForward(_:)), for: .touchUpInside)
        
        forwardButton.addTarget(self, action: #selector(onTouchUpForward(_:)), for: .touchDragExit)
        
        forwardButton.addTarget(self, action: #selector(onTouchUpForward(_:)), for: .touchCancel)
        
        
       view.addSubview(forwardButton)


        backButton = UIButton(frame: CGRect(x: 320, y: 210, width: 83, height: 60))
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)

        //   Rounded button
        backButton.layer.borderWidth = 0
        backButton.layer.cornerRadius = 18
        backButton.tag = 6
        backButton.addTarget(self, action: #selector(onTouchDownBack(_:)), for: .touchDown)
        
        backButton.addTarget(self, action: #selector(onTouchUpBack(_:)), for: .touchUpInside)
        
        backButton.addTarget(self, action: #selector(onTouchUpBack(_:)), for: .touchDragExit)
        
        backButton.addTarget(self, action: #selector(onTouchUpBack(_:)), for: .touchCancel)
        view.addSubview(backButton)
//
//

        leftButton = UIButton(frame: CGRect(x: 270, y: 140, width: 83, height: 60))
        leftButton.setTitle("Left", for: .normal)
        leftButton.setTitleColor(UIColor.white, for: .normal)
        leftButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        leftButton.tag = 7
        //   Rounded button
        leftButton.layer.borderWidth = 0
        leftButton.layer.cornerRadius = 18
        leftButton.addTarget(self, action: #selector(onTouchDownLeft(_:)), for: .touchDown)
        
        leftButton.addTarget(self, action: #selector(onTouchUpLeft(_:)), for: .touchUpInside)
        
        leftButton.addTarget(self, action: #selector(onTouchUpLeft(_:)), for: .touchDragExit)
        
        leftButton.addTarget(self, action: #selector(onTouchUpLeft(_:)), for: .touchCancel)
        view.addSubview(leftButton)

        
        
        rightButton = UIButton(frame: CGRect(x: 375, y: 140, width: 83, height: 60))
        rightButton.setTitle("Right", for: .normal)
        rightButton.setTitleColor(UIColor.white, for: .normal)
        rightButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        //   Rounded button
        rightButton.layer.borderWidth = 0
        rightButton.layer.cornerRadius = 18
        rightButton.tag = 8
        rightButton.addTarget(self, action: #selector(onTouchDownRight(_:)), for: .touchDown)
        
        rightButton.addTarget(self, action: #selector(onTouchUpRight(_:)), for: .touchUpInside)
        
        rightButton.addTarget(self, action: #selector(onTouchUpRight(_:)), for: .touchDragExit)
        
        rightButton.addTarget(self, action: #selector(onTouchUpRight(_:)), for: .touchCancel)

        
        view.addSubview(rightButton)

       
        if(isLandscape){
            setupLandscapeView(CGSize(width: self.view.frame.width/2, height: self.view.frame.height))
        }
        else{
            setupPortraitView(CGSize(width: self.view.frame.width, height: self.view.frame.height/2))
      }
        
    }
   
    
    func setupLandscapeView(_ size:CGSize){
        print("setupLandscapeView():\(size)")
        isLandscape = true
    
        NSLayoutConstraint.deactivate(btViewConstraints)
        btViewConstraints.removeAll()
        btViewConstraints.append(bleView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20))
        btViewConstraints.append(bleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20))
        NSLayoutConstraint.activate(btViewConstraints)
    }
    
    func setupPortraitView(_ size:CGSize){
        print("setupPortraitView():\(size)")
        isLandscape = false
      
        NSLayoutConstraint.deactivate(btViewConstraints)
        btViewConstraints.removeAll()
        btViewConstraints.append(bleView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 75))
        btViewConstraints.append(bleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20))
        NSLayoutConstraint.activate(btViewConstraints)
    }
    
    func exitProgram(){
        // All commands executed
        let message: PlaygroundValue = .array(commandsForAssessment)
        sendMessage(message)
        commandsForAssessment.removeAll()
    }
    
    class ConnectionViewDelegate: PlaygroundBluetoothConnectionViewDelegate, PlaygroundBluetoothConnectionViewDataSource {
       
        //PlaygroundBluetoothConnectionViewDataSource
        public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, itemForPeripheral peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?) -> PlaygroundBluetoothConnectionView.Item {
            // Displays UI elements for connectivity
            let name = peripheral.name ?? NSLocalizedString("Unknown Device", comment: "")
            let icon = UIImage(imageLiteralResourceName:"Images/adafruit_logo_small copy.png")
            let issueIcon = icon
            return PlaygroundBluetoothConnectionView.Item(name: name, icon: icon, issueIcon: issueIcon, firmwareStatus: nil, batteryLevel: nil)
        }

        // MARK: PlaygroundBluetoothConnectionView Delegate
        public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, shouldDisplayDiscovered peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double) -> Bool {
            // Filter out peripheral items (optional)
            
            return true
        }

        public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, titleFor state: PlaygroundBluetoothConnectionView.State) -> String {
            // Provide a localized title for the given state of the connection view.
            switch state {
            case .noConnection:
                return NSLocalizedString("Connect RC", comment: "")
            case .connecting:
                return NSLocalizedString("Connecting to RC", comment: "")
            case .searchingForPeripherals:
                return NSLocalizedString("Searching for RC", comment: "")
            case .selectingPeripherals:
                return NSLocalizedString("Select your RC", comment: "")
            case .connectedPeripheralFirmwareOutOfDate:
                return NSLocalizedString("Connect to a Different RC", comment: "")
            }
        }

        public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, firmwareUpdateInstructionsFor peripheral: CBPeripheral) -> String {
            // Provide firmware update instructions.
            return "Firmware update instructions here."
        }
   
        func connectionView(_ connectionView: PlaygroundBluetoothConnectionView,
                            willDisconnectFrom peripheral: CBPeripheral) {
        }
        
        func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, shouldConnectTo peripheral: CBPeripheral, withAdvertisementData advertisementData: [String: Any]?, rssi: Double) -> Bool {
            return true
        }
    }
}


extension RCViewController: PlaygroundLiveViewMessageHandler {
    
    public func liveViewMessageConnectionOpened(){
        printLog(newString: "<Live View Message Connection Made>  ")
        
       }
    
    public func liveViewMessageConnectionClosed() {
        commandsForAssessment.removeAll()
        //PlaygroundPage.current.finishExecution()
    }
    
    //Recieve message from Constant.swift
    public func receive(_ message: PlaygroundValue) {
       printLog(newString: #function)
    
    if case let .string(command) = message {
        if command.isEqual(CommandType.COMMAND_EXIT_PROGRAM.rawValue){
            exitProgram()
        }
        
        if rcBluetooth.isConnected {
            printLog(newString: "Bluetooth is Online.")
            addCommandToAssessmentArray(message)
           processCommand(message)
            printLog(newString: "\(message)")
            printLog(newString: "Array count \(commandsForAssessment.count)")
            printLog(newString: "First in the arrray is... \(commandsForAssessment[0])")
    }
            
            else{ // Connection not ready
                printLog(newString: "Connect To RC Before Sending Commands.")
            }
        }
    
   else if case let .dictionary(dict) = message { // Connect to robot
            printLog(newString: "Send message; Command String attempt made")
            processCommand(message)
            addCommandToAssessmentArray(message)
        }
        
        else if case let .boolean(result) = message { // Program Results
          //  programStateImage.stopAnimating()
            //isShowingResult = true
//            if result{
//                myPrint("Receive result from Constants.swift: feedback_success")
//                setCommandAnimationAsync(CommandType.FEEDBACK_SUCCESS)
//                if robotConnection.isConnected {
//                    robotCommand.sendRobotCommand(robotConnection, PlaygroundValue.string(CommandType.COMMAND_SOUND_AWESOME.rawValue))
//                }
//            }
//            else{
//                myPrint("Receive result from Constants.swift: feedback_fail")
//                setCommandAnimationAsync(CommandType.FEEDBACK_FAIL)
//                if robotConnection.isConnected {
//                    robotCommand.sendRobotCommand(robotConnection, PlaygroundValue.string(CommandType.COMMAND_SOUND_WHA.rawValue))
//                }
//            }
            sendMessage(.string(Constants.PROGRAM_FINISHED))
    }
    
    else if case let item = message {
        
        if rcBluetooth.isConnected {
            printLog(newString: "Integer Sent: \(message)")
            addCommandToAssessmentArray(message)
            processCommandForDuration(message)
            printLog(newString: "Array count \(commandsForAssessment.count)")
            printLog(newString: "First in the arrray is... \(commandsForAssessment[0])")
            
        }  else{ // Connection not ready
            printLog(newString: "Send message; (PROGRAM_FINISHED) attempt made")
            sendMessage(.string(Constants.PROGRAM_FINISHED))
        }
        
    }
        
}
    
    public func sendMessage(_ message: PlaygroundValue) {
        printLog(newString: "<Send message to Contants.swift>")
       rcCommand.durationReset()
        send(message)
    }
}

 
