//
//  TimeSyncViewController.swift
//  gps4camera
//
//  Created by Astro on 11/7/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import UIKit

class TimeSyncViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    private let dateFormatForDisplay = DateFormatter()
    private let dateFormatForDateDisplay = DateFormatter()
    private let dateFormatForQR = DateFormatter()

    private var currentTime: Date = Date() {
        didSet {
            timeLabel.text = dateFormatForDisplay.string(from: currentTime)
            dateLabel.text = dateFormatForDateDisplay.string(from: currentTime)
            imageView.image = generateQRCode(from: dateFormatForQR.string(from: currentTime))
        }
    }
    
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sync"
        dateFormatForDisplay.dateFormat = "hh:mm:ssa"
        dateFormatForDateDisplay.dateFormat = "EEEE, MMMM d, yyyy"
//        dateFormatForQR.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
//        dateFormatForQR.timeZone = TimeZone(secondsFromGMT: 0)
//        dateFormatForQR.locale = Locale(identifier: "en_US_POSIX")
        dateFormatForQR.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SS"
        currentTime = Date()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] (timer) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.currentTime = Date()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
}
