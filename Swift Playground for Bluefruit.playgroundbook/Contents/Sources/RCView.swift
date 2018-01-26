//
//  RCView.swift
//  
//
//  Created by Trevor Beaton on 8/23/17.
//  Copyright © 2017 Vanguard Logic LLC. All rights reserved.


import UIKit
import Foundation
import CoreBluetooth


public class RobotView:UIView{

    var scrollView:UIScrollView!
    var buttons = [UIButton]()
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))

    var robotName:String = ""

    override init (frame : CGRect) {
        super.init(frame : frame)
                setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    func setupView(){
        icon.image = #imageLiteral(resourceName: "robotAvatar.png")
        icon.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(icon)
        
        label.numberOfLines = 0
        label.text = NSLocalizedString("Robots\nAvailable", comment: "")
        label.textAlignment = NSTextAlignment.left;
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        scrollView.backgroundColor = #colorLiteral(red: 0.9688462615, green: 0.9830557704, blue: 1, alpha: 0)
        scrollView.contentSize = CGSize(width:200, height:50)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView)
        
    }
    

    
    public func addDiscoveredRobot(_ name:String){
        print("addDiscoveredRobot: \(name)")
        let button = UIButton(frame: CGRect(x:self.buttons.count*100 , y: 0, width: 150, height: 50))
        //        button.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "robotNameBg.png")) // # imageLiteral(resourceName: "robotNameBg.png")
        button.setTitle(name, for: UIControlState.normal)
        button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: UIControlState.normal)
        button.titleLabel!.font = UIFont.boldSystemFont(ofSize: 15)
        button.titleLabel!.textAlignment = .left
        button.titleLabel!.lineBreakMode = .byWordWrapping
        button.titleLabel!.numberOfLines = 2
        scrollView.addSubview(button)
        self.buttons.append(button)
    }

    
    

}
