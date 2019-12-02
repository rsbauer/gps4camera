//
//  NetworkProvider.swift
//  gps4camera
//
//  Created by Astro on 12/1/19.
//  Copyright © 2019 RSB. All rights reserved.
//

import UIKit

public protocol NetworkProviderType {
    func get(url: String, completionBlock: @escaping NetworkCompletionBlock)
}

public typealias DataResponse = Result<AnyObject, NSError>
public typealias NetworkCompletionBlock = (DataResponse) -> Void

public class NetworkProvider: NetworkProviderType {
    private var session = URLSession(configuration: .default)
    private var task: URLSessionDataTask?
    
    private enum Constants {
    }
    
    public init() {
    }
    
    /// Make a get request using NSURLSession
    ///
    /// - Parameter url: String url to request
    /// - Parameter completionBlock: NetworkCompletionBlock if success or failed
    public func get(url: String, completionBlock: @escaping NetworkCompletionBlock) {
        guard let urlObject = URL(string: url) else {
            return
        }

        // if a task is in flight, cancel it
        task?.cancel()
        
        task = session.dataTask(with: urlObject, completionHandler: { [weak self] (responseData, response, error) in
            guard let strongSelf = self else {
                return
            }
            
            defer {
                strongSelf.task = nil
            }
            
            if let errorExists = error {
                completionBlock(DataResponse.failure(errorExists as NSError))
            }
            
            if let responseExists = response as? HTTPURLResponse,
                responseExists.statusCode == 200,
                let data = responseData {
                completionBlock(DataResponse.success(data as AnyObject))
            }
        })
        
        task?.resume()
    }
}
