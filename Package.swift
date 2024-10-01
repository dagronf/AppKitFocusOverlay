// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "AppKitFocusOverlay",
	platforms: [
		.macOS(.v10_13)
	],
	products: [
		.library(
			name: "AppKitFocusOverlay",
			targets: ["AppKitFocusOverlay"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/HotKey", from: "0.2.0")
	],
	targets: [
		.target(
			name: "AppKitFocusOverlay",
			dependencies: ["HotKey"]),
		.testTarget(
			name: "AppKitFocusOverlayTests",
			dependencies: ["AppKitFocusOverlay"]),
	]
)
