//
//  AppDelegate.swift
//  AppKitFocusPathDisplay Demo
//
//  Created by Darren Ford on 31/12/2021.
//

import Cocoa

import AppKitFocusOverlay
import HotKey

let _globalFocusOverlay = AppKitFocusOverlay()

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		_ = _globalFocusOverlay
	}

	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
}
