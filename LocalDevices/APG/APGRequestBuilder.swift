//
//  APGRequestBuilder.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/24/24.
//

import Foundation
import CryptoSwift

struct APGRequestBuilder {
  
  var device: NetworkDevice
  
  static let aesKey: Data = Data(hex: "a5003c5f8bee76b19e512b8c7cdec4089188d5e60b302aaf95a463291b568e56")!
  static let hmacKey: Data = Data(hex: "766755bf8a6fa21aa257a934aca57e25388d92b67c410fc63d082ec1a2e211e3")!
  
  var separatorString: String {
    String(bytes: [0x0a], encoding: .utf8)!
  }

  var separator: Data {
    Data([0x0a])
  }
  
  private func generateNonceRequestString() -> Data? {
    var nonceRequestString = "<XML><PacketType>NRequest</PacketType>"
    
    nonceRequestString.append(separatorString)
    nonceRequestString.append("<ProductName>APG Atwood</ProductName>")
    nonceRequestString.append(separatorString)
    nonceRequestString.append("<SerialNum>429004699</SerialNum>")
    nonceRequestString.append(separatorString)
    nonceRequestString.append("<MacAddr>70:B3:D5:BC:F8:D6</MacAddr>")
    nonceRequestString.append(separatorString)
    nonceRequestString.append("</XML>")
    
    return nonceRequestString.data(using: .utf8)
  }

  private func generateUniqueNonce(length: Int = 16) -> Data? {
    var uniqueNonce = Data(count: length)
    
    let result = uniqueNonce.withUnsafeMutableBytes { mutableBytes in
      SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes.baseAddress!)
    }
    
    if result == errSecSuccess {
      return uniqueNonce
    } else {
      print("Unable to generate nonce")
      return nil
    }
  }

  private func generateTimestamp() -> Data? {
    let formatter = DateFormatter()
    
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS" // to match the "2016-03-17T08:03:00.002" format from the docs
    formatter.locale = Locale(identifier: "en_US_POSIX") // POSIX to ensure consistency
    formatter.timeZone = TimeZone(secondsFromGMT: 0) // Use GMT to match the example
    
    let timestamp = formatter.string(from: Date())
    
    // Ensure the UTF-8 encoded data is exactly 23 bytes
    guard let timestampData = timestamp.data(using: .utf8), timestampData.count == 23 else {
      return nil
    }
    
    // This is exactly 23 bytes when UTF-8 encoded
    return timestamp.data(using: .utf8)
  }

  private func generateInitVector(length: Int = 16) -> Data? {
    var iv = Data(count: length)
    
    let result = iv.withUnsafeMutableBytes {
      SecRandomCopyBytes(kSecRandomDefault, length, $0.baseAddress!)
    }
    
    return (result == errSecSuccess) ? iv : nil
  }

  private func generatePresharedCreds() -> (username: Data?, password: Data?) {
    let username: Data? = Data(hex: "1374b8fb458199745608be1da15ed1f67b0b2b788c4110fd5ec38000139c6b5c3b426975dd6c421dcba8cd4f1ca23eacafa491ef23a0460065c0afda92dc29067f56a14853e3f73eb9b315c2cbe139ae9d438671f0c5ac00f9643524773989187aec177b")
    let password: Data? = Data(hex: "962769c1a44b2ad16f3970cb3f1abfe02400b1c451d22c8b68b6efb9041717844bd5b7493e059aefe657acb7e973e0560ab5361678bc45a7add88e77aeb668c0a2396e8a4fe5486051534e3569b59a2c31352b62ba2ff5db890d8721fc2b46411ee27169")
    
    return (username, password)
  }
  
  enum APGMessageType {
    case discoveryRequest
    case nonceRequest
    case tlsChange
    
  }
  
  func generateEncryptedMessage(type: APGMessageType) -> Data {
    // 1. Nonce Request
//    let requestStringData = generateNonceRequestString()
    let requestStringData = "NRequest".data(using: .utf8)

    // 2. A 16-byte unique nonce for once time use
    let uniqueNonceData = generateUniqueNonce()

    // 3. A 23-byte timestamp
    let timestampData = generateTimestamp()

    // 4. A 16-byte unique initialization vector
    let initVectorData = generateInitVector()

    // 5. 100 byte pre-shared username and password
    let (username, password) = generatePresharedCreds()

    let usernameData = username
    let passwordData = password

    // 6. Padded concatenation produces unencrypted Cipher-Text
    var cipherTextData = Data()

    cipherTextData.append(usernameData!.prefix(100))
    cipherTextData.append(passwordData!.prefix(100))
    cipherTextData.append(uniqueNonceData!)
    cipherTextData.append(timestampData!)
    cipherTextData.append(separator)
    cipherTextData.append(requestStringData!)
    cipherTextData.append(separator)

    print(cipherTextData as NSData)

    // 7. Create the actual encrypted cipher text
    let aes = try? AES(key: APGRequestBuilder.aesKey.bytes, blockMode: CBC(iv: initVectorData!.bytes), padding: .pkcs7)
    let encryptedCipherText = try? aes?.encrypt(cipherTextData.bytes)
    let encryptedData = Data(encryptedCipherText!)

    print(encryptedCipherText as Any)
    print(encryptedData as Any)

    // 8. Create the completed cipher: (the 16-byte init vector || the 400-byte AES encrypted cipher text)
    var completeCipher = Data()

    completeCipher.append(initVectorData!)
    completeCipher.append(encryptedData)

    print(completeCipher as Any)

    // 9. Generate a 32-byte HMAC code
    let hmac = HMAC(key: APGRequestBuilder.hmacKey.bytes, variant: .sha2(.sha256))
    let hmacResult = try? hmac.authenticate(completeCipher.bytes)
    let hmacData = Data(hmacResult!)

    print("HMAC (SHA256): \(hmacData as NSData)")

    // 10. Complete the datagram
    var datagram = Data()
    datagram.append(hmacData)
    datagram.append(completeCipher)

    print("Complete datagram: \(datagram as NSData)")
    
    return datagram
  }
  
  
}
