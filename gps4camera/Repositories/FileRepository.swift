//
//  FileRepository.swift
//  gps4camera
//
//  Created by Astro on 11/24/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import CoreData

public protocol FileFormatType {
    init()
    
    var fileExtensionName: String { get }
    func write(data: AnyObject) -> String
    func header() -> String
    func content(pois: [POI]) -> String
    func footer() -> String
}

public protocol FileRepositoryType {
    static func action(_ action: FileAction)
    static func getDocumentsDirectory() -> URL
}

public enum FileRepositoryKind: String {
    case kml
    case gpx
    
    var fileExtensionName: String {
        return ".\(self.rawValue)"
    }
    
    func repositoryClass() -> FileFormatType.Type {
        switch self {
        case .kml:
            return KMLFormat.self
        case .gpx:
            return GPXFormat.self
        }
    }
}

public enum FileAction {
    case append(URL, FileFormatType, AnyObject)
    case export(URL, FileRepositoryKind, Track)
}

public class FileRepository {
    
    static public func action(_ action: FileAction) -> Error? {
        switch action {
        case .append(let filename, let format, let data):
            append(filename, format: format, data: data)
            return nil
        case .export(let filename, let format, let track):
            return export(filename, format: format, track: track)
        }
    }

    static private func export(_ filename: URL, format: FileRepositoryKind, track: Track) -> Error? {
        let formatter = format.repositoryClass().init()
        var output = formatter.header()
        if let pois = track.pois?.array as? [POI] {
            output += formatter.content(pois: pois)
        }
        output += formatter.footer()
        
        do {
            try output.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print("\(#function): \(error.localizedDescription)")
            return error
        }
        
        return nil
    }
    
    static private func append(_ filename: URL, format: FileFormatType, data: AnyObject) {
        if FileManager.default.fileExists(atPath: filename.path) {
            if let fileHandle = try? FileHandle(forWritingTo: filename),
                let data = format.write(data: data).data(using: String.Encoding.utf8) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            // file doesn't exist
            do {
                let firstOutput = format.header() + "\n" + format.write(data: data)
                try firstOutput.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                print("\(#function): \(error.localizedDescription)")
            }
        }
    }
    
    // from: https://www.hackingwithswift.com/example-code/strings/how-to-save-a-string-to-a-file-on-disk-with-writeto
    static public func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static public func filename(for track: Track, format: FileRepositoryKind) -> URL? {
        guard let name = track.name?.replacingOccurrences(of: " ", with: "_") else {
            return nil
        }
        
        return FileRepository.getDocumentsDirectory().appendingPathComponent("\(name).\(format.rawValue)")
    }
    
    static public func getFileList() -> [URL] {
        let directory = getDocumentsDirectory()
        var items = [URL]()
        
        let fileManager = FileManager.default
        do {
            let fileUrls = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            for fileUrl in fileUrls {
                items.append(fileUrl)
            }
        } catch {
            print("Error while enumerating files \(directory.path): \(error.localizedDescription)")
        }
        
        return items
    }
    
    static public func remove(_ path: URL) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: path)
        } catch {
            print("\(#function): \(error.localizedDescription)")
        }

    }
}
