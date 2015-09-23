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
    private let addAccessibilityCodeNK = "elg-addAccessibilityCode"
    
    private let peerId = MCPeerID(displayName: NSHost.currentHost().localizedName!)
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    var player1Code: Int?
    
    override init () {
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: GameServiceType)
        super.init()
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.player1Code = randomizedConnectionCode()
        print("Starting advertising peer...")
        
        NSNotificationCenter.defaultCenter().postNotificationName(addAccessibilityCodeNK, object: self, userInfo: ["accessibilityCode": self.player1Code!])
        
        print("Randomized connection code: \(player1Code)")
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
    
    func randomizedConnectionCode() -> Int {
        let randomInt = Int(arc4random_uniform(10_000))
        var randomIntString = String(randomInt)
        
        if randomInt <= 9 {
            randomIntString = ("000\(randomIntString)")
            return Int(randomIntString)!
        } else if randomInt <= 99 {
            randomIntString = ("00\(randomIntString)")
            return Int(randomIntString)!
        } else if randomInt <= 999 {
            randomIntString = ("0\(randomIntString)")
            return Int(randomIntString)!
        } else {
            return randomInt
        }
    }
    
}

extension ServiceManager : MCNearbyServiceAdvertiserDelegate {
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        print("Error: didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        print("didReceiveInvitationFromPeer: \(peerID)")
        
        // Here check if the code sent matches
        // if it does, accept the invitation
        let codeSent = NSString(data: context!, encoding: NSUTF8StringEncoding)
        
        if Int(codeSent as! String) == player1Code {
            print("Correct code!")
            invitationHandler(true, self.session)
        } else {
            print("Incorrect code sent")
            invitationHandler(false, self.session)
        }
    }
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "Not Connected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        default: return "Unknown Status"
        }
    }
}

extension ServiceManager : MCSessionDelegate {
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state.stringValue())")
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("peer \(peerID) didStartReceivingResourceWithName: \(resourceName)")
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("peer \(peerID) didFinishReceivingResourceWithName: \(resourceName)")
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("peer \(peerID) didReceiveData: \(data)")
        
        let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
        print(dataString)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("peer \(peerID) didReceiveStream, with name: \(streamName)")
    }
}