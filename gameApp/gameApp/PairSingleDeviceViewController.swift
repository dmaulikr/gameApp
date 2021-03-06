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
    
    private let kAddPeerInviteNK = "elg-addPeerInvite"
    private let switchToGameViewNK = "elg-switchToGameView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewLayer = CALayer()
        viewLayer.backgroundColor = CGColorCreateGenericRGB(0.000, 0.114, 0.212, 1.00)
        pairDeviceView.wantsLayer = true
        pairDeviceView.layer = viewLayer
        self.view.addSubview(pairDeviceView)
        
        // Do view setup here.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPeerInvite:", name: kAddPeerInviteNK, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "switchToGameView", name: switchToGameViewNK, object: nil)
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
