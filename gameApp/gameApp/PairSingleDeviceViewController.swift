//
//  PairSingleDeviceViewController.swift
//  gameApp
//
//  Created by Liza Girsova on 9/23/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

class PairSingleDeviceViewController: NSViewController {
    
    @IBOutlet var pairDeviceView: NSView!
    @IBOutlet var connectedPeersTableView: NSTableView!
    @IBOutlet var horrorLevelButton: NSButton!
    @IBOutlet var extremeHorrorLevelButton: NSButton!
    
    var serviceManager: ServiceManager?
    var gameViewController: GameViewController = GameViewController()
    
    var connectedPeersArray: [(peerID: MCPeerID, status: String)] = []
    let tableCellViewNib = NSNib(nibNamed: "TableCellView", bundle: NSBundle.mainBundle())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectedPeersTableView.setDataSource(self)
        connectedPeersTableView.setDelegate(self)
        connectedPeersTableView.registerNib(tableCellViewNib, forIdentifier: "TableCellView")
        
        let viewLayer = CALayer()
        viewLayer.backgroundColor = CGColorCreateGenericRGB(0.000, 0.114, 0.212, 1.00)
        pairDeviceView.wantsLayer = true
        pairDeviceView.layer = viewLayer
        self.view.addSubview(pairDeviceView)
        
        // Do view setup here.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPeerInvite:", name: Constants.Notifications.addPeerInvite, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateReadyStatus:", name: Constants.Notifications.updateReadyStatus, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enableLevelSelect", name: Constants.Notifications.switchToGameView, object: nil)
        serviceManager = ServiceManager()
    }
    
    func addPeerInvite(notification: NSNotification) {
        let userInfo:Dictionary<String,MCPeerID> = notification.userInfo as! Dictionary<String,MCPeerID>
        let peerID = userInfo["peerID"]
        let dataTuple = (peerID!, "Not Ready")
        connectedPeersArray.append(dataTuple)
        dispatch_async(dispatch_get_main_queue(), {
            self.connectedPeersTableView.reloadData()
        })
    }
    
    func updateReadyStatus(notification: NSNotification) {
        let userInfo:Dictionary<String,MCPeerID> = notification.userInfo as! Dictionary<String,MCPeerID>
        let peerID = userInfo["peerID"]
        for (i, _) in connectedPeersArray.enumerate() {
            if connectedPeersArray[i].peerID.isEqual(peerID) {
                connectedPeersArray[i].status = "Ready"
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.connectedPeersTableView.reloadData()
        })
    }
    
    func readyCount() -> Int {
        var count = 0;
        for peer in connectedPeersArray {
            if peer.status == "Ready" {
                count++
            }
        }
        return count
    }
    
    func enableLevelSelect() {
        horrorLevelButton.enabled = true
        extremeHorrorLevelButton.enabled = true
    }
    
    func switchToGameView() {
        dispatch_async(dispatch_get_main_queue(), {
            self.view.replaceSubview(self.pairDeviceView, with: self.gameViewController.view)
        })
    }
    
    @IBAction func horrorLevel(sender: NSButton) {
        self.gameViewController.level = "horror"
        switchToGameView()
    }
    
    @IBAction func extremehorrorLevel(sender: NSButton) {
        self.gameViewController.level = "extremeHorror"
        switchToGameView()
    }
    
}

extension PairSingleDeviceViewController : NSTableViewDataSource, NSTableViewDelegate
{
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int
    {
        return connectedPeersArray.count
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        // Get an existing cell with the MyView identifier if it exists
        let view = tableView.makeViewWithIdentifier("TableCellView", owner: nil)! as! TableCellView
        let tuple: (peerID: MCPeerID, status: String) = self.connectedPeersArray[row]
        view.displayNameTF.stringValue = tuple.peerID.displayName
        view.readyTF.stringValue = tuple.status
        
        if self.readyCount() == 2 {
            self.enableLevelSelect()
        }
        
        return view
    }
}
