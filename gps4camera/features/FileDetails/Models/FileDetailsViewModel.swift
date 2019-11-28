//
//  FileDetailsViewModel.swift
//  gps4camera
//
//  Created by Astro on 11/24/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import CoreData
import ReactiveKit
import Swinject

public class FileDetailsViewModel {
    
    private(set) var track: Observable<Track?>
    
    init(track: Track?) {
        if let trackExists = track {
            self.track = Observable(trackExists)
        }
        else {
            self.track = Observable(nil)
        }
    }
    
    private var disposeBag: DisposeBag = DisposeBag()

    public func shutdown() {
        disposeBag.dispose()
        disposeBag = DisposeBag()
    }

}
