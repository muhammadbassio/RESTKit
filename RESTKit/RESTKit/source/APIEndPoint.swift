//
//  APIEndPoint.swift
//  RESTKit
//
//  Created by Muhammad Bassio on 12/29/17.
//  Copyright © 2017 Muhammad Bassio. All rights reserved.
//

import Foundation
import OAuthKit

open class APIEndPoint {
  open var method:HTTPMethod = .get
  open var path:String = ""
  open var requiresAuthentication:Bool = false
  
  init(path:String, method:HTTPMethod, requiresAuth:Bool) {
    self.path = path
    self.method = method
    self.requiresAuthentication = requiresAuth
  }
}
