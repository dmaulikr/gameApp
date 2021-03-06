//
//  ServiceManager.swift
//  gameApp
//
//  Created by Liza Girsova on 9/21/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class ServiceManager : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    private let GameServiceType = "elg-escape-game"
    private let kAddPeerInviteNK = "elg-addPeerInvite"
    private let switchToGameViewNK = "elg-switchToGameView"
    let kPlayerControlsNK = "elg-playerControls"
    let kPeerIDKey = "elg-peerid"
    
    var peerId: MCPeerID
    var serviceAdvertiser : MCNearbyServiceAdvertiser
    var player1Code: String?
    var defaults: NSUserDefaults
    
    override init () {
        defaults = NSUserDefaults.standardUserDefaults()
        if let peerIDData = defaults.dataForKey(kPeerIDKey) {
        print("peerID already exists")
        peerId = NSKeyedUnarchiver.unarchiveObjectWithData(peerIDData) as! MCPeerID
        print("peerID: \(peerId)")
        } else {
            print("peerID does not yet exist. Create a new one.")
        peerId = MCPeerID(displayName: NSHost.currentHost().localizedName!)
        print("peerID: \(peerId)")
        let peerIDData = NSKeyedArchiver.archivedDataWithRootObject(peerId)
        defaults.setObject(peerIDData, forKey: kPeerIDKey)
        defaults.synchronize()
        }
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: GameServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        print("Starting advertising peer...")
        
    }
    
    deinit {
        print("serviceAdvertiser deinit")
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.peerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.Required)
        session.delegate = self
        return session
        }()
    
}

extension ServiceManager : MCNearbyServiceAdvertiserDelegate {
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("Error: didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("didReceiveInvitationFromPeer: \(peerID)")
        
             //NSNotificationCenter.defaultCenter().postNotificationName(kAddPeerInviteNK, object: self, userInfo: ["peerId": peerID.displayName])
        
            invitationHandler(true, self.session)
    }
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "Not Connected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }
}

extension ServiceManager : MCSessionDelegate {
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state.stringValue())")
        
        if(state == MCSessionState.Connected) {
            // Here must switch to the game view for now
            NSNotificationCenter.defaultCenter().postNotificationName(switchToGameViewNK, object: self, userInfo: nil)
        }
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("peer \(peerID) didStartReceivingResourceWithName: \(resourceName)")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("peer \(peerID) didFinishReceivingResourceWithName: \(resourceName)")
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        
        // Send notification to GameControllerView that controls have been sent
        NSNotificationCenter.defaultCenter().postNotificationName(kPlayerControlsNK, object: self, userInfo: ["strokeInfo": data])
        
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("peer \(peerID) didReceiveStream, with name: \(streamName)")
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
    }
}