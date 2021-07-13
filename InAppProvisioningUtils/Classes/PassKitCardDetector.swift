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
    ///  Allows you to check secure chip on device and apple watch
    /// - Parameters:
    ///   - cardSuffix: 4 last digits of card
    ///   - bankName: need to filter cards - you can find it with bankNames() if added card before with 'Apple Wallet'
    /// - Returns: enum PassKitCardDetectorResult
    public static func checkSupportApplePay(cardSuffix: String, bankName: String? = nil) -> PassKitCardDetectorResult {
        assert(cardSuffix.count == 4, "cardSuffix lenght should be equal to 4 characters!")

        if !isApplePayAvailableForDevice {
            return .notSupport
        }

        if #available(iOS 13.4, *) {
            return canAddToApplePaySecurePass(cardSuffix, bankName: bankName)
        } else {
            return canAddToApplePayPass(cardSuffix, bankName: bankName)
        }
    }

    private static func canAddToApplePayPass(_ cardSuffix: String, bankName: String? = nil) -> PassKitCardDetectorResult {
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

    /// Allow get bank names from linked with your app cards in 'Apple Wallet'
    public static var bankNames: [String] {
        let passLibrary = PKPassLibrary()
        var arr = passLibrary.passes(of: .payment).map({ $0.organizationName })
        if #available(iOS 13.4, *) {
            arr.append(contentsOf: passLibrary.remoteSecureElementPasses.map({ $0.organizationName }))
        } else {
            arr.append(contentsOf: passLibrary.remotePaymentPasses().map({ $0.organizationName }))
        }
        return Array(Set(arr))
    }

    private static func pass(of passes: [PKPass], suffix: String, bankName: String? = nil) -> PKPass? {
        let pass = passes.first { pass -> Bool in
            var passSuffix: String = "none"
            if let cardSuffix = pass.paymentPass?.primaryAccountNumberSuffix {
                passSuffix = cardSuffix
            }
            let foundBank = bankName == nil ? bankNames.contains(pass.organizationName) : pass.organizationName == bankName
            return foundBank && passSuffix == suffix
        }
        return pass
    }

    private static func getPrimaryAccountIdentifier(_ localPass: PKPass?, _ remotePass: PKPass?) -> String? {
        return localPass?.paymentPass?.primaryAccountIdentifier
            ?? remotePass?.paymentPass?.primaryAccountIdentifier
    }

    public static var isApplePayAvailableForDevice: Bool {
        return PKAddPaymentPassViewController.canAddPaymentPass()
    }
}
@available(iOS 13.4, *)
extension PassKitCardDetector {
    private static func canAddToApplePaySecurePass(_ cardSuffix: String, bankName: String? = nil) -> PassKitCardDetectorResult {
        let passLibrary = PKPassLibrary()
        let passes = passLibrary.passes(of: .payment)
        let remotePasses = passLibrary.remoteSecureElementPasses

        let cardFromPasses = pass(of: passes, suffix: cardSuffix, bankName: bankName)
        let cardFromRemote = securePass(of: remotePasses, suffix: cardSuffix, bankName: bankName)

        let primaryAccountIdentifier = getPrimaryAccountIdentifier( cardFromPasses, cardFromRemote)
        var canAddCard = true
        if let identifier = primaryAccountIdentifier, !identifier.isEmpty {
            canAddCard = passLibrary.canAddSecureElementPass(primaryAccountIdentifier: identifier)
        }
        if canAddCard {
            return .enabled(primaryAccountIdentifier)
        }
        return .disabled
    }

    private static func securePass(of passes: [PKSecureElementPass], suffix: String, bankName: String? = nil) -> PKSecureElementPass? {
        let pass = passes.first { pass -> Bool in
            var passSuffix: String = "none"
            if let cardSuffix = pass.paymentPass?.primaryAccountNumberSuffix {
                passSuffix = cardSuffix
            }

            let foundBank = bankName == nil ? bankNames.contains(pass.organizationName) : pass.organizationName == bankName
            return foundBank && passSuffix == suffix
        }
        return pass
    }
}
