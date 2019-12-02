//
//  File.swift
//  gps4camera
//
//  Created by Astro on 11/24/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import ReactiveKit
import Swinject

public struct FileListDisplay {
    var title: String
    var track: Track?
}

public class FilesViewModel {
    private var disposeBag: DisposeBag = DisposeBag()
    private(set) var items = MutableObservableArray<FileListDisplay>([])
    private var dataStore: DataStoreProviderType?
    
    private enum Constants {
        static let emptyItemTitle = "No tracks recorded yet"
    }

    init(dataStore: DataStoreProviderType?) {
        self.dataStore = dataStore
    }

    public func shutdown() {
        disposeBag.dispose()
        disposeBag = DisposeBag()
    }

    public func populateList() {
        dataStore?.load(completionHandler: { [weak self] (result) in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let tracks):
                strongSelf.items.removeAll()
                for track in tracks {
                    let item = FileListDisplay(title: track.name ?? "Title not available", track: track)
                    strongSelf.items.append(item)
                }
                
                if strongSelf.items.isEmpty {
                    strongSelf.items.append(FileListDisplay(title: Constants.emptyItemTitle, track: nil))
                }
            case .failure(let error):
                print("\(error)")
            }
        })
    }
    
    public func removeItem(at index: Int) {
        let item = items[index]
        if let track = item.track {
            dataStore?.remove(track: track, completionHandler: nil)
        }

        items.remove(at: index)
    }
    
    static public func displayName(for track: Track) -> String {
        let dateFormatterForDisplay = DateFormatter()
        dateFormatterForDisplay.dateFormat = "MM-dd-YYY hh:mma"
        let dateFormatterForFilename = DateFormatter()
        dateFormatterForFilename.dateFormat = GPSControlViewModel.Constants.filenameDateFormat
        if let filedate = dateFormatterForFilename.date(from: track.name ?? "") {
            return dateFormatterForDisplay.string(from: filedate)
        }

        return track.name ?? "File name not found"
    }
}
