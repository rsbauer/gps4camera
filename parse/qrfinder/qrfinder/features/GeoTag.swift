//
//  GeoTag.swift
//  qrfinder
//
//  Created by Astro on 6/7/20.
//  Copyright © 2020 RSB. All rights reserved.
//

import Foundation

public final class GeoTag {
    private enum Constants {
        static let exifCommand = "exiftool -overwrite_original -geotag="
    }
    
    public func using(_ mapPaths: [URL]) {
        for path in mapPaths {
            let filename = path.lastPathComponent
            let dirpath = path.path.replacingOccurrences(of: filename, with: "")
            let command = "\(Constants.exifCommand)\"\(path.path)\" \(dirpath)"
            print("Executing: \(command)")
            Shell.shell(command)
        }
    }
}
