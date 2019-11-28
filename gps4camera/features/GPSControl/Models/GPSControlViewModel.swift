//
//  GPSControlViewModel.swift
//  gps4camera
//
//  Created by Astro on 11/24/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import CoreLocation
import ReactiveKit
import Swinject

public class GPSControlViewModel {
    
    private(set) var gpsButtonText = Observable("")
    private(set) var track: Track?
    private(set) var speed = Observable<Double>(0)
    private(set) var repositoryKind = Observable(FileRepositoryKind.kml)
    
    private var locationManager: LocationManagerType?
    private var dataStore: DataStoreProviderType?
    private var stateMachine: GPSStateMachine
    private var disposeBag: DisposeBag = DisposeBag()
    private var speedUnit: String = "mph"

    public enum Constants {
        static let filenameDateFormat = "MM-dd-YYY hh:mma"
    }

    init(manager: LocationManagerType?, dataStore: DataStoreProviderType?) {
        locationManager = manager
        self.dataStore = dataStore
        
        guard let locationManagerExists = manager else {
            stateMachine = GPSStateMachine(states: [])
            return
        }
    
        stateMachine = GPSStateMachine(states: [
            GPSInitializeState(locationManager: locationManagerExists),
            GPSOnState(locationManager: locationManagerExists),
            GPSOffState(locationManager: locationManagerExists)
        ])
        
        MessageBroker.sharedMessageBroker.subscribe(self, messageKey: LocationMessage.locationType)
    }

    public func shutdown() {
        disposeBag.dispose()
        disposeBag = DisposeBag()
        MessageBroker.sharedMessageBroker.unsubscribe(self, messageKey: LocationMessage.locationType)
    }
    
    public func setSpeedUnit(unit: String) {
        speedUnit = unit
    }
    
    public func initializeGPS() {
        stateMachine.enter(GPSInitializeState.self)
        stateMachine.enter(GPSOffState.self)
        updateGPSButtonText()
    }

    public func startGPS() {
        guard let context = dataStore?.context else {
            return
        }
        
        track = Track(context: context)
        track?.name = createFileNameFromDate()
        track?.start = Date()

        saveTrack()
        
        stateMachine.enter(GPSOnState.self)
        updateGPSButtonText()
    }
    
    public func stopGPS() {
        stateMachine.enter(GPSOffState.self)
        updateGPSButtonText()
        
        track?.end = Date()

        saveTrack()
    }
    
    public func toggleGPS() {
        if stateMachine.currentState is GPSOnState {
            stopGPS()
        } else {
            startGPS()
        }
    }
    
    private func saveTrack() {
        if let trackExists = track {
            dataStore?.save(track: trackExists, completionHandler: { (result) in
                print("save complete")
            })
        }
    }
    
    private func updateGPSButtonText() {
        guard let text = (stateMachine.currentState as? GPSStateType)?.stateDisplayName else {
            return
        }

        gpsButtonText.value = text
    }
    
    private func locationUpdated(location: CLLocation) {
        print(location)
        let metersPerSecond = Measurement(value: location.speed, unit: UnitSpeed.metersPerSecond)
        var newSpeed: Measurement<UnitSpeed> = Measurement<UnitSpeed>.init(value: 0, unit: UnitSpeed.metersPerSecond)
        if speedUnit == "mph" {
            newSpeed =  metersPerSecond.converted(to: UnitSpeed.milesPerHour)
        }
        else {
            newSpeed = metersPerSecond.converted(to: UnitSpeed.kilometersPerHour)
        }

        speed.value = newSpeed.value
        
        save(location: location)
    }
    
    private func headingUpdated(heading: CLHeading) {
        print(heading)
    }
    
    private func createFileNameFromDate() -> String {
        let dateFormatterForFileName = DateFormatter()
        dateFormatterForFileName.dateFormat = Constants.filenameDateFormat
        return dateFormatterForFileName.string(from: Date())
    }
    
    private func save(location: CLLocation) {
        guard let context = dataStore?.context else {
            return
        }

        let poi = POI(context: context)
        poi.altitude = location.altitude
        poi.latitude = location.coordinate.latitude
        poi.longitude = location.coordinate.longitude
        poi.speed = location.speed
        poi.haccuracy = location.horizontalAccuracy
        poi.vaccuracy = location.verticalAccuracy
        poi.course = location.course
        poi.timestamp = Date()
        poi.track = track
        
        saveTrack()
    }
    
    private func getFilename() -> URL  {
        let fileFormat = repositoryKind.value.repositoryClass().init()
        let localName = createFileNameFromDate() + ".\(fileFormat.fileExtensionName)"
        return FileRepository.getDocumentsDirectory().appendingPathComponent(localName)
    }
}

extension GPSControlViewModel: Subscriber {
    func receive(_ message: Message) {
        if let locationMessage = message as? LocationMessage {
            switch locationMessage {
            case .location(let location):
                locationUpdated(location: location)
            case .heading(let heading):
                headingUpdated(heading: heading)
            }
        }
    }
}
