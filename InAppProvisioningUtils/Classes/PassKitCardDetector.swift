//
//  PassKitHelper+PassKitCardDetector.swift
//
//  Created by s.petruk on 22/07/2019.
//  Copyright © 2019 QIWI. All rights reserved.
//

import Foundation
import PassKit

public enum PassKitCardDetectorResult {
	case notSupport
	case disabled
	case enabled(_ primaryAccountIdentifier:String?)
}

public class PassKitCardDetector {
	public static func checkSupportApplePay(cardSuffix: String, bankName: String) -> PassKitCardDetectorResult {
		assert(cardSuffix.count == 4, "cardSuffix lenght should be equal to 4 characters!")
		
		if !isApplePayAvailableForDevice() {
			return .notSupport
		}

		let passLibrary = PKPassLibrary()
		let passes = passLibrary.passes(of: .payment)
		let remotePasses = passLibrary.remotePaymentPasses()

		let cardFromPasses = pass(of: passes, suffix: cardSuffix, bankName: bankName)
		let cardFromRemote = pass(of: remotePasses, suffix: cardSuffix, bankName: bankName)

		let primaryAccountIdentifier = getPrimaryAccountIdentifier( cardFromPasses, cardFromRemote)

		var canAddCard = true
		if let identifier = primaryAccountIdentifier, !identifier.isEmpty {
			canAddCard = passLibrary.canAddPaymentPass(withPrimaryAccountIdentifier: identifier)
		}

		if canAddCard {
			return .enabled(primaryAccountIdentifier)
		}

		return .disabled
	}

	public static func bankNames() -> [String] {
		let passLibrary = PKPassLibrary()
		var arr = passLibrary.passes(of: .payment)
		arr.append(contentsOf: passLibrary.remotePaymentPasses())
		let set = Set(arr).map { $0.organizationName }
		return set
	}

	private static func pass(of passes: [PKPass], suffix: String, bankName: String) -> PKPass? {
		let pass = passes.first { pass -> Bool in
			var passSuffix: String = "none"
			if let cardSuffix = pass.paymentPass?.primaryAccountNumberSuffix {
				passSuffix = cardSuffix
			}

			return pass.organizationName == bankName && passSuffix == suffix
		}
		return pass
	}

	private static func getPrimaryAccountIdentifier(_ localPass: PKPass?, _ remotePass: PKPass?) -> String? {
		var primaryAccountIdentifier: String?
		primaryAccountIdentifier = localPass?.paymentPass?.primaryAccountIdentifier
		if primaryAccountIdentifier == nil {
			primaryAccountIdentifier = remotePass?.paymentPass?.primaryAccountIdentifier
		}

		return primaryAccountIdentifier
	}

	public static func isApplePayAvailableForDevice() -> Bool {
		return PKAddPaymentPassViewController.canAddPaymentPass()
	}
}
