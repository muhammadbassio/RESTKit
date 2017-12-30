//
//  APIManager.swift
//  RESTKit
//
//  Created by Muhammad Bassio on 12/29/17.
//  Copyright © 2017 Muhammad Bassio. All rights reserved.
//

import Foundation
import OAuthKit

open class APIManager {
  
  open var configuration:APIConfiguration = APIConfiguration()
  open var accessToken:OAuth2Token?                       // the access token to use in API requests
  
  public init(configuration:APIConfiguration) {
    self.configuration = configuration
    self.loadSavedToken()
  }
  
  /// Override to provide your own logic
  open func loadSavedToken() {
    
  }
  
  /// Override to provide your own logic
  open func saveToken() {
    
  }
  
  open func sendRequest(endPoint:APIEndPoint, completion:@escaping ((_ response:DataResponse<Any>) -> Void)) {
    var headers = self.configuration.mainHeaders
    if endPoint.requiresAuthentication {
      if let token = self.accessToken?.accessToken, token != "", let type = self.accessToken?.tokenType, type != "" {
        headers["Authorization"] = "\(type) \(token)"
      } else {
        let error = OAKError(localizedDescription: "No access token found, Please authorize first")
        let response = DataResponse<Any>(request: nil, response: nil, data: nil, result: Result.failure(error))
        completion(response)
        return
      }
    }
    request("\(self.configuration.baseURL)/\(endPoint.path)", method: endPoint.method, headers: headers).validate().responseJSON { dataResponse in
      completion(dataResponse)
    }
  }
  
  open func sendRequest(endPoint:APIEndPoint, parameters:Parameters, completion:@escaping ((_ response:DataResponse<Any>) -> Void)) {
    var headers = self.configuration.mainHeaders
    if endPoint.requiresAuthentication {
      if let token = self.accessToken?.accessToken, token != "", let type = self.accessToken?.tokenType, type != "" {
        headers["Authorization"] = "\(type) \(token)"
      } else {
        let error = OAKError(localizedDescription: "No access token found, Please authorize first")
        let response = DataResponse<Any>(request: nil, response: nil, data: nil, result: Result.failure(error))
        completion(response)
        return
      }
    }
    request("\(self.configuration.baseURL)/\(endPoint.path)", method: endPoint.method, parameters:parameters, headers: headers).validate().responseJSON { dataResponse in
      completion(dataResponse)
    }
  }
  
  open func uploadRequest(to endPoint:APIEndPoint, with pamameters:[String:Any], attachments:[String:Data], completion: @escaping ((_ response:DataResponse<Any>) -> Void)) {
    if let token = self.accessToken?.accessToken, token != "", let type = self.accessToken?.tokenType, type != "" {
      var headers = self.configuration.mainHeaders
      headers["Authorization"] = "\(type) \(token)"
      upload(multipartFormData: { multipartFormData in
        for (key, value) in pamameters {
          if value is String || value is Int {
            if let data = "\(value)".data(using: String.Encoding.utf8) {
              multipartFormData.append(data, withName: key)
            }
          }
        }
        for (key, value) in attachments {
          multipartFormData.append(value, withName: key, mimeType: "image/jpeg")
        }
      }, to: "\(self.configuration.baseURL)/\(endPoint.path)", method:endPoint.method, headers:headers, encodingCompletion: { encodingResult in
        switch encodingResult {
        case .success(let upload, _, _):
          upload.responseJSON { dataResponse in
            completion(dataResponse)
          }
        case .failure(let encodingError):
          let response = DataResponse<Any>(request: nil, response: nil, data: nil, result: Result.failure(encodingError))
          completion(response)
        }
      })
    } else {
      let error = OAKError(localizedDescription: "No access token found, Please authorize first")
      let response = DataResponse<Any>(request: nil, response: nil, data: nil, result: Result.failure(error))
      completion(response)
      return
    }
  }
}
