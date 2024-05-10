//
//  NetworkDevice.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/24/24.
//

import Foundation

struct NetworkDevice: Codable {
  
  var id: String {
    "\(serialNumber):\(ipAddress):\(macAddress)"
  }
  
  var ipAddress: String
  var macAddress: String
  var serialNumber: String
  var productName: String
  var productBarcode: String
  
  enum CodingKeys: String, CodingKey {
    case ipAddress = "IPAddr"
    case macAddress = "MacAddr"
    case serialNumber = "SerialNum"
    case productName = "ProductName"
    case productBarcode = "Barcode"
  }
  
}
