//
//  SettingsViewController.swift
//  gps4camera
//
//  Created by Astro on 11/27/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import InAppSettingsKit

public class SettingsViewController: IASKAppSettingsViewController {
    
}

extension SettingsViewController: IASKSettingsDelegate {
    public func settingsViewControllerDidEnd(_ sender: IASKAppSettingsViewController!) {
        
    }
    
    public func tableView(_ tableView: UITableView!, heightFor specifier: IASKSpecifier!) -> CGFloat {
        return 44
    }
    
    public func tableView(_ tableView: UITableView!, cellFor specifier: IASKSpecifier!) -> UITableViewCell! {
        var cell = tableView.dequeueReusableCell(withIdentifier: specifier.key() as String)
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: specifier.key())
            cell?.accessoryType = .disclosureIndicator
        }
        
        cell?.textLabel?.text = specifier.title()
        
        return cell
    }
}
