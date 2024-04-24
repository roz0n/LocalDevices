//
//  NetworkConnectionError.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/23/24.
//

import Foundation

enum NetworkConnectionError: Error, LocalizedError {
  case connectionFailure
  case listenerFailure
  
  var errorDescription: String {
    switch self {
      case .connectionFailure:
        "Unable to create a NWConnection"
      case .listenerFailure:
        "Unable to create a NWListener"
    }
  }
}
