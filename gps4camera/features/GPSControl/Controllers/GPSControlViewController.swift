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
    
    private var viewModel: GPSControlViewModel
    private var disposeBag: DisposeBag = DisposeBag()
    private weak var container: Container?
    private var led: LEDWidgetCollectionViewCell?
    private var lastSpeed: Double = 0

    public init(container: Container) {
        self.container = container
        let locationManager = container.resolve(LocationManagerType.self)
        let dataStore = container.resolve(DataStoreProviderType.self)
        viewModel = GPSControlViewModel(manager: locationManager, dataStore: dataStore)

        super.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        viewModel = GPSControlViewModel(manager: nil, dataStore: nil)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = GPSControlViewModel(manager: nil, dataStore: nil)
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
        title = "GPS"

        led = LEDWidgetCollectionViewCell.loadFromNib(ofType: LEDWidgetCollectionViewCell.self)
        guard let ledExists = led else {
            return
        }

        ledExists.frame = CGRect(x: 0, y: 120, width: 150, height: 100)
//        ledExists.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        view.addSubview(ledExists)

        setupObservers()

        viewModel.initializeGPS()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        led?.setValue(lastSpeed, units: getSpeedUnit())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    // MARK: - UI Actions
    
    @IBAction func gpsTogglePressed(_ sender: Any) {
        viewModel.toggleGPS()
    }
    
    // MARK: - Private Functions
    
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
            strongSelf.led?.setValue(speed, units: strongSelf.getSpeedUnit())
        }.dispose(in: disposeBag)
    }
    
    private func getSpeedUnit() -> String {
        if let speedUnits = UserDefaults.standard.value(forKey: "speed_units") as? String {
            return speedUnits
        }
        
        return "mph"
    }
}
