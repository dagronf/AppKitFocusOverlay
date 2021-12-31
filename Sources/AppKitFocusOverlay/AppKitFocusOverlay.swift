//
//  FocusOverlay.swift
//  AppKitFocusPathDisplay
//
//  Created by Darren Ford on 28/12/2021.
//  Copyright © 2021 Darren Ford. All rights reserved.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import AppKit
import Foundation
import HotKey

public class AppKitFocusOverlay {
	/// Create an instance of the focus overlay
	/// - Parameters:
	///   - windowHotKey: The hotkey to use for displaying the focus path for the window
	///   - viewHotKey: The hotkey to use for displaying the focus path from the currently focussed UI element.
	///   - shouldRecalculateKeyViewLoop: If true, recalculates the window's key view loop before displaying the overlay
	public init(
		windowHotKey: HotKey = HotKey(key: .leftBracket, modifiers: [.option]),
		viewHotKey: HotKey = HotKey(key: .rightBracket, modifiers: [.option]),
		shouldRecalculateKeyViewLoop: Bool = true
	) {
		self.hotKeyWindow = windowHotKey
		self.hotKeyView = viewHotKey
		self.shouldRecalculateKeyViewLoop = shouldRecalculateKeyViewLoop
		self.setupHotKeys()
	}

	/// Present the focus overlay starting at the specified view
	public func present(startingAt view: NSView) {
		guard let window = view.window else { return }
		_present(window: window, startingAt: view)
	}

	/// Present the focus overlay for the current window. if a responder is specified, start from this specific ui element
	public func present(_ window: NSWindow, _ responder: NSResponder? = nil) {
		guard let startingView = (responder ?? window.initialFirstResponder) as? NSView else { return }
		_present(window: window, startingAt: startingView)
	}

	/// Hide the focus overlay
	public func clear() {
		self._lastAttachedWindow = nil
		detachResizeHandler()
		self.overlayView.currentChain = []
	}

	// private

	private lazy var overlayWindow: NSWindow = {
		let w = NSWindow(contentRect: .zero,
							  styleMask: [.borderless],
							  backing: .buffered,
							  defer: false)
		w.backgroundColor = .clear
		w.ignoresMouseEvents = true
		w.contentView = self.overlayView
		return w
	}()
	private let overlayView = FocusOverlayView()
	private let shouldRecalculateKeyViewLoop: Bool
	private var resizeObserver: NSObjectProtocol?

	private let hotKeyWindow: HotKey
	private let hotKeyView: HotKey

	private weak var _lastAttachedWindow: NSWindow? {
		willSet {
			self._lastAttachedWindow?.removeChildWindow(self.overlayWindow)
		}
		didSet {
			if let w = _lastAttachedWindow {
				w.addChildWindow(self.overlayWindow, ordered: .above)
				self.overlayWindow.level = .normal
			}
		}
	}
}

private extension AppKitFocusOverlay {
	class ViewRepresent {
		weak var view: NSView?
		let rect: CGRect
		init(view: NSView, rect: CGRect) {
			self.view = view
			self.rect = rect
		}

		var isValid: Bool { return self.view != nil }
	}

	enum Which {
		case top
		case left
		case bottom
		case right
		case center
	}
}

private extension AppKitFocusOverlay {
	func setupHotKeys() {
		do {
			self.hotKeyWindow.keyDownHandler = { [weak self] in
				if let `self` = self, let w = NSApp.mainWindow {
					self.present(w)
				}
			}
			self.hotKeyWindow.keyUpHandler = { [weak self] in
				self?.clear()
			}
		}

		do {
			self.hotKeyView.keyDownHandler = { [weak self] in
				if let `self` = self, let w = NSApp.mainWindow, let v = w.firstResponder as? NSView {
					self.present(startingAt: v)
				}
			}
			self.hotKeyView.keyUpHandler = { [weak self] in
				self?.clear()
			}
		}
	}

	func _present(window: NSWindow, startingAt view: NSView) {
		detachResizeHandler()

		guard let contentView = window.contentView else { return }

		if shouldRecalculateKeyViewLoop {
			window.recalculateKeyViewLoop()
		}

		self._lastAttachedWindow = window

		// Position our window
		let r = window.convertToScreen(contentView.frame)

		self.overlayWindow.setFrame(r, display: true)
		self.overlayView.frame = window.contentLayoutRect

		// And update the content of the focus view
		self.overlayView.currentChain = self.nextFocusFor(view)

		// And listen for attached window size changes
		attachResizeHandler(window: window, startingAt: view)

		Swift.print("window - \(self.overlayWindow), \(self.overlayWindow.frame)")
	}

	func nextFocusFor(_ view: NSView, seenViews: [NSView] = []) -> [ViewRepresent] {
		let actualView: NSView = {
			if let v = view as? NSTextView,
				v.isFieldEditor,
				let parent = v.delegate as? NSTextField
			{
				return parent
			}
			else {
				return view
			}
		}()

		if seenViews.contains(actualView) {
			// We've completed the key loop.
			return []
		}

		var result: [AppKitFocusOverlay.ViewRepresent] = []

		if actualView.canBecomeKeyView {
			let r = actualView.convert(actualView.bounds, to: nil)
			// Swift.print("view -> \(actualView): \(r)")
			result.append(ViewRepresent(view: actualView, rect: r))
		}

		if let next = actualView.nextKeyView {
			let alreadyVisited = seenViews + [actualView]
			let nextOnes = self.nextFocusFor(next, seenViews: alreadyVisited)
			result.append(contentsOf: nextOnes)
		}

		return result
	}
}

private extension AppKitFocusOverlay {
	func attachResizeHandler(window: NSWindow, startingAt view: NSView) {
		self.resizeObserver = NotificationCenter.default.addObserver(
			forName: NSWindow.didResizeNotification,
			object: window,
			queue: nil
		) { [weak self, weak window, weak view] notification in
			if let w = window, let v = view {
				self?._present(window: w, startingAt: v)
			}
		}
	}

	func detachResizeHandler() {
		if let r = resizeObserver {
			NotificationCenter.default.removeObserver(r)
			self.resizeObserver = nil
		}
	}
}

// MARK: - Focus Overlay View

internal class FocusOverlayView: NSView {
	override var acceptsFirstResponder: Bool { false }
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool { false }

	fileprivate var currentChain: [AppKitFocusOverlay.ViewRepresent] = [] {
		didSet {
			self.needsDisplay = true
		}
	}

	override func draw(_ dirtyRect: NSRect) {
		guard let ctx = NSGraphicsContext.current?.cgContext else { return }

		var previous: AppKitFocusOverlay.ViewRepresent?

		self.currentChain.reversed().forEach { viewElement in

			guard let thisView = viewElement.view else { return }

			let cpos: AppKitFocusOverlay.Which = {
				if thisView is NSControl { return .center }
				return .top
			}()

			let ep: CGPoint = {
				switch cpos {
				case .top: return CGPoint(x: viewElement.rect.midX, y: viewElement.rect.maxY - 16)
				default: return CGPoint(x: viewElement.rect.midX, y: viewElement.rect.midY)
				}
			}()

			ctx.usingGState { context in
				let cir = CGPath(ellipseIn: CGRect(x: ep.x - 8, y: ep.y - 8, width: 16, height: 16),
									  transform: nil)

				let targetColor: CGColor = {
					NSColor.systemRed.cgColor
					//					if let currentlyFocussed = thisView.window?.firstResponder,
					//						let fieldEditor = currentlyFocussed as? NSText,
					//						fieldEditor.isFieldEditor,
					//						let orig = fieldEditor.delegate as? NSTextField,
					//						orig === thisView
					//					{
					//						return NSColor.systemYellow.cgColor
					//					}
					//					else if thisView.window?.firstResponder === thisView {
					//						return NSColor.systemYellow.cgColor
					//					}
					//					else {
					//						return NSColor.systemRed.cgColor
					//					}
				}()

				context.setFillColor(targetColor)
				context.addPath(cir)
				context.fillPath()

				context.setStrokeColor(.black)
				context.setLineWidth(1)
				context.addPath(cir)
				context.strokePath()
			}

			if let l = previous, l.isValid {
				let lpos: AppKitFocusOverlay.Which = {
					if l.view is NSControl { return .center }
					return .top
				}()

				let sp: CGPoint = {
					switch lpos {
					case .top: return CGPoint(x: l.rect.midX, y: l.rect.maxY - 16)
					default: return CGPoint(x: l.rect.midX, y: l.rect.midY)
					}
				}()

				// Arrow

				let pth = CGPath.arrow(from: ep, to: sp, tailWidth: 4, headWidth: 12, headLength: 16)

				ctx.usingGState { context in
					context.setShadow(
						offset: CGSize(width: 0, height: 0),
						blur: 4,
						color: NSColor.keyboardFocusIndicatorColor.cgColor
					)
					context.addPath(pth)
					context.setFillColor(NSColor.textColor.cgColor)
					context.fillPath()
				}

				ctx.usingGState { context in
					context.addPath(pth)
					context.setStrokeColor(NSColor.textBackgroundColor.cgColor)
					context.setLineWidth(2)
					context.setLineJoin(.bevel)
					context.strokePath()
				}
			}
			previous = viewElement
		}
	}
}
