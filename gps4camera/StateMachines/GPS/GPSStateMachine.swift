//
//  GPSStateMachine.swift
//  gps4camera
//
//  Created by Astro on 11/11/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import class GameplayKit.GKStateMachine
import class GameplayKit.GKState

public protocol GPSStateType {
    var stateDisplayName: String { get }
}

class GPSStateMachine: GKStateMachine {

    override init(states: [GKState]) {
        super.init(states: states)
    }
    
    public func toggleGPS() {
        switch currentState {
        case is GPSOnState:
            enter(GPSOffState.self)
        case is GPSOffState:
            enter(GPSOnState.self)
        default:
            break
        }
    }
}
