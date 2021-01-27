// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "InAppProvisioningUtils",
	platforms: [
		.iOS("10.3"),
	],
	products: [
		.library(
			name: "InAppProvisioningUtils",
			type: .static,
			targets: ["InAppProvisioningUtils"]
		)
	],
	
	dependencies: [],
	targets: [
		.target(name: "InAppProvisioningUtils", dependencies: [], path: "InAppProvisioningUtils", exclude: ["Info.plist"])
	],
	
	swiftLanguageVersions: [
		.v5
	]
)
