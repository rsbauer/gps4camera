//
//  LEDWidget.swift
//  gps4camera
//
//  Created by Astro on 11/29/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import UIKit

public struct LEDWidgetColorConfig {
    var color: UIColor
    var background: UIColor
}

public class LEDWidget: NibView {
    
    @IBOutlet weak var majorValueLabel: UITextField!
    @IBOutlet weak var minorValueLabel: UITextField!
    
    private var majorFontSize: CGFloat = 0
    private(set) var colorConfig: LEDWidgetColorConfig?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        if majorFontSize == 0 {
            majorFontSize = majorValueLabel.font?.pointSize ?? majorFontSize
            if majorFontSize != frame.size.height {
                majorFontSize = frame.size.height
            }
            minorValueLabel.font = majorValueLabel.font?.withSize(majorFontSize / 1.75)
            majorValueLabel.font = majorValueLabel.font?.withSize(majorFontSize)
        }
    }
    
    public func setColor(config: LEDWidgetColorConfig) {
        colorConfig = config
        
        majorValueLabel.textColor = config.color
        minorValueLabel.textColor = config.color
        backgroundColor = config.background
    }
    
    public func setValue(_ value: Double) {
        let rounded = round(value * 10) / 10
        let valueStr = "\(rounded)"
        let parts = valueStr.components(separatedBy: ".")
        
        if parts[0] == "-999" {
            majorValueLabel.text = "-"
            minorValueLabel.text = ""
            return
        }
        
        majorValueLabel.text = parts[0]
        minorValueLabel.text = "\(parts[1])"
    }
}
