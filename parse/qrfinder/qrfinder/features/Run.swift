//
//  Run.swift
//  qrfinder
//
//  Created by Astro on 6/7/20.
//  Copyright © 2020 RSB. All rights reserved.
//

import Foundation
import Cocoa

public final class Run {
    public func run() {
        guard CommandLine.arguments.count > 2 else {
            showCommandLineArgs()
            return
        }
        
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
    
    private func showCommandLineArgs() {
        print("""
qrfinder usage:

qrfinder <directory to images to sync time to, plus 1 image of the Sync tab from gps4camera app>

exiftool must be installed before running: https://exiftool.org/install.html#OSX

Place a kml or gpx file (or files) in the directory with the images and qrfinder will execute exiftool to geo tag the photos.

MAKE BACKUPS BEFORE RUNNING.  All file changes are done in place.
""")
    }
}
