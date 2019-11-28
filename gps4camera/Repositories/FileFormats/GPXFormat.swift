//
//  GPXFormat.swift
//  gps4camera
//
//  Created by Astro on 11/24/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import CoreLocation

public class GPXFormat: FileFormatType {
    public let fileExtensionName = "gpx"
    
    required public init() {
        
    }

    public func header() -> String {
        return """
<?xml version="1.0" encoding="UTF-8" ?><gpx version="1.0" creator="GPSLogger 103 - http://gpslogger.mendhak.com/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.topografix.com/GPX/1/0" xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd">
        <trk>
        <trkseg>

"""
        // may be worth appending time tag:
        // <time>2019-11-25T05:00:53.416Z</time>
    }

    public func content(pois: [POI]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"

        var timestamp = ""
        var output = ""
        for poi in pois {
            timestamp = ""
            if let date = poi.timestamp {
                timestamp = dateFormatter.string(from: date)
            }
            
            output += """
            <trkpt lat="\(poi.latitude)" lon="\(poi.longitude)">
                <ele>\(poi.altitude)</ele>
                <time>\(timestamp)</time>
                <src>network</src>
            </trkpt>
"""
        }
        
        return output
    }
    
    public func footer() -> String {
        return "</trkseg></trk></gpx>"
    }
    
    public func write(data: AnyObject) -> String {
        if let location = data as? CLLocation {
            return "\(location.speed)"
        }
        
        return "\(data)"
    }
}
