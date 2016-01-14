//
//  PairSingleDeviceViewController.swift
//  gameApp
//
//  Created by Liza Girsova on 9/23/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa

class PairSingleDeviceViewController: NSViewController {

    @IBOutlet var pairDeviceView: NSView!
    @IBOutlet var playerLabel: NSTextField!
    @IBOutlet var acceptButton: NSButton!
    
    var serviceManager: ServiceManager?
    var gameViewController: GameViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.enterFullScreenMode(NSScreen.mainScreen()!, withOptions:nil)
        //self.view.window?.hidesOnDeactivate = true
        
        let viewLayer = CALayer()
        viewLayer.backgroundColor = CGColorCreateGenericRGB(0.000, 0.114, 0.212, 1.00)
        pairDeviceView.wantsLayer = true
        pairDeviceView.layer = viewLayer
        self.view.addSubview(pairDeviceView)
        
        // Do view setup here.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPeerInvite:", name: Constants.Notifications.addPeerInvite, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchToGameView", name: Constants.Notifications.switchToGameView, object: nil)
        serviceManager = ServiceManager()
    }
    
    func addPeerInvite(notification: NSNotification) {
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let peerId = userInfo["peerId"]
    }
    
    func switchToGameView() {
        dispatch_async(dispatch_get_main_queue(), {
        self.gameViewController = GameViewController(nibName: "GameViewController", bundle: NSBundle.mainBundle())
        self.view.replaceSubview(self.pairDeviceView, with: self.gameViewController!.view)
        })
    }
    
}
