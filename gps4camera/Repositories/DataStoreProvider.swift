//
//  DataProvider.swift
//  ComicReader
//
//  Created by Robert Bauer on 11/14/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import CoreData
import CoreLocation

public typealias DataStoreProviderCompletionHandler = (Result<[Track], Error>) -> Void
public typealias DataStoreProviderSaveHandler = (Result<Bool, Error>) -> Void

public protocol DataStoreProviderType {
    var context: NSManagedObjectContext? { get }
    func save(track: Track, completionHandler: DataStoreProviderSaveHandler?)
    func load(completionHandler: DataStoreProviderCompletionHandler?)
    func remove(track: Track, completionHandler: DataStoreProviderSaveHandler?)
}

public class DataStoreProvider: DataStoreProviderType {
    public let context: NSManagedObjectContext?
    
    private enum Constants {
        static let tracksEntityName = "Track"
        static let poiEntityName = "POI"
    }
    
    init(context: NSManagedObjectContext?) {
        self.context = context
    }
    
    public func save(track: Track, completionHandler: DataStoreProviderSaveHandler?) {
        guard let context = context else {
            completionHandler?(.failure(NSError(domain: "Failed to save media.", code: 100, userInfo: nil)))
            return
        }

        do {
            try context.save()
            completionHandler?(.success(true))
        } catch {
            completionHandler?(.failure(NSError(domain: "Failed to save media", code: 101, userInfo: nil)))
        }
    }
    
    public func load(completionHandler: DataStoreProviderCompletionHandler?) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.tracksEntityName)
        request.returnsObjectsAsFaults = false
        
        do {
            if let result = try context?.fetch(request) as? [Track] {
                completionHandler?(.success(result))
            }
        } catch {
            completionHandler?(.failure(error))
        }
    }
    
    public func remove(track: Track, completionHandler: DataStoreProviderSaveHandler?) {
        context?.delete(track)
        do {
            try context?.save()
        } catch {
            print("Failed to delete all media: \(error.localizedDescription)")
            completionHandler?(.failure(error))
            return
        }
        completionHandler?(.success(true))
    }
    
    public  func deleteAllMedia(for entityName: String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context?.execute(deleteRequest)
        } catch {
            print("Failed to delete all media: \(error.localizedDescription)")
        }
    }
}
