//
//  RCViewController.swift
//
//  Copyright © 2018 Adafruit Industries All rights reserved.
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

public class RCViewController: UIViewController, UITextViewDelegate, PlaygroundLiveViewSafeAreaContainer {
    //Data
    //Page ID
    var page: Int = 1
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
    public let logView = UITextView(frame: CGRect.zero)
    public let clearButton = UIButton(frame: CGRect.zero)
    var forwardButton: UIButton!
    var backButton: UIButton!
    var leftButton: UIButton!
    var rightButton: UIButton!
    var blePeripheral: CBPeripheral!
    
    // Data
    weak var delegate: ControllerPadViewControllerDelegate?
    
    func updateTextView() {
        let newLine = "\n"
        var newText = logView.text!
        newText += printString
        logView.text = newText
        scrollToBottom()
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
//        self.view.clipsToBounds = true
//        self.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public override func  viewDidLoad() {
        super.viewDidLoad()
        
        rcBluetooth.onDataWritten = onCommandCompleted
        UISetup()
        
        self.logView.delegate = self
        
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
        //   printLog("\(size)")
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
    
    public func scrollToBottom() {
        let stringLength:Int = self.logView.text.count
        self.logView.scrollRangeToVisible(NSMakeRange(stringLength-1, 0))
    }
    
    func onTouchUpClear(_ sender: UIButton) {
        sendTouchEvent(sender.tag, isPressed: true)
        logView.text = ""
    }
    
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
    
    func processCommand(_ command:PlaygroundValue){
        //    printLog(#function)
        printLog("--> adding assessment val \(command)")
        self.commandsForAssessment.append(command)
        rcCommand.sendRobotCommand(rcBluetooth, command)
    }
    
    func onCommandCompleted(){
        //   printLog("Command Completed")
        self.send(.string(Constants.COMMAND_FINISHED))
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
        
        // Log View
        logView.translatesAutoresizingMaskIntoConstraints = false
        logView.isEditable = false
        logView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        logView.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        logView.font = UIFont.init(name: "Avenir", size: 15)
        logView.textAlignment = .left
        logView.textContainer.lineBreakMode = .byWordWrapping
        logView.layer.borderWidth = 0
        logView.layer.cornerRadius = 18
        view.addSubview(logView)
        view.addConstraints(generateConstraintsForLogView())
        
        // Clear button
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(imageLiteralResourceName:"Images/refresh.png") as UIImage?
        clearButton.setImage(image, for: UIControlState.normal)
        clearButton.alpha = 0.5
        clearButton.backgroundColor = UIColor.clear
        clearButton.layer.borderWidth = 0
        clearButton.layer.cornerRadius = 9
        clearButton.tag = 9
        clearButton.addTarget(self, action: #selector(onTouchUpClear(_:)), for: .touchUpInside)
        view.addSubview(clearButton)
        view.addConstraints(generateConstraintsForClearButton())
        
        // Forward button
        forwardButton = UIButton(frame: CGRect(x: 320, y: 70, width: 83, height: 60))
        forwardButton.setTitle("Forward", for: .normal)
        forwardButton.setTitleColor(UIColor.white, for: .normal)
        forwardButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        forwardButton.layer.borderWidth = 0
        forwardButton.layer.cornerRadius = 18
        forwardButton.tag = 5
        forwardButton.addTarget(self, action: #selector(onTouchDownForward(_:)), for: .touchDown)
        forwardButton.addTarget(self, action: #selector(onTouchUpForward(_:)), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(onTouchUpForward(_:)), for: .touchDragExit)
        forwardButton.addTarget(self, action: #selector(onTouchUpForward(_:)), for: .touchCancel)
        view.addSubview(forwardButton)
        
        // Back button
        backButton = UIButton(frame: CGRect(x: 320, y: 210, width: 83, height: 60))
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        backButton.layer.borderWidth = 0
        backButton.layer.cornerRadius = 18
        backButton.tag = 6
        backButton.addTarget(self, action: #selector(onTouchDownBack(_:)), for: .touchDown)
        backButton.addTarget(self, action: #selector(onTouchUpBack(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(onTouchUpBack(_:)), for: .touchDragExit)
        backButton.addTarget(self, action: #selector(onTouchUpBack(_:)), for: .touchCancel)
        view.addSubview(backButton)
        
        // Left button
        leftButton = UIButton(frame: CGRect(x: 270, y: 140, width: 83, height: 60))
        leftButton.setTitle("Left", for: .normal)
        leftButton.setTitleColor(UIColor.white, for: .normal)
        leftButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        leftButton.tag = 7
        leftButton.layer.borderWidth = 0
        leftButton.layer.cornerRadius = 18
        leftButton.addTarget(self, action: #selector(onTouchDownLeft(_:)), for: .touchDown)
        leftButton.addTarget(self, action: #selector(onTouchUpLeft(_:)), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(onTouchUpLeft(_:)), for: .touchDragExit)
        leftButton.addTarget(self, action: #selector(onTouchUpLeft(_:)), for: .touchCancel)
        view.addSubview(leftButton)
        
        // Right button
        rightButton = UIButton(frame: CGRect(x: 375, y: 140, width: 83, height: 60))
        rightButton.setTitle("Right", for: .normal)
        rightButton.setTitleColor(UIColor.white, for: .normal)
        rightButton.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
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
    
    private func generateConstraintsForLogView() -> [NSLayoutConstraint] {
        
        let constraintBottom = NSLayoutConstraint(item: self.logView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: view,
                                                  attribute: .bottom,
                                                  multiplier: 1.0,
                                                  constant: -70.0)
        
        //using this constraint instead of the above will prevent run button from blocking log window
//        let constraintBottom = logView.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor, constant: 0.0)
        
        let constraintLeading = NSLayoutConstraint(item: self.logView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: view,
                                                   attribute: .leading,
                                                   multiplier: 1.0,
                                                   constant: 20.0)
        
        let constraintTrailing = NSLayoutConstraint(item: self.logView,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: view,
                                                    attribute: .trailing,
                                                    multiplier: 1.0,
                                                    constant: -20.0)
        
        let constraintHeight = NSLayoutConstraint(item: self.logView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 142.0)
        
        return [constraintBottom, constraintLeading, constraintTrailing, constraintHeight]
        
    }
    
    private func generateConstraintsForClearButton() -> [NSLayoutConstraint] {
        
        // Create constraints for the clear button
        let constraintTop = NSLayoutConstraint(item: self.clearButton,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: self.logView,
                                                  attribute: .top,
                                                  multiplier: 1.0,
                                                  constant: 10.0)
        
        let constraintTrailing = NSLayoutConstraint(item: self.clearButton,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: view,
                                                    attribute: .trailing,
                                                    multiplier: 1.0,
                                                    constant: -32.0)  //negative because it's moving left
        
        let constraintHeight = NSLayoutConstraint(item: self.clearButton,
                                                  attribute: .height,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1.0,
                                                  constant: 22.0)
        
        let constraintWidth = NSLayoutConstraint(item: self.clearButton,
                                                 attribute: .width,
                                                 relatedBy: .equal,
                                                 toItem: nil,
                                                 attribute: .notAnAttribute,
                                                 multiplier: 1.0,
                                                 constant: 22.0)
        
        // Return the constraints in an array
        return [constraintTop, constraintWidth, constraintTrailing, constraintHeight]
    }
    
    //- LANDSCAPE ORIENTATION
    func setupLandscapeView(_ size:CGSize){
        isLandscape = true
        
        NSLayoutConstraint.deactivate(btViewConstraints)
        btViewConstraints.removeAll()
        btViewConstraints.append(bleView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20))
        btViewConstraints.append(bleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20))
        NSLayoutConstraint.activate(btViewConstraints)
        
        //- Comment Log mark
        scrollToBottom()
        
        logView.font = UIFont.init(name: "Avenir Next", size: 17)
        
        //-Button Frame Update For Landscape Mode
        
        forwardButton.frame = CGRect(x: 320, y: 70, width: 83, height: 60)
        backButton.frame = CGRect(x: 320, y: 210, width: 83, height: 60)
        leftButton.frame = CGRect(x: 270, y: 140, width: 83, height: 60)
        rightButton.frame = CGRect(x: 375, y: 140, width: 83, height: 60)
    }
    
    func setupPortraitView(_ size:CGSize){
        isLandscape = false
        
        NSLayoutConstraint.deactivate(btViewConstraints)
        btViewConstraints.removeAll()
        btViewConstraints.append(bleView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 75))
        btViewConstraints.append(bleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20))
        NSLayoutConstraint.activate(btViewConstraints)
        
        
        scrollToBottom()
        //- Comment Log
        
        //  logView.frame = CGRect(x: size.width*32/100, y: size.height*60/100,width: size.width*37/100, height: size.height*27/100)
        
        logView.font = UIFont.init(name: "Avenir Next", size: 17)
        
        //  scrollToBottom()
        //- Button Frame Update For Portrait Mode
        
        forwardButton.frame = CGRect(x: 570, y: 85, width: 83, height: 60)
        backButton.frame = CGRect(x: 570, y: 215, width: 83, height: 60)
        leftButton.frame = CGRect(x: 520, y: 150, width: 83, height: 60)
        rightButton.frame = CGRect(x: 620, y: 150, width: 83, height: 60)
    }
    
    
    func exitProgram(){
        // All commands executed
        let message: PlaygroundValue = .array(commandsForAssessment)
        send(message)
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
        
        func connectionView(_ connectionView: PlaygroundBluetoothConnectionView,
                            shouldConnectTo peripheral: CBPeripheral,
                            withAdvertisementData advertisementData: [String: Any]?,
                            rssi: Double) -> Bool {
            return true
        }
    }
}


extension RCViewController: PlaygroundLiveViewMessageHandler {
    
    public func liveViewMessageConnectionOpened(){
        //      printLog("<Live View Message Connection Made>  ")
        
    }
    
    public func liveViewMessageConnectionClosed() {
        commandsForAssessment.removeAll()
        //PlaygroundPage.current.finishExecution()
    }
    
    //Receive message from LiveView
    public func receive(_ message: PlaygroundValue) {
        
        //If there's no BT connection, abort mission
        if rcBluetooth.isConnected == false {
            printLog("Connect To Car Before Sending Commands")
//            send(.string(Constants.PROGRAM_FINISHED))
            return
        }
        
        //If it's a string …
        if case let .string(command) = message {
            if command.isEqual(CommandType.COMMAND_EXIT_PROGRAM.rawValue){
                exitProgram()
            }
            processCommand(message)
        }
            
        //If it's an integer …
        else if case let .integer(command) = message {
            processCommand(message)
        }
            
        //If it's a dictionary …
        else if case let .dictionary(dict) = message { // Connect to robot
            printLog("Send message; Command String attempt made")
            processCommand(message)
        }
            
        //If it's a boolean …
        else if case let .boolean(result) = message {
            send(.string(Constants.PROGRAM_FINISHED))
        }
        
    }
    
}


