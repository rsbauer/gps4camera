//
//  Share.swift
//  gps4camera
//
//  Created by Astro on 11/27/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import CoreData
import UIKit

public class ShareManager {
    private enum Constants {
        static let errorTitle = "Error"
        static let fileSaveFailed = "Failed to save file."
    }
    
    static func share(track: Track, viewController: UIViewController) {
        let alertController = UIAlertController(title: "Share Format", message: "Select file format to share", preferredStyle: .actionSheet)
        let kml = UIAlertAction(title: "KML", style: .default) { (action) in
            if let path = FileRepository.filename(for: track, format: .kml) {
                let error = FileRepository.action(.export(path, .kml, track))
                if let error = error {
                    let alert = UIAlertController(title: Constants.errorTitle, message: Constants.fileSaveFailed + " \(error.localizedDescription)", preferredStyle: .alert)
                    viewController.present(alert, animated: true, completion: nil)
                } else {
                    ShareManager.shareFile(path: path, viewController: viewController)
                }
            }
        }
        
        let gpx = UIAlertAction(title: "GPX", style: .default) { (action) in
            if let path = FileRepository.filename(for: track, format: .gpx) {
                let error = FileRepository.action(.export(path, .gpx, track))
                if let error = error {
                    let alert = UIAlertController(title: Constants.errorTitle, message: Constants.fileSaveFailed + " \(error.localizedDescription)", preferredStyle: .alert)
                    viewController.present(alert, animated: true, completion: nil)
                } else {
                    ShareManager.shareFile(path: path, viewController: viewController)
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        alertController.addAction(kml)
        alertController.addAction(gpx)
        alertController.addAction(cancel)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static private func shareFile(path: URL, viewController: UIViewController) {
        let activity = UIActivityViewController(activityItems: [path], applicationActivities: nil)
        activity.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            // Delete the file after having shared or cancelled.
            FileRepository.remove(path)
        }

        viewController.present(activity, animated: true, completion: nil)
    }

}
