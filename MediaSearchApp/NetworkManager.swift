//
//  NetworkManager.swift
//  MediaSearchApp
//
//  Created by KKNANXX on 5/28/24.
//

import UIKit

class NetworkManager: NSObject {
    
    static let shared: NetworkManager = {
        let instance = NetworkManager()
        return instance
    }()
    //static let shared: NetworkManager = NetworkManager()
    
    private override init() {
        super.init()
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
        case PUT
        case DELETE
    }
    
    enum NetworkError: Error {
        case invalidURL
        case noData
    }
    
    func request(urlString: String, method: HTTPMethod, body: Data?, completion: @escaping (Result<Data, Error>) -> Void) {
        
        // 1. Step - Make URL
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // 2. Step - Make Request
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // Base authentication
        /*
         let credStr = "any formula"
         
         let logindata = credStr.data(using: .utf8)
         
         let base64 = logindata?.base64EncodedString()
         
         request.setValue(base64, forHTTPHeaderField: "Authorization")
         */
        request.timeoutInterval = 20.0 // timeout error
        
        // 3. Make Actual Session URL
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else  {
                completion(.failure(NetworkError.noData))
                return
            }
            
            completion(.success(data))
            
        })
        
        task.resume()
        
    }
}
