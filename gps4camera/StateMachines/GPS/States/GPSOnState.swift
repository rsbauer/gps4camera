//
//  GPSOnState.swift
//  gps4camera
//
//  Created by Astro on 11/11/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import class GameplayKit.GKState

class GPSOnState: GKState, GPSStateType {
    
    public let stateDisplayName = ""
    
    private var locationManager: LocationManagerType?
    
    init(locationManager: LocationManagerType) {
        self.locationManager = locationManager
    }

    override func didEnter(from previousState: GKState?) {
        locationManager?.startUpdatingLocation()
    }
    
    override func willExit(to nextState: GKState) {
        // TODO
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        if stateClass is GPSOffState.Type {
            return true
        }
        
        return false
    }
    
}
