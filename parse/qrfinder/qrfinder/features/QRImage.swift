//
//  QRImage.swift
//  qrfinder
//
//  Created by Astro on 5/21/20.
//  Copyright © 2020 RSB. All rights reserved.
//

import Foundation

public struct QRImage {
    let qrDate: Date
    let cameraDate: Date
    let path: URL
    let exifCommand: String
    let duration: TimeInterval
}
