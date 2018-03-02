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

public class RCViewController: UIViewController, UITextViewDelegate, PlaygroundLiveViewSafeAreaContainer, PlaygroundBluetoothConnectionViewDelegate, PlaygroundBluetoothConnectionViewDataSource {
    //Data
    //Page ID
    var page: Int = 1
    //Data
    var bleView: PlaygroundBluetoothConnectionView!
    let carImageView = UIImageView(image: UIImage(imageLiteralResourceName:"Images/myminiracecar-vector1-500px.png") as UIImage?)
//    let bleViewDelegate = ConnectionViewDelegate()
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
    var buttons: [UIButton] = []
    let buttonDisabledColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
    let buttonEnabledColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    let controlPadView = UIView(frame: CGRect.zero)
    var blePeripheral: CBPeripheral!
    
    // Data
    weak var delegate: ControllerPadViewControllerDelegate?
    
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
        
        //subscribe to bluetooth connection notifications
        NotificationCenter.default.addObserver(self, selector: #selector(respondToConnection),name:NSNotification.Name(rawValue: "Bluetooth Connected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(respondToDisconnection),name:NSNotification.Name(rawValue: "Bluetooth Disconnected"), object: nil)
        
        //subscribe to command notifications
        NotificationCenter.default.addObserver(self, selector: #selector(respondToCommand),name:NSNotification.Name(rawValue: "Command"), object: nil)
        
        
        //subscribe to print log notifications
        NotificationCenter.default.addObserver(self, selector: #selector(updateTextView),name:NSNotification.Name(rawValue: "Print"), object: nil)
        
        //subscribe to keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
    
    //respond to print log calls
    func updateTextView() {
        let newLine = "\n"
        var newText = logView.text!
        newText += printString
        logView.text = newText
        scrollToBottom()
    }
    
    // respond to bluetooth connection status changes
    @objc func respondToConnection() {
        printLog("Bluefruit device connected")
        enableControlButtons(true)
    }
    
    @objc func respondToDisconnection() {
        printLog("Bluefruit device disconnected")
        enableControlButtons(false)
    }
    
    func enableControlButtons(_ enabled:Bool) {
        for button in buttons{
            button.isEnabled = enabled
            if enabled{
                button.backgroundColor = buttonEnabledColor
            }
            else {
                button.backgroundColor = buttonDisabledColor
            }
        }
    }
    
    //respond to commands
    @objc func respondToCommand(notification: NSNotification){
        
        // Adjust UI buttons for command
        
        let info = notification.object as! Dictionary<String, AnyObject>
        let type:String = (info["Command"] as! String)
        
//        printLog("command event = \(type)")
        
        switch type {
        case CommandType.COMMAND_MOVE_FORWARD.rawValue:
            forwardButton.isSelected = true
            forwardButton.layer.borderWidth = 1
            break
        case CommandType.COMMAND_MOVE_BACKWARD.rawValue:
            backButton.isSelected = true
            backButton.layer.borderWidth = 1
            
            break
        case CommandType.COMMAND_TURN_LEFT.rawValue:
            leftButton.isSelected = true
            leftButton.layer.borderWidth = 1
            break
        case CommandType.COMMAND_TURN_RIGHT.rawValue:
            rightButton.isSelected = true
            rightButton.layer.borderWidth = 1
            break
        case "Stop":
            for button in buttons{
                button.isSelected = false
                button.layer.borderWidth = 0
            }
            break
        default:
            break
        }
    }
    
    // respond to keyboard changes
    @objc func keyboardWillShow(notification: NSNotification) {
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        printLog("keyboardWillShow height = \(targetFrame.height)")
        if targetFrame.height >= 60.0{
            logView.isHidden = true
            clearButton.isHidden = true
        }
        else {
            logView.isHidden = false
            clearButton.isHidden = false
        }
    }

    @objc func keyboardWillHide(notification: NSNotification){
//        printLog("keyboardWillHide")
        logView.isHidden = false
        clearButton.isHidden = false
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
//        printLog("--> adding assessment val \(command)")
        self.commandsForAssessment.append(command)
        rcCommand.sendRobotCommand(rcBluetooth, command)
    }
    
    func onCommandCompleted(){
        //   printLog("Command Completed")
        self.send(.string(Constants.COMMAND_FINISHED))
    }
    
    func UISetup() {
        
        isLandscape = (self.view.frame.width > self.view.frame.height)
        
        // Log View
        logView.translatesAutoresizingMaskIntoConstraints = false
        logView.isEditable = false
        logView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        logView.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        logView.font = UIFont.init(name: "Avenir", size: 15)
        logView.textAlignment = .left
        logView.textContainer.lineBreakMode = .byWordWrapping
        logView.layer.borderWidth = 0
        logView.layer.cornerRadius = 12
        view.addSubview(logView)
        view.addConstraints(generateConstraintsForLogView())
        
        // Clear button
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(imageLiteralResourceName:"Images/refresh.png") as UIImage?
        clearButton.setImage(image, for: UIControlState.normal)
        clearButton.alpha = 0.5
        clearButton.backgroundColor = UIColor.clear
        clearButton.layer.borderWidth = 0
        clearButton.tag = 9
        clearButton.addTarget(self, action: #selector(onTouchUpClear(_:)), for: .touchUpInside)
        view.addSubview(clearButton)
        view.addConstraints(generateConstraintsForClearButton())
        
        // Forward button
        forwardButton = UIButton(frame: CGRect(x: 320, y: 70, width: 83, height: 60))
        forwardButton.setTitle("Forward", for: .normal)
        forwardButton.setTitleColor(UIColor.white, for: .normal)
        forwardButton.setTitleColor(UIColor.lightGray, for: .disabled)
        forwardButton.setTitleColor(buttonEnabledColor, for: UIControlState.selected)
        forwardButton.backgroundColor = buttonDisabledColor
        forwardButton.layer.borderWidth = 0
        forwardButton.layer.borderColor = UIColor.white.cgColor
        forwardButton.layer.cornerRadius = 12
        forwardButton.tag = 5
        forwardButton.addTarget(self, action: #selector(onTouchDownForward(_:)), for: .touchDown)
        forwardButton.addTarget(self, action: #selector(onTouchUpForward(_:)), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(onTouchUpForward(_:)), for: .touchDragExit)
        forwardButton.addTarget(self, action: #selector(onTouchUpForward(_:)), for: .touchCancel)
        forwardButton.isEnabled = false
        view.addSubview(forwardButton)
        
        // Back button
        backButton = UIButton(frame: CGRect(x: 320, y: 210, width: 83, height: 60))
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitleColor(UIColor.lightGray, for: .disabled)
        backButton.setTitleColor(buttonEnabledColor, for: UIControlState.selected)
        backButton.backgroundColor = buttonDisabledColor
        backButton.layer.borderWidth = 0
        backButton.layer.borderColor = UIColor.white.cgColor
        backButton.layer.cornerRadius = 12
        backButton.tag = 6
        backButton.addTarget(self, action: #selector(onTouchDownBack(_:)), for: .touchDown)
        backButton.addTarget(self, action: #selector(onTouchUpBack(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(onTouchUpBack(_:)), for: .touchDragExit)
        backButton.addTarget(self, action: #selector(onTouchUpBack(_:)), for: .touchCancel)
        backButton.isEnabled = false
        view.addSubview(backButton)
        
        // Left button
        leftButton = UIButton(frame: CGRect(x: 270, y: 140, width: 83, height: 60))
        leftButton.setTitle("Left", for: .normal)
        leftButton.setTitleColor(UIColor.white, for: .normal)
        leftButton.setTitleColor(UIColor.lightGray, for: .disabled)
        leftButton.setTitleColor(buttonEnabledColor, for: UIControlState.selected)
        leftButton.backgroundColor = buttonDisabledColor
        leftButton.tag = 7
        leftButton.layer.borderWidth = 0
        leftButton.layer.borderColor = UIColor.white.cgColor
        leftButton.layer.cornerRadius = 12
        leftButton.addTarget(self, action: #selector(onTouchDownLeft(_:)), for: .touchDown)
        leftButton.addTarget(self, action: #selector(onTouchUpLeft(_:)), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(onTouchUpLeft(_:)), for: .touchDragExit)
        leftButton.addTarget(self, action: #selector(onTouchUpLeft(_:)), for: .touchCancel)
        leftButton.isEnabled = false
        view.addSubview(leftButton)
        
        // Right button
        rightButton = UIButton(frame: CGRect(x: 375, y: 140, width: 83, height: 60))
        rightButton.setTitle("Right", for: .normal)
        rightButton.setTitleColor(UIColor.white, for: .normal)
        rightButton.setTitleColor(UIColor.lightGray, for: .disabled)
        rightButton.setTitleColor(buttonEnabledColor, for: UIControlState.selected)
        rightButton.backgroundColor = buttonDisabledColor
        rightButton.layer.borderWidth = 0
        rightButton.layer.borderColor = UIColor.white.cgColor
        rightButton.layer.cornerRadius = 12
        rightButton.tag = 8
        rightButton.addTarget(self, action: #selector(onTouchDownRight(_:)), for: .touchDown)
        rightButton.addTarget(self, action: #selector(onTouchUpRight(_:)), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(onTouchUpRight(_:)), for: .touchDragExit)
        rightButton.addTarget(self, action: #selector(onTouchUpRight(_:)), for: .touchCancel)
        rightButton.isEnabled = false
        view.addSubview(rightButton)
        
        //store buttons for group enabling/disabling
        buttons = [forwardButton, backButton, leftButton, rightButton]
        
        //add control pad view to view
//        controlPadView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(controlPadView)
//        view.addConstraints(generateConstraintsForControlPadView(toView: view))
        
        //add car image
//        carImageView.translatesAutoresizingMaskIntoConstraints = false
//        carImageView.contentMode = UIViewContentMode.scaleAspectFit
//        view.addSubview(carImageView)
//        view.addConstraints(generateConstraintsForCarImageView(toView: view))
        
        //Add Connecting Bluetooth View
        bleView = PlaygroundBluetoothConnectionView(centralManager: rcBluetooth.centralManager!)
        bleView.delegate = self
        bleView.dataSource = self
        //        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
        //            self.rcBluetooth.centralManager!.connectToLastConnectedPeripheral()   //UI can't respond to this change!
        //        }
        self.view.addSubview(bleView)
        
        if(isLandscape){
            setupLandscapeView(CGSize(width: self.view.frame.width/2, height: self.view.frame.height))
        }
        else{
            setupPortraitView(CGSize(width: self.view.frame.width, height: self.view.frame.height/2))
        }
        
    }
    
    private func generateConstraintsForLogView() -> [NSLayoutConstraint] {
        
//        let constraintBottom = NSLayoutConstraint(item: self.logView,
//                                                  attribute: .bottom,
//                                                  relatedBy: .equal,
//                                                  toItem: view,
//                                                  attribute: .bottom,
//                                                  multiplier: 1.0,
//                                                  constant: -70.0)
        
        //using this constraint instead of the above will prevent run button from blocking log window
        let constraintBottom = logView.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor, constant: 0.0)
        
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
    
    private func generateConstraintsForCarImageView(toView:UIView) -> [NSLayoutConstraint] {
        
        // Create constraints for the clear button
        let constraintTop = NSLayoutConstraint(item: self.carImageView,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: toView,
                                               attribute: .top,
                                               multiplier: 1.0,
                                               constant: 10.0)
        
        let constraintBottom = NSLayoutConstraint(item: self.carImageView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: logView,
                                                  attribute: .top,
                                                  multiplier: 1.0,
                                                  constant: -10.0)
        
        let constraintLeading = NSLayoutConstraint(item: self.carImageView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: toView,
                                                   attribute: .leading,
                                                   multiplier: 1.0,
                                                   constant: 10.0)
        
        let constraintTrailing = NSLayoutConstraint(item: self.carImageView,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: toView,
                                                    attribute: .centerX,
                                                    multiplier: 1.0,
                                                    constant: -10.0)
        
        // Return the constraints in an array
        return [constraintTop, constraintBottom, constraintLeading, constraintTrailing]
    }
    
    private func generateConstraintsForControlPadView(toView:UIView) -> [NSLayoutConstraint] {
        
        // Create constraints for the clear button
        let constraintTop = NSLayoutConstraint(item: self.controlPadView,
                                               attribute: .top,
                                               relatedBy: .equal,
                                               toItem: toView,
                                               attribute: .top,
                                               multiplier: 1.0,
                                               constant: 10.0)
        
        let constraintBottom = NSLayoutConstraint(item: self.controlPadView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: logView,
                                                  attribute: .top,
                                                  multiplier: 1.0,
                                                  constant: -10.0)
        
        let constraintLeading = NSLayoutConstraint(item: self.controlPadView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: toView,
                                                   attribute: .centerX,
                                                   multiplier: 1.0,
                                                   constant: 10.0)
        
        let constraintTrailing = NSLayoutConstraint(item: self.controlPadView,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: toView,
                                                    attribute: .trailing,
                                                    multiplier: 1.0,
                                                    constant: -10.0)
        
        // Return the constraints in an array
        return [constraintTop, constraintBottom, constraintLeading, constraintTrailing]
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
        
//        printLog("exitProgram command count = \(commandsForAssessment.count)")
        //prevent evaluation if no commands sent
        if commandsForAssessment.count == 0 {
            enableControlButtons(true)
            return
        }
        
        // All commands executed
        let message: PlaygroundValue = .array(commandsForAssessment)
        send(message)
        commandsForAssessment.removeAll()
    }
    
//    class ConnectionViewDelegate: PlaygroundBluetoothConnectionViewDelegate, PlaygroundBluetoothConnectionViewDataSource {
    
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
                return NSLocalizedString("Connect", comment: "")
            case .connecting:
                return NSLocalizedString("Connecting …", comment: "")
            case .searchingForPeripherals:
                return NSLocalizedString("Searching …", comment: "")
            case .selectingPeripherals:
                return NSLocalizedString("Select your car", comment: "")
            case .connectedPeripheralFirmwareOutOfDate:
                return NSLocalizedString("Connect to a different car", comment: "")
            }
        }
        
        public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, firmwareUpdateInstructionsFor peripheral: CBPeripheral) -> String {
            // Provide firmware update instructions.
            return "Please update device firmware."
        }
        
        public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, willDisconnectFrom peripheral: CBPeripheral) {
            
            respondToDisconnection()
        }
        
        public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, shouldConnectTo peripheral: CBPeripheral, withAdvertisementData advertisementData: [String: Any]?) -> Bool {
            
            respondToConnection()
            
            return true
        }
    
//    }
}


extension RCViewController: PlaygroundLiveViewMessageHandler {
    
    public func liveViewMessageConnectionOpened(){
//        printLog("<liveViewMessageConnectionOpened>")
        self.enableControlButtons(false)
    }
    
    public func liveViewMessageConnectionClosed() {
        commandsForAssessment.removeAll()
//        printLog("<liveViewMessageConnectionClosed>")
//        enableControlButtons(true)
    }
    
    //Receive message from LiveView
    public func receive(_ message: PlaygroundValue) {
        
//        printLog("received: \(message)")
        
        //If there's no BT connection, abort mission
        if rcBluetooth.isConnected == false {
            printLog("Connect to car before sending commands")
            exitProgram()
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


