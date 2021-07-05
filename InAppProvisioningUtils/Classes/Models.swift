//
//  Models.swift
//  InAppProvisioningUtils
//
//  Created by s.petruk on 04/10/2019.
//  Copyright © 2019 s.petruk. All rights reserved.
//

import Foundation

public struct Payload {
	public var raw: Data
	public var base64: String {
		return raw.base64EncodedString()
	}
	public var hex: String {
		return raw.map { String(format: "%02x", $0) }.joined()
	}

    public init(_ raw: Data) {
        self.raw = raw
    }
}

public struct PassData {
	public var certificates: [Payload]
	public var nonce: Payload
	public var nonceSignature: Payload

    public init(certificates: [Payload], nonce: Payload, nonceSignature: Payload) {
        self.certificates = certificates
        self.nonce = nonce
        self.nonceSignature = nonceSignature
    }
}

public enum Result {
	case success
	case nothing
	case error(Error)
}

public struct InAppRequest {
	public let activationData: Data
	public let ephemeralPublicKey: Data
	public let encryptedDataBase: Data
	
	public init(activationData: Data, ephemeralPublicKey: Data, encryptedDataBase: Data) {
		self.activationData = activationData
		self.ephemeralPublicKey = ephemeralPublicKey
		self.encryptedDataBase = encryptedDataBase
	}
}



