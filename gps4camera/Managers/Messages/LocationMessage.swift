//
//  LocationMessage.swift
//  gps4camera
//
//  Created by Astro on 11/24/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import CoreLocation

public enum LocationMessage: Message {
    case location(CLLocation)
    case heading(CLHeading)
    
    static let locationType = "locationType"
    static let headingType = "headingType"
    
    func messageKey() -> MessageKey {
        switch self {
        case .location(_):
            return LocationMessage.locationType
        case .heading(_):
            return LocationMessage.headingType
        }
    }
}
