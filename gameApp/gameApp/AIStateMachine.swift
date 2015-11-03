//
//  AIStateMachine.swift
//  gameApp
//
//  Created by Liza Girsova on 10/28/15.
//  Copyright © 2015 Girsova. All rights reserved.
//

import Cocoa

class AIStateMachine<T>: NSObject {

    var owner: T!
    var currentState: AIState<T>?
    var previousState: AIState<T>?
    var globalState: AIState<T>?
    
    init(owner: T) {
        super.init()
        self.owner = owner
    }
    
    func changeState(newState: AIState<T>) {
        
    }
    
}
