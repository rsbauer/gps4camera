//
//  DirectoryProcessor.swift
//  qrfinder
//
//  Created by Astro on 5/21/20.
//  Copyright © 2020 RSB. All rights reserved.
//

import Foundation

public class DirectoryProcessor {
    public func directoryList(path: String, fileExtension: String) -> [String] {
        let fileManager = FileManager.default
        let fileExtNormalized = fileExtension.lowercased()
        
        do {
            let items = try fileManager.contentsOfDirectory(atPath: path)
            return items.compactMap { (item) -> String? in
                if item.lowercased().contains(".\(fileExtNormalized)") {
                    return "\(path)\(item)"
                }
                return nil
            }
            
//            for item in items {
//                if item.lowercased().contains(".\(fileExtNormalized)") {
//                    print(item)
//                }
//            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
}
