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

import CoreGraphics
import Foundation

extension CGPath {
	@inlinable @inline(__always) static var empty: CGPath {
		return CGMutablePath()
	}
}

extension CGPath {
	static func arrow(from start: CGPoint, to end: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> CGPath {
		let length = hypot(end.x - start.x, end.y - start.y)
		let tailLength = length - headLength
		
		guard length > 0 else { return CGPath.empty }
		
		@inline(__always) func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { return CGPoint(x: x, y: y) }
		let points: [CGPoint] = [
			p(0, tailWidth / 2),
			p(tailLength, tailWidth / 2),
			p(tailLength, headWidth / 2),
			p(length, 0),
			p(tailLength, -headWidth / 2),
			p(tailLength, -tailWidth / 2),
			p(0, -tailWidth / 2),
		]
		
		let cosine = (end.x - start.x) / length
		let sine = (end.y - start.y) / length
		let transform = CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: start.x, ty: start.y)
		
		let path = CGMutablePath()
		path.addLines(between: points, transform: transform)
		path.closeSubpath()
		
		return path
	}
}
