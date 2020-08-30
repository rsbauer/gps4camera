//
//  QRProcessor.swift
//  qrfinder
//
//  Created by Astro on 5/21/20.
//  Copyright © 2020 RSB. All rights reserved.
//

import Cocoa
import Foundation

public class ImageProcessor {
    private let dateFormatForQR = DateFormatter()
    private let dateFormats = [
        "yyyy-MM-dd'T'HH:mm:ss.SS",
        "yyyy-MM-dd'T'HH:mm:ss"
    ]
    
    public init() {
    }
    
    public func diskImage(from named: URL) -> CGImage? {
        guard let image = NSImage(contentsOf: named) else {
            print("Unable to read image")
            return nil
        }

        var imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        return image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
    }

    public func readQR(from imageRef: CGImage) -> String? {
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let qrCodes = detector?.features(in: CIImage(cgImage: imageRef))

        if let first = qrCodes?.first as? CIQRCodeFeature {
            return first.messageString
        }
        
        return nil
    }
    
    public func imageSource(from name: URL) -> CGImageSource? {
        guard let data = NSData(contentsOf: name),
            let source = CGImageSourceCreateWithData((data as CFData), nil) else {
                return nil
        }
        
        return source
    }

    public func readExif(from name: URL) -> Dictionary<String, Any>? {
        return imageSource(from: name)?.metadata()
    }
    
    public func processImage(name: URL) -> QRImage? {
        guard let image = diskImage(from: name) else {
            print("Unable to open image \(name)")
            return nil
        }

        guard let message = readQR(from: image), let qrDate = parseStringToDate(message) else {
            return nil
        }

        guard let metaData = readExif(from: name),
            let createDate = findCreateDate(metaData),
            let cameraDate = parseStringToDate(createDate) else {
            return nil
        }

        var incrementDirection = "-"
        if qrDate > cameraDate {
            incrementDirection = "+"
        }
        
        let calendar = Calendar.current
        let diff = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: cameraDate, to: qrDate)
        
        let exifCommand = "exiftool \"-AllDates\(incrementDirection)=\(diff.year ?? 0):\(diff.month ?? 0):\(diff.day ?? 0) \(diff.hour ?? 0):\(diff.minute ?? 0):\(diff.second ?? 0)\""
        
        var start = cameraDate
        var end = qrDate
        if end < start {
            start = qrDate
            end = cameraDate
        }
        
        let interval = DateInterval(start: start, end: end)
        
        return QRImage(qrDate: qrDate, cameraDate: cameraDate, path: name, exifCommand: exifCommand, duration: interval.duration)
    }
    
    public func adjustDates(using qrImage: QRImage, for path: URL) {
        Shell.shell("\(qrImage.exifCommand) \(path.absoluteURL)")
    }
}

extension ImageProcessor {
    private func parseStringToDate(_ string: String) -> Date? {
        for format in dateFormats {
            dateFormatForQR.dateFormat = format

            if let foundDate = dateFormatForQR.date(from: string) {
                return foundDate
            }
        }
        
        return nil
    }
    
    private func findCreateDate(_ metaData: Dictionary<String, Any>) -> String? {
        let keys = ["DateCreate", "DateCreated"]
        for key in keys {
            if let found = metaData[key] as? String {
                return found
            }
        }

        return nil
    }
}
