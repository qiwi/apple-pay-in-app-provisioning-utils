# In-App Provisioning Utils

In-App Provisioning Utils consists of 2 helpers:
1. [PassKitCardDetector](#PassKitCardDetector) - logic for button 'Add Card to Apple Pay'
2. [PassKitRequestGenerator](#PassKitRequestGenerator) - implements In-App Provisioning flow

## Requirements
* iOS 10.3+

## Installation

### CocoaPods
```
pod 'InAppProvisioningUtils', :git => 'https://github.com/qiwi/apple-pay-in-app-provisioning-utils'
```

### Carthage
```
git "https://github.com/qiwi/apple-pay-in-app-provisioning-utils" "master"
```


## Preparation
Before use them you should setup Xcode project:
1. Turn on Wallet in target capabilities
2. Add follow keys and values to Entitlements file ([more details](https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/ApplePayandPassKitEntitlements/ApplePayandPassKitEntitlements.html)):
```xml
  <key>com.apple.developer.pass-type-identifiers</key>
    <array>
      <string>$(TeamIdentifierPrefix)*</string>
    </array>
  <key>com.apple.developer.payment-pass-provisioning</key>
    <true/>
```

3. Turn on In-App Provisioning in Provisioning Profiles. You need special permission from Apple to submit apps with this key enabled. For more information, contact apple-pay-inquiries@apple.com. After all you have 2 ways:
 1. Turn on with [match action](https://docs.fastlane.tools/actions/match/) '*template_name*' parameter in [fastlane](https://fastlane.tools)
 2. Or manual on [developer.apple.com](https://developer.apple.com) and edit Provision profiles ![](https://github.com/qiwi/apple-pay-in-app-provisioning-utils/blob/master/images/provision-profile.png)

4. In payment system admin page (Visa/MasterCard/...) setup cards design, link on you app for cards (app id, team id, deeplink to app)


 ## PassKitCardDetector

 PassKitCardDetector allows you to check secure chip on device and apple watch for implement 'Add Card to Apple Pay' button!
 Usage:
 ```swift
public static func checkSupportApplePay(cardSuffix: String, bankName: String) -> PassKitCardDetectorResult

// cardSuffix - 4 last digits of card
// bankName - need to filter cards - you can find it with bankNames() if added card before with 'Apple Wallet'

enum PassKitCardDetectorResult {
	case notSupport
	case disabled
	case enabled(primaryAccountIdentifier:String?)
}

// primaryAccountIdentifier - need to show correctly screen with device selection for in-app provisioning

 ```

bankNames returns bank names for your cards added to Apple Wallet (only cards linked with your app):

```swift
public static func bankNames() -> [String]
```

also for users which have ability to add cards, app should show landing. You can use this method:

```swift
public static func isApplePayAvailableForDevice() -> Bool
```

 ## PassKitRequestGenerator
 ### Warning: You should test it only on testflight builds, in all other cases - completion will fail
 PassKitRequestGenerator helps you implement In-App Provisioning flow:

1. Initialization
 ```swift
  init(cardholderName: String,
       primaryAccountIdentifier: String?, // you get it from PassKitCardDetectorResult
       primaryAccountSuffix: String, // last 4 digits of card
       localizedDescription: String,
       paymentNetwork: PaymentNetwork, // VISA/MasterCard
       encryptionScheme: EncryptionScheme, // ECC_V2/RSA_V2
       pollingFrequency: Double = 0.2, // After in-app completion to apple watch, you need to wait a bit time, card adds to passKit not immediately :(
       pollingAttemptCount: Int = 5,
       requestBlock: @escaping RequestBlock, //pass data to your backend and back to apple
       completion: @escaping Completion) {}
 ```
2. Create In-AppViewController, which you should present to user
 ```swift
 public func inAppViewController() -> UIViewController
  ```
