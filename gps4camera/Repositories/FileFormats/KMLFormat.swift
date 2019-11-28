//
//  KMLFormat.swift
//  gps4camera
//
//  Created by Astro on 11/24/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import CoreLocation

public class KMLFormat: FileFormatType {
    public let fileExtensionName = "kml"
    
    required public init() {
        
    }

    public func header() -> String {
        return """
<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2"><Document><name>Tracks</name><open>1</open>
<description></description>
<Placemark>
<name>Moving</name>
<address></address>
<ExtendedData>
<Data name="Category">
<value>Moving</value>
</Data>
<Data name="Distance">
<value>538</value>
</Data>
</ExtendedData>
<LineString>
<altitudeMode>clampToGround</altitudeMode>
<extrude>1</extrude>
<tesselate>1</tesselate>
<coordinates>
"""
    }
    
    public func content(pois: [POI]) -> String {
        var output = ""
        for poi in pois {
            output += "\(poi.longitude),\(poi.latitude),0 "
        }
        
        return output
    }
    
    public func footer() -> String {
        return """
</coordinates>
</LineString>
<description>Moving from DATE to DATE. Distance DISTANCE and other info</description>
</Placemark>
</Document>
</kml>
"""
    }
    
    public func write(data: AnyObject) -> String {
        if let location = data as? CLLocation {
            return "\(location.coordinate.longitude),\(location.coordinate.latitude),0 "
        }
        
        return "\(data)"
    }
}
