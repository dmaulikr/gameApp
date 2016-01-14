//
//  ServiceManager.swift
//  gameApp
//
//  Created by Liza Girsova on 9/21/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Foundation
import MultipeerConnectivity

struct ConnectedPeers {
    static var dict = NSMutableDictionary() // dictionary of peers
    static var firstConnectionPeerID: MCPeerID?
    static var secondConnectionPeerID: MCPeerID?
}

class ServiceManager : NSObject {
    
    // Service type must be a unique string, at most 15 characters long
    private let GameServiceType = "elg-escape-game"
    let kPeerIDKey = "elg-peerid"
    
    var peerId: MCPeerID
    var serviceAdvertiser : MCNearbyServiceAdvertiser
    var defaults: NSUserDefaults
    
    override init () {
        defaults = NSUserDefaults.standardUserDefaults()
        if let peerIDData = defaults.dataForKey(kPeerIDKey) {
        peerId = NSKeyedUnarchiver.unarchiveObjectWithData(peerIDData) as! MCPeerID
        print("peerID: \(peerId)")
        } else {
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
            // Create new connected peer
            
            let newPeer = Peer(peerID: peerID)
            
            if ConnectedPeers.dict.count == 0 {
             ConnectedPeers.firstConnectionPeerID = peerID
            }
            
            if ConnectedPeers.dict.count == 1 {
                ConnectedPeers.secondConnectionPeerID = peerID
            }
            
            ConnectedPeers.dict.setObject(newPeer, forKey: peerID)
            
            if ConnectedPeers.dict.count == 2 {
                print("connectedPeersDict: \(ConnectedPeers.dict)")
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.switchToGameView, object: self, userInfo: nil)
            }
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
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.playerControls, object: self, userInfo: ["strokeInfo": data, "peerID": peerID])
        
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("peer \(peerID) didReceiveStream, with name: \(streamName)")
    }
    
    func session(session: MCSession, didReceiveCertificate certificate: [AnyObject]?, fromPeer peerID: MCPeerID, certificateHandler: (Bool) -> Void) {
        certificateHandler(true)
    }
}