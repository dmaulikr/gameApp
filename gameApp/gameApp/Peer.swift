//
//  Peer.swift
//  gameApp
//
//  Created by Liza on 1/10/16.
//  Copyright © 2016 Girsova. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

class Peer: NSObject {
    var player: Player?
    let mcPeerID: MCPeerID!
    var hud: HUD?
    
    init(peerID: MCPeerID) {
        self.mcPeerID = peerID
        super.init()
        
    }
}
