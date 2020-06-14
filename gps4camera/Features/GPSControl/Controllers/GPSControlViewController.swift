//
//  GPSControlViewController.swift
//  gps4camera
//
//  Created by Astro on 11/11/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import InAppSettingsKit
import ReactiveKit
import Swinject
import UIKit

class GPSControlViewController: UIViewController {

    @IBOutlet weak var gpsToggleButton: UIButton!
    @IBOutlet weak var speedWidget: LEDWidget!
    @IBOutlet weak var speedUnitLabel: UILabel!

    @IBOutlet weak var distanceWidget: LEDWidget!
    @IBOutlet weak var distanceTitle: UILabel!
    @IBOutlet weak var maxSpeedWidget: LEDWidget!
    @IBOutlet weak var altitudeWidget: LEDWidget!
    @IBOutlet weak var headingWidget: LEDWidget!
    @IBOutlet weak var headingTitle: UILabel!
    @IBOutlet weak var accuracyWidget: LEDWidget!
    @IBOutlet weak var accuracyTitle: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var temperatureWidget: LEDWidget!
    @IBOutlet weak var temperatureTitle: UILabel!
    
    private var viewModel: GPSControlViewModel
    private var disposeBag: DisposeBag = DisposeBag()
    private weak var container: Container?
    private var lastSpeed: Double = 0
    
    private enum Constants {
        static let backgroundColor = UIColor(hexString: "96ad9d")
        static let foregroundColor: UIColor = .black
        static let speedUnitKey = "speed_units"
        static let temperatureUnitKey = "temperature_units"
    }

    public init(container: Container) {
        self.container = container
        let locationManager = container.resolve(LocationManagerType.self)
        let dataStore = container.resolve(DataStoreProviderType.self)
        let weatherProvider = container.resolve(WeatherProviderType.self)
        viewModel = GPSControlViewModel(manager: locationManager, dataStore: dataStore, weatherProvider: weatherProvider)

        super.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        viewModel = GPSControlViewModel(manager: nil, dataStore: nil, weatherProvider: nil)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = GPSControlViewModel(manager: nil, dataStore: nil, weatherProvider: nil)
        super.init(coder: coder)
    }
    
    deinit {
        viewModel.shutdown()
        
        disposeBag.dispose()
        disposeBag = DisposeBag()
    }
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureColors()
        
        setupObservers()

        viewModel.initializeGPS()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        speedWidget?.setValue(lastSpeed)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - UI Actions
    
    @IBAction func gpsTogglePressed(_ sender: Any) {
        viewModel.toggleGPS()
    }
    
    // MARK: - Private Functions
    
    private func configureColors() {
        let backgroundColor = Constants.backgroundColor
        let textColor = Constants.foregroundColor

        view.backgroundColor = backgroundColor

        let config = LEDWidgetColorConfig(color: textColor, background: backgroundColor)
        let widgets = [speedWidget,
                       distanceWidget,
                       maxSpeedWidget,
                       altitudeWidget,
                       headingWidget,
                       accuracyWidget,
                       temperatureWidget
        ]
        
        for widget in widgets {
            widget?.setColor(config: config)
        }
        
        if let labels = view.subviews.filter({ $0 is UILabel }) as? [UILabel] {
            for label in labels {
                label.textColor = textColor
            }
        }
    }
    
    private func setupObservers() {
        viewModel.gpsButtonText.observeNext { [weak self] (title) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.gpsToggleButton.setTitle(title, for: .normal)
        }.dispose(in: disposeBag)
        
        viewModel.speed.observeNext { [weak self] (speed) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.lastSpeed = speed
            strongSelf.speedWidget?.setValue(speed)
        }.dispose(in: disposeBag)
        
        viewModel.distanceForDisplay.observeNext { [weak self] (distance) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.distanceWidget.setValue(distance)
        }.dispose(in: disposeBag)
        
        viewModel.maxSpeed.observeNext { [weak self] (speed) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.maxSpeedWidget.setValue(speed)
        }.dispose(in: disposeBag)
        
        viewModel.altitudeForDisplay.observeNext { [weak self] (altitude) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.altitudeWidget.setValue(altitude)
        }.dispose(in: disposeBag)
        
        viewModel.heading.observeNext { [weak self] (heading) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.headingWidget.setValue(heading)
        }.dispose(in: disposeBag)
        
        viewModel.headingTitle.observeNext { [weak self] (title) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.headingTitle.text = title
        }.dispose(in: disposeBag)
        
        viewModel.accuracyForDisplay.observeNext { [weak self] (accuracy) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.accuracyWidget.setValue(accuracy)
        }.dispose(in: disposeBag)
        
        viewModel.clock.observeNext { [weak self] (clock) in
            guard let strongSelf = self else {
                return
            }

            strongSelf.clockLabel.text = clock
        }.dispose(in: disposeBag)
        
        viewModel.elapsedTime.observeNext { [weak self] (elapsed) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.elapsedTimeLabel.text = elapsed
        }.dispose(in: disposeBag)
        
        UserDefaults.standard.reactive.keyPath(Constants.speedUnitKey, ofType: Optional<String>.self, context: .immediateOnMain).observeNext { [weak self] (newValue) in
            guard let strongSelf = self, let newValueExists = newValue else {
                return
            }
            
            strongSelf.viewModel.setSpeedUnit(unit: newValueExists)
            strongSelf.speedUnitLabel.text = newValueExists

            var distanceUnit = "km"
            var distanceUnitSmall = "m"
            if newValueExists == GPSControlViewModel.Constants.imperialRate {
                distanceUnit = "miles"
                distanceUnitSmall = "ft"
            }
            
            strongSelf.distanceTitle.text =  "distance - \(distanceUnit)"
            strongSelf.accuracyTitle.text = "accuracy - \(distanceUnitSmall)"
        }.dispose(in: disposeBag)
        
        _ = UserDefaults.standard.reactive.keyPath(Constants.temperatureUnitKey, ofType: Optional<String>.self, context: .immediateOnMain).observeNext { [weak self] (newValue) in
            guard let strongSelf = self, let valueExists = newValue, let firstChar = valueExists.first else {
                return
            }
            
            strongSelf.temperatureTitle.text = "temperature - \(firstChar)"
        }

        viewModel.temperature.observeNext { [weak self] (temperature) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.temperatureWidget.setValue(temperature)
        }.dispose(in: disposeBag)
    }
}
