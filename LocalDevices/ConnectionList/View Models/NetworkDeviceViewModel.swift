//
//  NetworkDeviceViewModel.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/24/24.
//

import Foundation

final class NetworkDeviceViewModel: ObservableObject {
  
  private (set) var device: NetworkDevice
  
  // MARK: - Lifecycle
  
  init(device: NetworkDevice) {
    self.device = device
  }
  
  // MARK: - Computeds
  
  var name: String {
    device.productName
  }
  
  var serialNumber: String {
    device.serialNumber
  }
  
  var ipAddress: String {
    device.ipAddress
  }
  
  var macAddress: String {
    device.macAddress
  }
  
  var productBarcode: String {
    device.productBarcode
  }
  
}

extension NetworkDeviceViewModel: Identifiable, Hashable {
  
  static func == (lhs: NetworkDeviceViewModel, rhs: NetworkDeviceViewModel) -> Bool {
    lhs.device.id == rhs.device.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(device.id)
  }
  
}
