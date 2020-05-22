//
//  CGImageSource+Extensions.swift
//  qrfinder
//
//  Created by Astro on 5/21/20.
//  Copyright © 2020 RSB. All rights reserved.
//

import Cocoa

// from: https://stackoverflow.com/questions/42668330/convert-from-cgimagemetadata-to-nsdictionary
extension CGImageSource {

    func metadata() -> Dictionary<String, Any>? {

        guard let imageMetadata = CGImageSourceCopyMetadataAtIndex(self, 0, .none) else {
            return .none
        }

        guard let tags = CGImageMetadataCopyTags(imageMetadata) else {
            return .none
        }

        var result = [String: Any]()
        for tag in tags as NSArray {
            let tagMetadata = tag as! CGImageMetadataTag
            if let cfName = CGImageMetadataTagCopyName(tagMetadata) {
                let name = String(cfName)
                let value = CGImageMetadataTagCopyValue(tagMetadata)
                result[name] = value
            }
        }

        return result
    }
}
