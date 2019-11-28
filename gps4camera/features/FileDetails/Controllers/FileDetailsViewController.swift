//
//  FileDetailsViewController.swift
//  gps4camera
//
//  Created by Astro on 11/24/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import CoreData
import MapKit
import ReactiveKit
import Swinject
import UIKit

class FileDetailsViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var viewModel: FileDetailsViewModel
    private var disposeBag: DisposeBag = DisposeBag()
    private weak var container: Container?
    
    private enum Constants {
        static let shareTitle = "Share"        
    }

    public init(container: Container, track: Track) {
        self.container = container
        viewModel = FileDetailsViewModel(track: track)
        super.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        viewModel = FileDetailsViewModel(track: nil)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = FileDetailsViewModel(track: nil)
        super.init(coder: coder)
    }
    
    deinit {
        viewModel.shutdown()
        
        disposeBag.dispose()
        disposeBag = DisposeBag()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.track.value?.name ?? ""
        setupNavBar()
        mapView.delegate = self
        
        if let track = viewModel.track.value {
            draw(track: track, mapView: mapView)
        }
    }
    
    private func setupNavBar() {
        let shareButton = UIBarButtonItem(title: Constants.shareTitle, style: .plain, target: self, action: #selector(shareButtonPressed))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    @objc public func shareButtonPressed() {
        guard let track = viewModel.track.value else {
            return
        }

        ShareManager.share(track: track, viewController: self)
    }
        
    private func draw(track: Track, mapView: MKMapView) {
        guard let pois =  track.pois?.array as? [POI] else {
            return
        }

        var coordinates: [CLLocationCoordinate2D] = []
        
        for poi in pois {
            let coordinate = CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude)
            coordinates.append(coordinate)
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        mapView.addOverlay(polyline)
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 50, bottom: 300, right: 50), animated: true)
    }
}

extension  FileDetailsViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
            polyLineRenderer.strokeColor = .blue
            polyLineRenderer.lineWidth = 3

            return polyLineRenderer
        }
        
        return MKPolylineRenderer(overlay: overlay)
    }
}
