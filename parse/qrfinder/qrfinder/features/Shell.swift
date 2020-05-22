//
//  Shell.swift
//  qrfinder
//
//  Created by Astro on 5/21/20.
//  Copyright © 2020 RSB. All rights reserved.
//

import Foundation

// from: https://stackoverflow.com/questions/26971240/how-do-i-run-an-terminal-command-in-a-swift-script-e-g-xcodebuild
public class Shell {
    @discardableResult static func shell(_ command: String) -> (String?, Int32) {
        let task = Process()

        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        task.waitUntilExit()
        return (output, task.terminationStatus)
    }
}
