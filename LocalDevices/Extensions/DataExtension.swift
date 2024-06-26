//
//  DataExtension.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/24/24.
//

import Foundation

extension Data {
  /// Creates a new data buffer from the hexadecimal string.
  /// - Parameter hex: A string containing hexadecimal digits.
  init?(hex: String) {
    let len = hex.count / 2
    var data = Data(capacity: len)
    
    for i in 0..<len {
      let j = hex.index(hex.startIndex, offsetBy: i*2)
      let k = hex.index(j, offsetBy: 2)
      let bytes = hex[j..<k]
      
      if var num = UInt8(bytes, radix: 16) {
        data.append(&num, count: 1)
      } else {
        return nil
      }
    }
    
    self = data
  }
}
