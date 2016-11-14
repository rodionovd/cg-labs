//
//  FractalView.swift
//  Fractals
//
//  Created by Dmitry Rodionov on 07/11/2016.
//  Copyright © 2016 Internals Exposed. All rights reserved.
//

import Cocoa

class FractalView: NSView {
    var fractal: Fractal? = nil {
        didSet {
            needsDisplay = true
        }
    }

    private var _origin: CGPoint? = nil
    var origin: CGPoint {
        get {
            return _origin ?? CGPoint(x: NSMidX(self.bounds), y: NSMidY(self.bounds))
        }
        set {
            _origin = newValue
        }
    }

    override init(frame frameRect: NSRect)
    {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool
    {
        return true
    }

    override func mouseDragged(with event: NSEvent)
    {
        let scaleFactor = convert(NSSize(width: 1.0, height: 1.0), to: nil)
        origin = CGPoint(x: origin.x + (event.deltaX / scaleFactor.width),
                         y: origin.y - (event.deltaY / scaleFactor.height))
        super.mouseDragged(with: event)
        needsDisplay = true
    }

    override func magnify(with event: NSEvent)
    {
        scaleUnitSquare(to: NSSize(width: event.magnification + 1.0, height: event.magnification + 1.0))
        needsDisplay = true
    }

    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
        guard let f = fractal, f.source.characters.count > 0 else {
            return
        }
        //
        let context = NSGraphicsContext.current()!.cgContext
        context.setLineWidth(1.0)
        context.setStrokeColor(.init(red: 0, green: 0, blue: 1, alpha: 1))
        context.setFillColor(.clear)
        let path = CGMutablePath()
        // 
        var point = origin
        path.move(to: point)
        var angle = CGFloat(90.0)
        struct State {
            let angle: CGFloat
            let point: CGPoint
        }
        var states: [State] = []
        // 
        for (_, c) in f.source.lowercased().characters.enumerated() {
            switch c {
            case "b":
                point = targetPoint(forStep: f.step, angle: angle, from: point)
                path.move(to: point)
            case "f":
                point = targetPoint(forStep: f.step, angle: angle, from: point)
                path.addLine(to: point)
            case "+":
                angle += f.angle
            case "-":
                angle -= f.angle
            case "[":
                states.append(State(angle: angle, point: point))
            case "]":
                let saved = states.popLast()!
                angle = saved.angle
                point = saved.point
                path.move(to: point)
            default:
                break;
            }
        }
        path.closeSubpath()
        context.addPath(path)
        context.drawPath(using: .fillStroke)
    }

    private func targetPoint(forStep step: CGFloat, angle: CGFloat, from: CGPoint) -> CGPoint
    {
        let newX = (from.x + step * CGFloat(sin(CGFloat(M_PI / 180) * angle)))
        let newY = (from.y + step * CGFloat(cos(CGFloat(M_PI / 180) * angle)))
        return CGPoint(x: newX, y: newY)
    }
}
