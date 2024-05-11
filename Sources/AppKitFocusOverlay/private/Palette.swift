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

// Drawing parameters
internal class Palette {
	@inlinable @inline(__always) static var targetColor: CGColor {
		return NSColor.systemRed.cgColor
	}
	
	@inlinable @inline(__always) static var primaryArrowFill: CGColor {
		return NSColor.textColor.cgColor
	}
	
	@inlinable @inline(__always) static var primaryArrowStroke: CGColor {
		return NSColor.textBackgroundColor.cgColor
	}
	
	@inlinable @inline(__always) static var secondaryArrowFill: CGColor {
		return NSColor.secondaryLabelColor.withAlphaComponent(0.2).cgColor
	}
	
	@inlinable @inline(__always) static var arrowShadow: CGColor {
		return NSColor.keyboardFocusIndicatorColor.cgColor
	}
	
	@inlinable @inline(__always) static func addDropShadow(_ ctx: CGContext) {
		ctx.setShadow(
			offset: CGSize(width: 0, height: 0),
			blur: 4,
			color: self.primaryArrowStroke
		)
	}
}
