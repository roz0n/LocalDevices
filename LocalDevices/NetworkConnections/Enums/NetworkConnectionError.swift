//
//  NetworkConnectionError.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/23/24.
//

import Foundation
import Network

enum NetworkConnectionError: Error, LocalizedError {
  case connectionFailure
  case listenerFailure
  case sendConnectFailed
  case sendError(NWError)
  
  var errorDescription: String {
    switch self {
      case .connectionFailure:
        "Unable to establish a NWConnection"
      case .listenerFailure:
        "Unable to create a NWListener"
      case .sendConnectFailed:
        "No connection found"
      case .sendError:
        "The message failed to send"
    }
  }
}
