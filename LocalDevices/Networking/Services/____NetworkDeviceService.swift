//
//  ____NetworkDeviceService.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/23/24.
//

import Foundation
import Combine
import Network
import XMLCoder
import CryptoSwift

/// A service that both initializes and runs a connection and listener for a given host, port, and provider conforming to ``NetworkConnectionBuilder``.
class ____NetworkDeviceService: NetworkConnectable {
  
  private (set) var connection: NWConnection?
  private (set) var listener: NWListener?
  private (set) var queue: DispatchQueue
  
  private (set) var deviceDiscoveryPublisher = PassthroughSubject<LocalNetworkDevice, Never>()
  private (set) var deviceMessageErrorPublisher = PassthroughSubject<NWError, Never>()
  
  // MARK: - Lifecycle
  
  /// A failable initializer that
  init?(host: NWEndpoint.Host,
        port: NWEndpoint.Port,
        queue: DispatchQueue = .global(),
        provider: NetworkConnectionBuilder) {
    do {
      self.connection = provider.createConnection(host: host, port: port)
      self.listener = try provider.createListener(port: port, on: queue)
      self.queue = queue
      
      try startConnection()
      try startListener()
      
      print("____NetworkDeviceService init success!")
    } catch {
      print("Error initializing ____NetworkDeviceService: \(error.localizedDescription)\n\(error)")
      return nil
    }
  }
  
  deinit {
    connection?.cancel()
    listener?.cancel()
  }
  
  // MARK: - Connection
  
  func startConnection() throws {
    guard let connection else {
      throw NetworkConnectionError.connectionFailure
    }
    
    connection.start(queue: queue)
    print("Connection started")
  }
  
  func startListener() throws {
    guard let listener else {
      throw NetworkConnectionError.listenerFailure
    }
    
    listener.newConnectionHandler = { [weak self] in
      print("New Connection to listener")

      if let queue = self?.queue {
        self?.handleNewConnection($0, on: queue)
      }
    }
    
    print("Listener started")
    listener.start(queue: queue)
  }
  
  func handleNewConnection(_ connection: NWConnection, on queue: DispatchQueue) {
    connection.receiveMessage { [weak self] content, contentContext, isComplete, error in
      guard error == nil else {
        print("Error handling new connection: \(error as Any)")
        return
      }
      
      if let content, let message = String(data: content, encoding: .utf8) {
        print("New connection content is String: \(message)")
        
        if let decodedData = try? XMLDecoder().decode(LocalNetworkDevice.self, from: content) {
          self?.deviceDiscoveryPublisher.send(decodedData)
        }
      } else if let content {
        self?.handleResponseMessage(content)
      } else {
        print("New connection did not provide content")
      }
    }
    
    connection.start(queue: queue)
    
    connection.stateUpdateHandler = { newState in
      switch newState {
        case .setup:
          print("Setting up connection")
        case .waiting(_):
          print("Waiting to set up connection")
        case .preparing:
          print("Preparing connection")
        case .ready:
          print("Connection Ready")
        case .failed(_):
          print("Connection Failed")
        case .cancelled:
          print("Connection Cancelled")
        @unknown default:
          print("Connection Status unknown...")
      }
    }
  }
  
  // MARK: - Transmission
  
  func sendContent(_ content: Data) throws {
    guard let connection else {
      throw NetworkConnectionError.connectionFailure
    }
    
    connection.send(content: content, completion: .contentProcessed({ [weak self] error in
      if let error {
        print("Error sending message \(error.localizedDescription)\n\(error)")
        self?.deviceMessageErrorPublisher.send(error)
      }
      
      // Prepare to listen for an incoming response from the drawer
      //      self?.getResponse()
      
      connection.receiveMessage { content, contentContext, isComplete, error in
        if let error {
          print("Message response error: \(error)")
        }
        
        if let content, let responseMessage = String(data: content, encoding: .utf8) {
          print("Message response: \(responseMessage)")
        }
      }
    }))
  }
  
  func handleResponseMessage(_ content: Data) {
    print("New connection data packet: \(content) \(String(data: content, encoding: .ascii))")
    
    let receivedHmac = content.prefix(32)
    let iv = content[32..<48]
    let cipherText = content.suffix(from: 48)
    
    // 1. Verify HMAC
    do {
      let hmac = HMAC(key: APGRequestBuilder.hmacKey.bytes, variant: .sha2(.sha256))
      
      var fullMessage = Data(iv)
      fullMessage.append(cipherText)
      
      let calculatedHmac = try hmac.authenticate(fullMessage.bytes)
      
      guard receivedHmac.bytes == calculatedHmac else {
        print("HMAC verification failed")
        return
      }
      
      print("HMAC verification success!")
    } catch {
      print("HMAC verification error: \(error.localizedDescription)\n\(error)")
    }
    
    // 2. Decrypt Cipher-Text
    do {
      let aes = try AES(key: APGRequestBuilder.aesKey.bytes, blockMode: CBC(iv: iv.bytes), padding: .pkcs7)
      let decryptedDataBytes = try aes.decrypt(cipherText.bytes)
//      let decryptedData = Data(decryptedDataBytes)
      
      let recievedNonce = decryptedDataBytes[200..<216]
      let recievedResponse = decryptedDataBytes.suffix(from: 217).dropLast() // skip one x0a
      
      // Convert to string
      if let message = String(data: Data(recievedResponse), encoding: .utf8) {
        print("[!] Decrypted response: \(message)")
      } else {
        print("Decryption was successful but data could be parsed into a string :(")
      }
    } catch {
      print("Decryption error: \(error)")
    }
  }
  
}
