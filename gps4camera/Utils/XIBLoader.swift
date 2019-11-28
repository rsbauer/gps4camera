//
//  XIBLoader.swift
//  gps4camera
//
//  Created by Astro on 11/23/19.
//  Copyright © 2019 RSB. All rights reserved.
//
import UIKit

// from: https://www.prolificinteractive.com/2017/06/09/xib-awakening-uniform-way-load-xibs/

protocol Identifiable {
    static var identifier: String { get }
}

extension Identifiable {
    static var identifier: String {
        return String(describing: self)
    }
}

protocol NibLoadable: Identifiable {
    static var nibName: String { get }
}

extension NibLoadable {
    @nonobjc static var nibName: String {
        return String(describing: self)
    }
}

extension UIView {
    static func loadFromNib<T: NibLoadable>(ofType _: T.Type) -> T {
        guard let nibViews = Bundle.main.loadNibNamed(T.nibName, owner: nil, options: nil) else {
            fatalError("Could not instantiate view from nib file.")
        }
        
        for view in nibViews {
            if let typedView = view as? T {
                return typedView
            }
        }
        fatalError("Could not instantiate view from nib file.")
    }
}
