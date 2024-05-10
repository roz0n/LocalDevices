//
//  LocalNetworkDeviceViewModel.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/24/24.
//

import Foundation

final class LocalNetworkDeviceViewModel: ObservableObject {
  
  private (set) var device: LocalNetworkDevice
  
  // MARK: - Lifecycle
  
  init(device: LocalNetworkDevice) {
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

extension LocalNetworkDeviceViewModel: Identifiable, Hashable {
  
  static func == (lhs: LocalNetworkDeviceViewModel, rhs: LocalNetworkDeviceViewModel) -> Bool {
    lhs.device.id == rhs.device.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(device.id)
  }
  
}
