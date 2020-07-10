//
//  PassKitViewControllerDelegate.swift
//  InAppProvisioningUtils
//
//  Created by s.petruk on 04/10/2019.
//  Copyright © 2019 s.petruk. All rights reserved.
//

import Foundation
import PassKit

class PassKitViewControllerDelegate: NSObject {
	private var resultPass: PKPass?
	private let pollingFrequency: Double
	private let pollingAttemptCount: Int
	private let requestBlock: RequestBlock
	private let completion: Completion
	
	init(pollingFrequency: Double,
		 pollingAttemptCount: Int,
		 requestBlock: @escaping RequestBlock,
		 completion: @escaping Completion) {

		self.pollingFrequency = pollingFrequency
		self.pollingAttemptCount = pollingAttemptCount
		self.requestBlock = requestBlock
		self.completion = completion
	}
}

extension PassKitViewControllerDelegate: PKAddPaymentPassViewControllerDelegate {
	
	public func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController,
											 generateRequestWithCertificateChain certificates: [Data],
											 nonce: Data,
											 nonceSignature: Data,
											 completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
		
		let certs = certificates.map { data -> Payload in
			let str = Payload(raw: data)
			return str
		}
		
		let n = Payload(raw: nonce)
		let nSignature = Payload(raw: nonceSignature)
		let data = PassData(certificates: certs, nonce: n, nonceSignature: nSignature)
		requestBlock(data, { request in
			let r = PKAddPaymentPassRequest()
			r.activationData = request.activationData
			r.encryptedPassData = request.encryptedDataBase
			r.ephemeralPublicKey = request.ephemeralPublicKey
			handler(r)
		})
		
	}
	
	public func addPaymentPassViewController(_ controller: PKAddPaymentPassViewController,
											 didFinishAdding pass: PKPaymentPass?,
											 error: Error?) {
		if error == nil && pass != nil {
			resultPass = pass
			checkIfCardWasAddedToWallet()
		} else {
			completion(.nothing)
		}
	}
	
	@objc private func checkIfCardWasAddedToWallet(_ count: Int = 0) {
		let passLibrary = PKPassLibrary()
		guard let pass = resultPass else {
			completion(.success)
			return
		}
		if passLibrary.containsPass(pass) {
			completion(.success)
		} else {
			if Double(count) * pollingFrequency < Double(pollingAttemptCount) {
				self.perform(#selector(checkIfCardWasAddedToWallet(_:)), with: count + 1, afterDelay: pollingFrequency)
			} else {
				completion(.success)
			}
		}
	}
}
