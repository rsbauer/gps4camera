//
//  UIColorExtension.swift
//  gps4camera
//
//  Created by Astro on 12/1/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import UIKit

// from: https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexInt: UInt64 = 0
        let scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt64(&hexInt)

        let red = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexInt & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexInt & 0xff) >> 0) / 255.0
        let alpha = alpha

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
