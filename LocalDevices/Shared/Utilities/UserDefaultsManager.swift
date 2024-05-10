//
//  UserDefaultsManager.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/10/24.
//

import Foundation

class UserDefaultsManager {
  
  static let shared = UserDefaultsManager()
  
  private init() {}
  
  enum UDMError: Error {
    case decodeFailure
  }
  
  func get<T: Codable>(_ key: String) throws -> T? {
    do {
      guard let data = UserDefaults.value(forKey: key) as? Data else {
        throw UDMError.decodeFailure
      }
      
      return try JSONDecoder().decode(T.self, from: data)
    } catch {
      throw error
    }
  }
  
  func set<T: Codable>(_ key: String, _ value: T, _ completion: ((T) -> Void)?) throws {
    do {
      let data = try JSONEncoder().encode(value)
      UserDefaults.setValue(data, forKey: key)
      
      completion?(try JSONDecoder().decode(T.self, from: data))
    } catch {
      throw error
    }
  }
  
}
