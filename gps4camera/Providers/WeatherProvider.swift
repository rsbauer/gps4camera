//
//  WeatherProvider.swift
//  gps4camera
//
//  Created by Astro on 12/1/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit

public protocol WeatherProviderType {
    func getTemperature(latitude: Double, longitude: Double)
    func setDelegate(delegate: WeatherProviderDelegate)
}

public protocol WeatherProviderDelegate: class {
    func update(weather: Weather)
}

public class WeatherProvider: WeatherProviderType {
    
    private var networkProvider: NetworkProviderType
    private weak var delegate: WeatherProviderDelegate?
    
    public init(networkProvider: NetworkProviderType) {
        self.networkProvider = networkProvider
    }
    
    public func setDelegate(delegate: WeatherProviderDelegate) {
        self.delegate = delegate
    }
    
    public func getTemperature(latitude: Double, longitude: Double) {
        // https://darksky.net/forecast/lat,long
        // <span class="summary swap">
        let urlString = "https://darksky.net/forecast/\(latitude),\(longitude)"
        networkProvider.get(url: urlString) { [weak self] (response) in
            guard let strongSelf = self else {
                return
            }
            
            switch response {
            case .success(let result):
                strongSelf.processResult(result)
            case .failure(let error):
                print("\(#function): Failed to retrieve weather. \(error.localizedDescription)")
            }
        }
    }
    
    private func processResult(_ result: AnyObject) {
        guard let data = result as? Data else {
            return
        }
        
        let html = String.init(decoding: data, as: UTF8.self)
        let pattern = #"<span class="summary swap">(\d+)"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(html.startIndex..<html.endIndex, in: html)
            regex.enumerateMatches(in: html, options: [], range: range) { [weak self] (match, _, stop) in
                guard let match = match, let strongSelf = self else {
                    return
                }
                
                if match.numberOfRanges == 2, let capture = Range(match.range(at: 1), in: html) {
                    let result = html[capture]
                    if let temperature =  Double(result) {
                        let weatherResult = Weather(temperatureInF: temperature)
                        DispatchQueue.main.async {
                            strongSelf.delegate?.update(weather: weatherResult)
                        }
                    }
                }
            }

        } catch {
            print("\(#function): Regex failed: \(error.localizedDescription)")
        }
    }
    
}

public struct Weather {
    var temperatureInF: Double
}
