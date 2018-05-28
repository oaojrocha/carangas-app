//
//  REST.swift
//  Carangas
//
//  Created by School Picture Dev on 23/05/18.
//  Copyright © 2018 Eric Brito. All rights reserved.
//

import Foundation

enum CarError {
    case url, taskError(error: Error), noResponse, noData, responseStatusCode(code: Int), invalidJSON
}

enum RESTOperation {
    case save, delete, update
}

class REST {
    private static let basePath = "https://carangas.herokuapp.com/cars"
    private static let configuration : URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = false
        config.httpAdditionalHeaders = ["Content-Type" : "application/json"]
        config.timeoutIntervalForRequest = 30.0
        config.httpMaximumConnectionsPerHost = 5
        return config
    }()
    
    private static let session = URLSession(configuration: configuration)
    
    class func loadBrands(onComplete: @escaping ([Brand]) -> Void) {
        guard let url = URL(string: "https://fipeapi.appspot.com/api/1/carros/marcas.json") else {
            return
        }
        
        let dataTask = session.dataTask(with: url) {(data: Data?, resp: URLResponse?, error: Error?) in
            
            if error != nil {
                return
            }
            
            guard let resp = resp as? HTTPURLResponse else {
                return
            }
            
            if resp.statusCode != 200 {
                return
            }
            
            // status 200
            
            guard let data = data else {
                return
            }
            
            do {
                let brands = try JSONDecoder().decode([Brand].self, from: data)
                onComplete(brands)
            } catch {}
            
        }
        
        dataTask.resume()
    }
    
    class func loadCars(onComplete: @escaping ([Car]) -> Void, onError: @escaping (CarError) -> Void) {
        guard let url = URL(string: basePath) else {
            onError(.url)
            return
        }
        
        let dataTask = session.dataTask(with: url) {(data: Data?, resp: URLResponse?, error: Error?) in
            
            if error != nil {
                onError(.taskError(error: error!))
                return
            }
            
            guard let resp = resp as? HTTPURLResponse else {
                onError(.noResponse)
                return
            }
            
            if resp.statusCode != 200 {
                onError(.responseStatusCode(code: resp.statusCode))
                return
            }
            
            // status 200
            
            guard let data = data else {
                onError(.noData)
                return
            }
            
            do {
                let cars = try JSONDecoder().decode([Car].self, from: data)
                onComplete(cars)
            } catch {
                onError(.invalidJSON)
            }
            
        }
        
        dataTask.resume()
    }
    
    class func update(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .update, onComplete: onComplete)
    }
    
    class func save(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .save, onComplete: onComplete)
    }
    
    class func delete(car: Car, onComplete: @escaping (Bool) -> Void) {
        applyOperation(car: car, operation: .delete, onComplete: onComplete)
    }
    
    private class func applyOperation(car: Car, operation: RESTOperation, onComplete: @escaping (Bool) -> Void) {
        
        var urlString: String = ""
        var httpMethod: String = ""
        
        switch operation {
            case .save:
                httpMethod = "POST"
                 urlString = basePath
            case .delete:
                httpMethod = "DELETE"
                urlString = basePath + "/" + car._id!
            case .update:
                httpMethod = "PUT"
                urlString = basePath + "/" + car._id!
        }
        
        
        guard let url = URL(string: urlString) else {
            onComplete(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        guard let json =  try? JSONEncoder().encode(car) else {
            onComplete(false)
            return
        }
        
        request.httpBody = json
        
        let dataTask = session.dataTask(with: request) { (data, resp, error) in
            if error != nil {
                onComplete(false)
                return
            }
            
            guard let resp = resp as? HTTPURLResponse, resp.statusCode == 200, let _ = data else {
                onComplete(false)
                return
            }
            
            onComplete(true)
            
        }
        
        dataTask.resume()
    }
    

    
}
