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

public enum CompassRose: Int {
    case n = 0
    case ne = 45
    case e = 90
    case se = 135
    case s = 180
    case sw = 225
    case w = 270
    case nw = 315
    
    static public func from(heading: Double) -> CompassRose {
        let directions: [CompassRose] = [.n, .ne, .e, .se, .s, .sw, .w, .nw, .n]
        let index: Int = Int(round(heading / 45))
        return directions[index]
    }
    
    public func stringValue() -> String {
        switch self {
        case .n:
            return "north"
        case .ne:
            return "north-east"
        case .e:
            return "east"
        case .se:
            return "south-east"
        case .s:
            return "south"
        case .sw:
            return "south-west"
        case .w:
            return "west"
        case .nw:
            return "north-west"
        }
    }
}

public class GPSControlViewModel {
    
    private(set) var gpsButtonText = Observable("")
    private(set) var track: Track?
    private(set) var speed = Observable<Double>(0)
    private(set) var distanceForDisplay = Observable<Double>(0)
    private(set) var distanceInMeters = Observable<Double>(0)
    private(set) var repositoryKind = Observable(FileRepositoryKind.kml)
    private(set) var maxSpeed = Observable<Double>(0)
    private(set) var altitudeInMeters = Observable<Double>(0)
    private(set) var altitudeForDisplay = Observable<Double>(0)
    private(set) var heading = Observable<Double>(0)
    private(set) var headingTitle = Observable("")
    private(set) var accuracyForDisplay = Observable<Double>(0)
    private(set) var accuracyInMeters = Observable<Double>(0)
    private(set) var elapsedTime = Observable("00.00.00")
    private(set) var clock = Observable("")
    private(set) var temperatureForDisplay = Observable<Double>(0)
    private var temperature = Observable<Double>(0)
    
    private var locationManager: LocationManagerType?
    private var dataStore: DataStoreProviderType?
    private var stateMachine: GPSStateMachine
    private var disposeBag: DisposeBag = DisposeBag()
    private var speedUnit: String = Constants.imperialRate
    private var previousLocation: CLLocation?
    private var clockTimer: Timer?
    private var startTime: Date = Date()
    private let clockDateFormatter = DateFormatter()

    public enum Constants {
        static let filenameDateFormat = "MM-dd-YYY hh:mma"
        static let clockDate24Format = "HH.mm.ss"
        static let clockDate12Format = "hh.mm.ss"
        static let imperialRate = "mph"
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

        clockDateFormatter.dateFormat = Constants.clockDate12Format
        UserDefaults.standard.reactive.keyPath("clock_format", ofType: Optional<String>.self, context: .immediateOnMain).observeNext { [weak self] (clockFormat) in
            guard let strongSelf = self, let formatExists = clockFormat else {
                return
            }
            
            var format = Constants.clockDate12Format
            if formatExists == "24"  {
                format = Constants.clockDate24Format
            }
            
            strongSelf.clockDateFormatter.dateFormat = format
        }.dispose(in: disposeBag)
        
        setupClockTimer()
    }

    public func shutdown() {
        clockTimer?.invalidate()
        clockTimer = nil
        
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
        setupObservers()
    }
    
    private func setupObservers() {
        distanceInMeters.observeNext { [weak self] (meters) in
            guard let strongSelf = self else {
                return
            }
            
            let distanceMeters = Measurement(value: meters, unit: UnitLength.meters)
            var newValue: Measurement<UnitLength> = Measurement<UnitLength>.init(value: 0, unit: UnitLength.kilometers)
            if strongSelf.speedUnit == Constants.imperialRate {
                newValue =  distanceMeters.converted(to: UnitLength.miles)
            }
            else {
                newValue = distanceMeters.converted(to: UnitLength.kilometers)
            }

            strongSelf.distanceForDisplay.value = newValue.value
            strongSelf.track?.distance = newValue.value
        }.dispose(in: disposeBag)
        
        maxSpeed.observeNext { [weak self] (speed) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.track?.maxSpeed = speed
        }.dispose(in: disposeBag)
        
        altitudeInMeters.observeNext { [weak self] (altitude) in
            guard let strongSelf = self else {
                return
            }

            let distanceMeters = Measurement(value: altitude, unit: UnitLength.meters)
            var newValue: Measurement<UnitLength> = Measurement<UnitLength>.init(value: 0, unit: UnitLength.kilometers)
            if strongSelf.speedUnit == Constants.imperialRate {
                newValue =  distanceMeters.converted(to: UnitLength.feet)
            }
            else {
                newValue = distanceMeters.converted(to: UnitLength.meters)
            }

            strongSelf.altitudeForDisplay.value = newValue.value
        }.dispose(in: disposeBag)
        
        heading.observeNext { [weak self] (headingValue) in
            guard let strongSelf = self else {
                return
            }
            
            let compassRose = CompassRose.from(heading: headingValue)
            strongSelf.headingTitle.value = compassRose.stringValue()
        }.dispose(in: disposeBag)
        
        accuracyInMeters.observeNext { [weak self] (accuracy) in
            guard let strongSelf = self else {
                return
            }
            
            let distanceMeters = Measurement(value: accuracy, unit: UnitLength.meters)
            var newValue: Measurement<UnitLength> = Measurement<UnitLength>.init(value: 0, unit: UnitLength.kilometers)
            if strongSelf.speedUnit == Constants.imperialRate {
                newValue =  distanceMeters.converted(to: UnitLength.feet)
            }
            else {
                newValue = distanceMeters.converted(to: UnitLength.meters)
            }

            strongSelf.accuracyForDisplay.value = newValue.value
        }.dispose(in: disposeBag)
    }

    public func startGPS() {
        guard let context = dataStore?.context else {
            return
        }
        
        if clockTimer == nil {
            setupClockTimer()
        }
        
        startTime = Date()
        
        track = Track(context: context)
        track?.name = createFileNameFromDate()
        track?.start = Date()

        saveTrack()
        
        stateMachine.enter(GPSOnState.self)
        updateGPSButtonText()
    }
    
    public func stopGPS() {
        clockTimer?.invalidate()
        clockTimer = nil
        
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
        if let prevLocation = previousLocation {
            distanceInMeters.value += location.distance(from: prevLocation)
        }
        
        let metersPerSecond = Measurement(value: location.speed, unit: UnitSpeed.metersPerSecond)
        var newSpeed: Measurement<UnitSpeed> = Measurement<UnitSpeed>.init(value: 0, unit: UnitSpeed.metersPerSecond)
        if speedUnit == Constants.imperialRate {
            newSpeed =  metersPerSecond.converted(to: UnitSpeed.milesPerHour)
        }
        else {
            newSpeed = metersPerSecond.converted(to: UnitSpeed.kilometersPerHour)
        }

        speed.value = newSpeed.value
        altitudeInMeters.value = location.altitude
        heading.value = location.course
        accuracyInMeters.value = location.horizontalAccuracy

        if speed.value > maxSpeed.value {
            maxSpeed.value = speed.value
        }
        
        save(location: location)
        previousLocation = location
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
    
    private func setupClockTimer() {
        clockTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (timer) in
            guard let strongSelf = self else {
                return
            }
            
            let now = Date()
            let elapsed = strongSelf.startTime.distance(to: now)
            strongSelf.clock.value = strongSelf.clockDateFormatter.string(from: now)
            
            if strongSelf.stateMachine.currentState is GPSOnState {
                let (hours, minutes, seconds) = strongSelf.secondsToHoursMinutesSeconds(seconds: elapsed)
                let secondsRounded: Int = Int(round(seconds))
                let padFormat = "%02d"
                
                // Gah, String(format: "%02d.%02d.%02d", hours, minutes, secondsRounded) should have worked, but was
                // putting seconds in the first parameter
                // Doing it manually below
                let hourDisplay = String(format: padFormat, hours)
                let minuteDisplay = String(format: padFormat, minutes)
                let secondDisplay = String(format: padFormat, secondsRounded)
                strongSelf.elapsedTime.value = "\(hourDisplay).\(minuteDisplay).\(secondDisplay)"
            }
        })
    }
    
    // from: https://stackoverflow.com/questions/26794703/swift-integer-conversion-to-hours-minutes-seconds
    private func secondsToHoursMinutesSeconds (seconds : Double) -> (Double, Double, Double) {
      let (hr,  minf) = modf (seconds / 3600)
      let (min, secf) = modf (60 * minf)
      return (hr, min, 60 * secf)
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
