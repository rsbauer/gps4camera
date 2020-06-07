//
//  DirectoryProcessor.swift
//  qrfinder
//
//  Created by Astro on 5/21/20.
//  Copyright © 2020 RSB. All rights reserved.
//

import Foundation

public class DirectoryProcessor {
    public func directoryList(path: String) -> [URL] {
        let url = URL(fileURLWithPath: path)
        var paths = [URL]()
        if let enumarator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]) {
            for case let fileURL as URL in enumarator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                    if fileAttributes.isRegularFile == true {
                        paths.append(fileURL)
                    }
                } catch {
                    print(error, fileURL)
                }
            }
        }
        
        return paths
    }
}
