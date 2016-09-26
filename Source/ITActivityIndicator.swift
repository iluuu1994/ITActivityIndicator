//
//  MIT License
//
//  Copyright (c) 2016 Ilija Tovilo
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

/// ITActivityIndicator is a very simple alternative to UIActivityIndicatorView
@IBDesignable public class ITActivityIndicator: UIView {

    // MARK: API

    /// Specifies the color of the indicator
    @IBInspectable public var color: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.38) { didSet { refreshTicks() }}

    /// The speed of the animation in seconds
    @IBInspectable public var speed: Double = 1.0 { didSet { refreshTicks() }}

    /// Specifies how many ticks the indicator draws
    @IBInspectable public var numberOfTicks: Int = 12 { didSet { refreshTicks() }}

    /// Specifies the width of the ticks
    @IBInspectable public var tickWidth: CGFloat = 2 { didSet { refreshTicks() }}

    /// Specifies the height of the ticks (0.0 - 1.0)
    @IBInspectable public var tickHeight: CGFloat = 0.5 { didSet { refreshTicks() }}


    // MARK: Private

    /// Re-load the view when it is resized
    override public var frame: CGRect { didSet { refreshTicks() }}

    /// Holds onto the tick layers
    private var tickLayers: [CALayer] = []


    // MARK: Drawing

    func refreshTicks() {
        refreshTickLayers()
        addTickAnimation()
    }

    func clearTickLayers() {
        for tickLayer in tickLayers {
            tickLayer.removeFromSuperlayer()
        }

        tickLayers = []
    }

    func refreshTickLayers() {
        clearTickLayers()

        for i in 0..<numberOfTicks {

            // Create a layer for the tick
            let tick = CALayer()
            tick.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            tick.frame = bounds.centerSquare
            layer.addSublayer(tick)
            tickLayers.append(tick)

            // Rotate the tick (2pi * i / max)
            let rotation = CGFloat.pi * 2.0 * CGFloat(i) / CGFloat(numberOfTicks)
            tick.transform = CATransform3DRotate(CATransform3DIdentity, rotation, 0, 0, 1)

            // Create separate layer for drawing
            let colorLayer = CALayer()
            colorLayer.backgroundColor = color.cgColor
            colorLayer.cornerRadius = tickWidth / 2.0
            colorLayer.frame = CGRect(
                x: tick.bounds.midX - tickWidth / 2.0,
                y: 0,
                width: tickWidth,
                height: tick.bounds.midY * tickHeight)

            tick.addSublayer(colorLayer)
        }
    }

    func addTickAnimation() {
        CATransaction.begin()

        for (i, tickLayer) in tickLayers.reversed().enumerated() {

            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = NSNumber(floatLiteral: 1.0)
            fade.toValue = NSNumber(floatLiteral: 0.0)
            fade.repeatCount = Float.infinity
            fade.duration = speed
            fade.timeOffset = speed / CFTimeInterval(tickLayers.count) * CFTimeInterval(i)

            tickLayer.add(fade, forKey: "fadeAnimation")
        }

        CATransaction.commit()
    }
}


// MARK: Geometry helper

private extension CGRect {
    var centerSquare: CGRect {
        let side = min(width, height)

        return CGRect(
            x: midX - side / 2.0,
            y: midY - side / 2.0,
            width: side,
            height: side)
    }
}
