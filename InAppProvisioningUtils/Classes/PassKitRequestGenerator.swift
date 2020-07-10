//
//  PassKitRequestGenerator.swift
//
//  Created by s.petruk on 22/07/2019.
//  Copyright © 2019 QIWI. All rights reserved.
//

import Foundation
import PassKit

public class PassKitRequestGenerator: NSObject {

	public enum PaymentNetwork {
		case visa
		case masterCard
	}

	public enum EncryptionScheme {
		case ECC_V2
		case RSA_V2
	}

	private let cardholderName: String
	private let paymentNetwork: PaymentNetwork
	private let encryptionScheme: EncryptionScheme
	private let primaryAccountIdentifier: String?
	private let primaryAccountSuffix: String
	private let localizedDescription: String
	
	private let passKitDelegate: PassKitViewControllerDelegate

	
	/// Setup you logic for inAppViewController
	/// - Parameters:
	///   - cardholderName:
	///   - primaryAccountIdentifier: you get it from PassKitCardDetectorResult
	///   - primaryAccountSuffix: last 4 digits of card
	///   - localizedDescription: for instance card name
	///   - paymentNetwork: VISA/MasterCard
	///   - encryptionScheme: ECC_V2/RSA_V2
	///   - pollingFrequency: After in-app completion to apple watch, you need to wait a bit time, card adds to passKit not immediately :(
	///   - pollingAttemptCount: Max time for polling result
	///   - requestBlock: pass data to your backend and back to apple
	///   - completion:
	public init(cardholderName: String,
				primaryAccountIdentifier: String?,
				primaryAccountSuffix: String,
				localizedDescription: String,
				paymentNetwork: PaymentNetwork,
				encryptionScheme: EncryptionScheme,
				pollingFrequency: Double = 0.2,
				pollingAttemptCount: Int = 5,
				requestBlock: @escaping RequestBlock,
				completion: @escaping Completion) {

		self.cardholderName = cardholderName
		self.primaryAccountIdentifier = primaryAccountIdentifier
		self.primaryAccountSuffix = primaryAccountSuffix
		self.localizedDescription = localizedDescription
		self.paymentNetwork = paymentNetwork
		self.encryptionScheme = encryptionScheme
		
		self.passKitDelegate = PassKitViewControllerDelegate(pollingFrequency: pollingFrequency, pollingAttemptCount: pollingAttemptCount, requestBlock: requestBlock, completion: completion)
	}

	
	/// Show it for user for add card to apple pay
	public func inAppViewController() -> UIViewController {
		guard let requestConfiguration = generateRequestConfiguration() else {
			fatalError()
		}

		guard let vc = PKAddPaymentPassViewController(requestConfiguration: requestConfiguration, delegate: self.passKitDelegate) else {
			fatalError()
		}

		return vc
	}

	private func generateRequestConfiguration() -> PKAddPaymentPassRequestConfiguration? {
		let eScheme = encryptionScheme.pkEncryptionScheme
		guard let request = PKAddPaymentPassRequestConfiguration(encryptionScheme: eScheme) else {
			return nil
		}
		request.cardholderName = cardholderName
		request.primaryAccountSuffix = primaryAccountSuffix
		request.localizedDescription = localizedDescription
		request.paymentNetwork = paymentNetwork.pkPaymentNetwork
		request.primaryAccountIdentifier = primaryAccountIdentifier

		return request
	}
}

fileprivate extension PassKitRequestGenerator.PaymentNetwork {
	var pkPaymentNetwork: PKPaymentNetwork {
		switch self {
		case .visa:
			return .visa
		case .masterCard:
			return .masterCard
		}
	}
}

fileprivate extension PassKitRequestGenerator.EncryptionScheme {
	var pkEncryptionScheme: PKEncryptionScheme {
		switch self {
		case .ECC_V2:
			return .ECC_V2
		case .RSA_V2:
			if #available(iOS 10.0, *) {
				return .RSA_V2
			} else {
				fatalError("Minimum required version is iOS 10.0")
			}
		}
	}
}
