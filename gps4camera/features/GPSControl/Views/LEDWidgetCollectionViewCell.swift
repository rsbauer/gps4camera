//
//  LEDWidgetCollectionViewCell.swift
//  gps4camera
//
//  Created by Astro on 11/23/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import InAppSettingsKit
import UIKit

class LEDWidgetCollectionViewCell: UICollectionViewCell, NibLoadable {

    @IBOutlet weak var majorValueLabel: UILabel!
    @IBOutlet weak var minorValueLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var majorValueDimmedLabel: UILabel!
    
    static var nibName = "LEDWidgetCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func setValue(_ value: Double, units: String) {
        let rounded = round(value * 10) / 10
        let valueStr = "\(rounded)"
        let parts = valueStr.components(separatedBy: ".")
        majorValueLabel.text = parts[0]
        minorValueLabel.text = ".\(parts[1])"
        unitLabel.text = units
    }
    
    public func setDimmedValue(_ value: String) {
        majorValueDimmedLabel.text = value
    }
    
    public func setUnits(_ units: String) {
        unitLabel.text = units
    }
}
