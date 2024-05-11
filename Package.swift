// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "AppKitFocusOverlay",
	platforms: [
		.macOS(.v10_11)
	],
	products: [
		.library(
			name: "AppKitFocusOverlay",
			targets: ["AppKitFocusOverlay"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/HotKey", from: "0.1.3")
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
