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
    let fileExt = CommandLine.arguments[2]
    if path.last != "/" {
        path = "\(path)/"
    }
    
    let imageProcessor = ImageProcessor()
    let paths = DirectoryProcessor().directoryList(path: path, fileExtension: fileExt)
    
    var qrImageFound: QRImage?
    
    for path in paths  {
        print("Processing: \(path)")
        if let qrImage = imageProcessor.processImage(name: path) {
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
    
}
