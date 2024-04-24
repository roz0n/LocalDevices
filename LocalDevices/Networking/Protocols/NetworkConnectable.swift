//
//  NetworkConnectable.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/23/24.
//

import Foundation
import Network

/// Represents services that can manage and act on network connections created by entities conforming to ``NetworkConnectionBuilder``.
protocol NetworkConnectable {
  var connection: NWConnection? { get }
  var listener: NWListener? { get }
  var queue: DispatchQueue { get }
  
  func startConnection() throws
  func startListener() throws
}
