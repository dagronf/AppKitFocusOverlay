//
//  Copyright © 2024 Darren Ford. All rights reserved.
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

@objc public class AppKitFocusOverlay: NSObject {
	/// Create an instance of the focus overlay using the default options
	@objc override public init() {
		self.hotKeyWindow = HotKey(key: .leftBracket, modifiers: [.command, .option])
		self.hotKeyView = HotKey(key: .rightBracket, modifiers: [.command, .option])
		self.shouldRecalculateKeyViewLoop = true
		super.init()
		self.setupHotKeys()
	}

	/// Create an instance of the focus overlay
	/// - Parameters:
	///   - windowHotKey: The hotkey to use for displaying the focus path for the window
	///   - viewHotKey: The hotkey to use for displaying the focus path from the currently focussed UI element.
	///   - shouldRecalculateKeyViewLoop: If true, recalculates the window's key view loop before displaying the overlay
	public init(
		windowHotKey: HotKey,
		viewHotKey: HotKey,
		shouldRecalculateKeyViewLoop: Bool = true
	) {
		self.hotKeyWindow = windowHotKey
		self.hotKeyView = viewHotKey
		self.shouldRecalculateKeyViewLoop = shouldRecalculateKeyViewLoop
		super.init()
		self.setupHotKeys()
	}

	/// Create an instance of the focus overlay
	/// - Parameters:
	///   - shouldRecalculateKeyViewLoop: If true, recalculates the window's key view loop before displaying the overlay
	///
	/// If you perform your own custom key loop handling, you need to set this to false.
	///
	/// This is primarily a convenience for objective-c support, as the HotKey library is not exposed to objective-c.
	/// If you need to customize the hotkeys for objective-c you'll need to fork this library and change the code.
	@objc public init(shouldRecalculateKeyViewLoop: Bool) {
		self.hotKeyWindow = HotKey(key: .leftBracket, modifiers: [.command, .option])
		self.hotKeyView = HotKey(key: .rightBracket, modifiers: [.command, .option])
		self.shouldRecalculateKeyViewLoop = shouldRecalculateKeyViewLoop
		super.init()
		self.setupHotKeys()
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
			self.overlayWindow.setIsVisible(false)
		}
		didSet {
			if let w = _lastAttachedWindow {
				self.overlayWindow.setIsVisible(true)
				w.addChildWindow(self.overlayWindow, ordered: .above)
				self.overlayWindow.level = .normal
			}
		}
	}
}

public extension AppKitFocusOverlay {
	/// Present the focus overlay starting at the specified view
	@objc func present(startingAt view: NSView) {
		guard let window = view.window else { return }
		_present(window: window, startingAt: view)
	}

	/// Present the focus overlay for the current window. if a responder is specified, start from this specific ui element
	@objc func present(_ window: NSWindow, _ responder: NSResponder? = nil) {
		guard let startingView = (responder ?? window.initialFirstResponder) as? NSView else { return }
		_present(window: window, startingAt: startingView)
	}

	/// Hide the focus overlay
	@objc func clear() {
		self._lastAttachedWindow = nil
		detachResizeHandler()
		self.overlayView.currentChain = []
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

		if self.shouldRecalculateKeyViewLoop {
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

		// Swift.print("window - \(self.overlayWindow), \(self.overlayWindow.frame)")
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

		if let next = actualView.nextValidKeyView {
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
		guard
			let ctx = NSGraphicsContext.current?.cgContext,
			var previousItem: AppKitFocusOverlay.ViewRepresent = self.currentChain.first
		else {
			// No items to draw
			return
		}

		var isFirst = true

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

			// Draw the circle

			let circleTargetPath = CGPath(
				ellipseIn: CGRect(x: ep.x - 8, y: ep.y - 8, width: 16, height: 16),
				transform: nil)

			ctx.usingGState {
				Palette.addDropShadow($0)
				$0.setFillColor(Palette.targetColor)
				$0.addPath(circleTargetPath)
				$0.fillPath()
			}

			ctx.usingGState {
				$0.setStrokeColor(.black)
				$0.setLineWidth(1)
				$0.addPath(circleTargetPath)
				$0.strokePath()
			}

			// If the item is invalid (ie. the view no longer exists) then we'll skip
			// over it

			if previousItem.isValid {
				let lpos: AppKitFocusOverlay.Which = {
					if previousItem.view is NSControl { return .center }
					return .top
				}()

				let sp: CGPoint = {
					switch lpos {
					case .top: return CGPoint(x: previousItem.rect.midX, y: previousItem.rect.maxY - 16)
					default: return CGPoint(x: previousItem.rect.midX, y: previousItem.rect.midY)
					}
				}()

				// Arrow

				let arrowPath = CGPath.arrow(from: ep, to: sp, tailWidth: 4, headWidth: 12, headLength: 16)

				if isFirst {
					// This is the point where the key loop ends and returns to the initial view responder.
					// Draw a lighter arrow to indicate the closing of the loop
					isFirst = false
					ctx.usingGState { context in
						Palette.addDropShadow(context)
						context.addPath(arrowPath)
						context.setFillColor(Palette.secondaryArrowFill)
						context.fillPath()
					}
				}
				else {
					ctx.usingGState { context in
						Palette.addDropShadow(context)
						context.addPath(arrowPath)
						context.setFillColor(Palette.primaryArrowFill)
						context.fillPath()
					}

					ctx.usingGState { context in
						context.addPath(arrowPath)
						context.setStrokeColor(Palette.primaryArrowStroke)
						context.setLineWidth(1.5)
						context.setLineJoin(.bevel)
						context.strokePath()
					}
				}
			}
			previousItem = viewElement
		}
	}
}
