//
//  main.swift
//  qrfinder
//
//  Created by Astro on 5/20/20.
//  Copyright © 2020 RSB. All rights reserved.
//

import Foundation
import Cocoa

if CommandLine.arguments.count > 2 {
    var path = CommandLine.arguments[1]
    if path.last != "/" {
        path = "\(path)/"
    }
    
    let imageProcessor = ImageProcessor()
    let paths = DirectoryProcessor().directoryList(path: path)
    
    var qrImageFound: QRImage?
    
    for path in paths  {
        print("Processing: \(path)")
        if let qrImage = imageProcessor.processImage(name: path) {
            print("QR code found! \(qrImage)")
            qrImageFound = qrImage
            break
        }
    }
    
    if let qrImage = qrImageFound {
        for path in paths {
            print("Fixing: \(path)")
            imageProcessor.adjustDates(using: qrImage, for: path)
        }
    }
    
    let mapPaths = paths.filter { (path) -> Bool in
        let fileExt = path.pathExtension
        if fileExt == "kml" || fileExt == "gpx" {
            return true
        }
        
        return false
    }
    
    print("Applying \(mapPaths.count) map file(s) (kml/gpx) to images.")
    GeoTag().using(mapPaths)
}
