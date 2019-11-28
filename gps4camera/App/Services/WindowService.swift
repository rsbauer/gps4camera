//
//  WindowService.swift
//  gps4camera
//
//  Created by Astro on 11/10/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import UIKit
import FontAwesome_swift
import PluggableAppDelegate

public protocol WindowServiceType {
}

public final class WindowService: NSObject, ApplicationService, WindowServiceType {
    
    private enum Constants {
        static let iconWidth = 30
        static let iconHeight = 30
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        guard let appDelegate = application.delegate as? AppDelegateType else {
            return true
        }

        let container = appDelegate.container
        
        let tabBarController = UITabBarController()
        let filesNavController = UINavigationController(rootViewController: FilesViewController(container: container))
        filesNavController.title = "Files"
        filesNavController.tabBarItem.image = UIImage.fontAwesomeIcon(name: .folder, style: .solid, textColor: .black, size: CGSize(width: Constants.iconWidth, height: Constants.iconHeight))

        let gpsController = GPSControlViewController(container: container)
        gpsController.title = "GPS"
        gpsController.tabBarItem.image = UIImage.fontAwesomeIcon(name: .satellite, style: .solid, textColor: .black, size: CGSize(width: Constants.iconWidth, height: Constants.iconHeight))

        let timeSyncController = TimeSyncViewController()
        timeSyncController.title = "Sync"
        timeSyncController.tabBarItem.image = UIImage.fontAwesomeIcon(name: .qrcode, style: .solid, textColor: .black, size: CGSize(width: Constants.iconWidth, height: Constants.iconHeight))
        
        let settings = SettingsViewController()
        settings.title = "Settings"
        settings.tabBarItem.image = UIImage.fontAwesomeIcon(name: .cogs, style: .solid, textColor: .black, size: CGSize(width: Constants.iconWidth, height: Constants.iconHeight))
        let settingsNav = UINavigationController(rootViewController: settings)


        tabBarController.viewControllers = [
            gpsController,
            timeSyncController,
            filesNavController,
            settingsNav
        ]
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
        
        return true
    }
}


