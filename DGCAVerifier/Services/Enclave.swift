//
/*-
 * ---license-start
 * eu-digital-green-certificates / dgca-verifier-app-ios
 * ---
 * Copyright (C) 2021 T-Systems International GmbH and all other contributors
 * ---
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ---license-end
 */
//  
//  Enclave.swift
//  PatientScannerDemo
//  
//  Created by Yannick Spreen on 4/25/21.
//  


import Foundation

struct Enclave {
  static let encryptAlg = SecKeyAlgorithm.eciesEncryptionCofactorVariableIVX963SHA256AESGCM
  static let signAlg = SecKeyAlgorithm.ecdsaSignatureMessageX962SHA512
  static let symmetricKey = generateOrLoadKey(with: "symmetricKey")

  static func tag(for name: String) -> Data {
    "\(Bundle.main.bundleIdentifier ?? "app").\(name)".data(using: .utf8)!
  }

  static func generateKey(with name: String? = nil) -> (SecKey?, String?) {
    let name = name ?? UUID().uuidString
    let tag = Enclave.tag(for: name)
    var error: Unmanaged<CFError>?
    guard
      let access =
        SecAccessControlCreateWithFlags(
          kCFAllocatorDefault,
          kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
          [.privateKeyUsage], // , .biometryCurrentSet],
          &error
        )
    else {
      return (nil, error?.takeRetainedValue().localizedDescription)
    }
    var attributes: [String: Any] = [
      kSecAttrKeyType as String:          kSecAttrKeyTypeEC,
      kSecAttrKeySizeInBits as String:    256,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String:    true,
        kSecAttrApplicationTag as String: tag,
        kSecAttrAccessControl as String:  access
      ]
    ]
    #if !targetEnvironment(simulator)
    attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
    #endif
    guard
      let privateKey = SecKeyCreateRandomKey(
        attributes as CFDictionary,
        &error
      )
    else {
      return (nil, error?.takeRetainedValue().localizedDescription)
    }
    error?.release()
    return (privateKey, nil)
  }

  static func loadKey(with name: String) -> SecKey? {
    let tag = Enclave.tag(for: name)
    let query: [String: Any] = [
      kSecClass as String                 : kSecClassKey,
      kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
      kSecAttrApplicationTag as String    : tag,
      kSecReturnRef as String             : true
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard
      status == errSecSuccess
    else {
      return nil
    }
    return (item as! SecKey)
  }

  static func generateOrLoadKey(with name: String) -> SecKey? {
    if let key = loadKey(with: name) {
      return key
    }
    return generateKey(with: name).0
  }

  static func encrypt(data: Data, with key: SecKey) -> (Data?, String?) {
    guard let publicKey = SecKeyCopyPublicKey(key) else {
      return (nil, "Cannot retrieve public key.")
    }
    guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, encryptAlg) else {
      return (nil, "Algorithm not supported.")
    }
    var error: Unmanaged<CFError>?
    let cipherData = SecKeyCreateEncryptedData(
      publicKey,
      encryptAlg,
      data as CFData,
      &error
    ) as Data?
    let err = error?.takeRetainedValue().localizedDescription
    error?.release()
    return (cipherData, err)
  }

  static func decrypt(data: Data, with key: SecKey, completion: @escaping (Data?, String?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      let (result, error) = syncDecrypt(data: data, with: key)
      completion(result, error)
    }
  }

  static func syncDecrypt(data: Data, with key: SecKey) -> (Data?, String?) {
    guard SecKeyIsAlgorithmSupported(key, .decrypt, encryptAlg) else {
      return (nil, "Algorithm not supported.")
    }
    var error: Unmanaged<CFError>?
    let clearData = SecKeyCreateDecryptedData(
      key,
      encryptAlg,
      data as CFData,
      &error
    ) as Data?
    let err = error?.takeRetainedValue().localizedDescription
    error?.release()
    return (clearData, err)
  }

  static func verify(data: Data, signature: Data, with key: SecKey) -> (Bool, String?) {
    guard let publicKey = SecKeyCopyPublicKey(key) else {
      return (false, "Cannot retrieve public key.")
    }
    guard SecKeyIsAlgorithmSupported(publicKey, .verify, signAlg) else {
      return (false, "Algorithm not supported.")
    }
    var error: Unmanaged<CFError>?
    let isValid = SecKeyVerifySignature(
      publicKey,
      signAlg,
      data as CFData,
      signature as CFData,
      &error
    )
    let err = error?.takeRetainedValue().localizedDescription
    error?.release()
    return (isValid, err)
  }

  static func sign(data: Data, with key: SecKey, completion: @escaping (Data?, String?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      let (result, error) = syncSign(data: data, with: key)
      completion(result, error)
    }
  }

  static func syncSign(data: Data, with key: SecKey) -> (Data?, String?) {
    guard SecKeyIsAlgorithmSupported(key, .sign, signAlg) else {
      return (nil, "Algorithm not supported.")
    }
    var error: Unmanaged<CFError>?
    let signature = SecKeyCreateSignature(
      key,
      signAlg,
      data as CFData,
      &error
    ) as Data?
    let err = error?.takeRetainedValue().localizedDescription
    error?.release()
    return (signature, err)
  }
}
