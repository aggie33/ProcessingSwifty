//
//  Shapes.swift
//  ProcessingJS-Swift
//
//  Created by Eric Bodnick on 4/12/23.
//

import Foundation
import SwiftUI

public struct GameValues {
    var fillColor: Color = .white
    var strokeColor: Color = .black
    
    var noFill = false
    var noStroke = false
    
    var textDesign: Font.Design = .default
    var textSize: Double = 12.0
    
    var rectMode: RectMode = .standard
    var ellipseMode: EllipseMode = .standard
    var imageMode: ImageMode = .standard
    
    var curveTightness = 0.0
    
    var strokeWeight = 1.0
    var strokeCap: StrokeCap = .round
    var strokeJoin: CGLineJoin = .miter
    
    var vertices: [Vertex] = []
    var beginShapeMode: BeginShapeMode? = nil
    var shapeType: ShapeType = .regular
    
    var colorMode: ColorMode = .rgb
    var textAlignment: Alignment = .leadingFirstTextBaseline
    
    @Modifiable var matrices: [CGAffineTransform] = []
    
    @Binding var frameRate: Double
}

public struct CanvasValues {
    public let frameTime: Double
    public let mouseX: Double
    public let mouseY: Double
    
    public let pmouseX: Double
    public let pmouseY: Double
    
    public let width: Double
    public let height: Double
    
    public let mouseIsPressed: Bool
    public let mouseButton: CGMouseButton?
    
    public let key: UInt16?
    public let keyText: String?
    public let specialKey: NSEvent.SpecialKey?
    public let keyIsPressed: Bool
}

func stroke(path: Path, context: inout GraphicsContext, size: CGSize, values: GameValues) {
    if !values.noStroke { context.stroke(path, with: .color(values.strokeColor), style: StrokeStyle(lineWidth: values.strokeWeight, lineCap: CGLineCap(values.strokeCap), lineJoin: values.strokeJoin))}
}
func fill(path: Path, context: inout GraphicsContext, size: CGSize, values: GameValues) {
    if !values.noFill { context.fill(path, with: .color(values.fillColor)) }
}
func draw(path: Path, context: inout GraphicsContext, size: CGSize, values: GameValues) {
    fill(path: path, context: &context, size: size, values: values)
    stroke(path: path, context: &context, size: size, values: values)
}

public enum ImageMode {
    case center
    case corner
    case corners
    
    static var standard: Self = .corner
}
public enum RectMode {
    case center
    case corner
    case corners
    case radius
    
    static var standard: Self = .corner
}
public enum EllipseMode {
    case center
    case corner
    case corners
    case radius
    
    static var standard: Self = .center
}
public enum StrokeCap: Int32 {
    case round
    case square
    case project
}

extension CGLineCap {
    init(_ cap: StrokeCap) {
        switch cap {
        case .round:
            self = .round
        case .square:
            self = .butt
        case .project:
            self = .square
        }
    }
}

public func rect(x: CanvasValue, y: CanvasValue, width: CanvasValue, height: CanvasValue, cornerRadius: Double = 0.0) -> Instruction {
    .draw { context, size, values in
        let rect = CGRect(
            x: x.resolve(for: size.width),
            y: y.resolve(for: size.height),
            width: width.resolve(for: size.width),
            height: height.resolve(for: size.height)
        )
        
        let path = Path(roundedRect: rect, cornerRadius: cornerRadius)
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func rect(x: CanvasValue, y: CanvasValue, oppositeX: CanvasValue, oppositeY: CanvasValue, cornerRadius: Double = 0.0) -> Instruction {
    .draw { context, size, values in
        let x = x.resolve(for: size.width)
        let y = y.resolve(for: size.height)
        let oppositeX = oppositeX.resolve(for: size.width)
        let oppositeY = oppositeY.resolve(for: size.height)
        
        let rect = CGRect(
            x: x,
            y: y,
            width: oppositeX - x,
            height: oppositeY - y
        )
        
        let path = Path(roundedRect: rect, cornerRadius: cornerRadius)
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func rect(centerX: CanvasValue, centerY: CanvasValue, width: CanvasValue, height: CanvasValue, cornerRadius: Double = 0.0) -> Instruction {
    .draw { context, size, values in
        let centerX = centerX.resolve(for: size.width)
        let centerY = centerY.resolve(for: size.height)
        let width = width.resolve(for: size.width)
        let height = height.resolve(for: size.height)
        
        let rect = CGRect(
            x: centerX - width / 2,
            y: centerY - height / 2,
            width: width,
            height: height
        )
        
        let path = Path(roundedRect: rect, cornerRadius: cornerRadius)
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func rect(centerX: CanvasValue, centerY: CanvasValue, xRadius: CanvasValue, yRadius: CanvasValue, cornerRadius: Double = 0.0) -> Instruction {
    .draw { context, size, values in
        let centerX = centerX.resolve(for: size.width)
        let centerY = centerY.resolve(for: size.height)
        let width = xRadius.resolve(for: size.width) * 2
        let height = yRadius.resolve(for: size.height) * 2
        
        let rect = CGRect(
            x: centerX - width / 2,
            y: centerY - height / 2,
            width: width,
            height: height
        )
        
        let path = Path(roundedRect: rect, cornerRadius: cornerRadius)
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func rect(origin: CanvasPoint, size: CanvasSize, cornerRadius: Double = 0.0) -> Instruction {
    rect(x: origin.x, y: origin.y, width: size.width, height: size.height, cornerRadius: cornerRadius)
}
public func rect(origin: CanvasPoint, opposite: CanvasPoint, cornerRadius: Double = 0.0) -> Instruction {
    rect(x: origin.x, y: origin.y, oppositeX: opposite.x, oppositeY: opposite.y)
}
public func rect(center: CanvasPoint, size: CanvasSize, cornerRadius: Double = 0.0) -> Instruction {
    rect(centerX: center.x, centerY: center.y, width: size.width, height: size.height, cornerRadius: cornerRadius)
}
public func rect(_ p1: CanvasValue, _ p2: CanvasValue, _ p3: CanvasValue, _ p4: CanvasValue, _ cornerRadius: Double = 0.0) -> Instruction {
    .draw { context, size, values in
        switch values.rectMode {
        case .corner:
            rect(x: p1, y: p2, width: p3, height: p4, cornerRadius: cornerRadius).draw(context: &context, size: size, values: values)
        case .radius:
            rect(centerX: p1, centerY: p2, xRadius: p3, yRadius: p4, cornerRadius: cornerRadius).draw(context: &context, size: size, values: values)
        case .corners:
            rect(x: p1, y: p2, oppositeX: p3, oppositeY: p4, cornerRadius: cornerRadius).draw(context: &context, size: size, values: values)
        case .center:
            rect(centerX: p1, centerY: p2, width: p3, height: p4, cornerRadius: cornerRadius).draw(context: &context, size: size, values: values)
        }
    }
}
@_disfavoredOverload public func rect(_ p1: Double, _ p2: Double, _ p3: Double, _ p4: Double, _ cornerRadius: Double = 0.0) -> Instruction {
    rect(.absolute(p1), .absolute(p2), .absolute(p3), .absolute(p4), cornerRadius)
}
public func rectMode(_ mode: RectMode) -> Instruction {
    .action { $0.rectMode = mode }
}

public func ellipse(x: CanvasValue, y: CanvasValue, width: CanvasValue, height: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let rect = CGRect(
            x: x.resolve(for: size.width),
            y: y.resolve(for: size.height),
            width: width.resolve(for: size.width),
            height: height.resolve(for: size.height)
        )
        
        let path = Path(ellipseIn: rect)
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func ellipse(x: CanvasValue, y: CanvasValue, oppositeX: CanvasValue, oppositeY: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let x = x.resolve(for: size.width)
        let y = y.resolve(for: size.height)
        let oppositeX = oppositeX.resolve(for: size.width)
        let oppositeY = oppositeY.resolve(for: size.height)
        
        let rect = CGRect(
            x: x,
            y: y,
            width: oppositeX - x,
            height: oppositeY - y
        )
        
        let path = Path(ellipseIn: rect)
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func ellipse(centerX: CanvasValue, centerY: CanvasValue, width: CanvasValue, height: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let centerX = centerX.resolve(for: size.width)
        let centerY = centerY.resolve(for: size.height)
        let width = width.resolve(for: size.width)
        let height = height.resolve(for: size.height)
        
        let rect = CGRect(
            x: centerX - width / 2,
            y: centerY - height / 2,
            width: width,
            height: height
        )
        
        let path = Path(ellipseIn: rect)
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func ellipse(centerX: CanvasValue, centerY: CanvasValue, xRadius: CanvasValue, yRadius: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let centerX = centerX.resolve(for: size.width)
        let centerY = centerY.resolve(for: size.height)
        let width = xRadius.resolve(for: size.width) * 2
        let height = yRadius.resolve(for: size.height) * 2
        
        let rect = CGRect(
            x: centerX - width / 2,
            y: centerY - height / 2,
            width: width,
            height: height
        )
        
        let path = Path(ellipseIn: rect)
        draw(path: path, context: &context, size: size, values: values)
    }
}
/// Note that if `radius` is a `.relative(_)` value, the ellipse may not be a perfect circle, since the width is relative to the width of the screen and the height is relative to the height of the screen.
public func ellipse(centerX: CanvasValue, centerY: CanvasValue, radius: CanvasValue) -> Instruction {
    ellipse(centerX: centerX, centerY: centerY, xRadius: radius, yRadius: radius)
}
public func ellipse(origin: CanvasPoint, size: CanvasSize) -> Instruction { ellipse(x: origin.x, y: origin.y, width: size.width, height: size.height)}
public func ellipse(origin: CanvasPoint, opposite: CanvasPoint) -> Instruction { ellipse(x: origin.x, y: origin.y, oppositeX: opposite.x, oppositeY: opposite.y)}
public func ellipse(center: CanvasPoint, size: CanvasSize) -> Instruction { ellipse(centerX: center.x, centerY: center.y, width: size.width, height: size.height)}
public func ellipse(_ p1: CanvasValue, _ p2: CanvasValue, _ p3: CanvasValue, _ p4: CanvasValue) -> Instruction {
    .draw { context, size, values in
        switch values.ellipseMode {
        case .corner:
            ellipse(x: p1, y: p2, width: p3, height: p4).draw(context: &context, size: size, values: values)
        case .radius:
            ellipse(centerX: p1, centerY: p2, xRadius: p3, yRadius: p4).draw(context: &context, size: size, values: values)
        case .corners:
            ellipse(x: p1, y: p2, oppositeX: p3, oppositeY: p4).draw(context: &context, size: size, values: values)
        case .center:
            ellipse(centerX: p1, centerY: p2, width: p3, height: p4).draw(context: &context, size: size, values: values)
        }
    }
}
@_disfavoredOverload public func ellipse(_ p1: Double, _ p2: Double, _ p3: Double, _ p4: Double) -> Instruction {
    ellipse(.absolute(p1), .absolute(p2), .absolute(p3), .absolute(p4))
}
public func ellipseMode(_ mode: EllipseMode) -> Instruction {
    .action { $0.ellipseMode = mode }
}

@_disfavoredOverload public func triangle(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ x3: Double, _ y3: Double) -> Instruction {
    triangle(.absolute(x1), .absolute(y1), .absolute(x2), .absolute(y2), .absolute(x3), .absolute(y3))
}
public func triangle(_ x1: CanvasValue, _ y1: CanvasValue, _ x2: CanvasValue, _ y2: CanvasValue, _ x3: CanvasValue, _ y3: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            $0.move(to: CGPoint(x: x1.resolve(for: size.width), y: y1.resolve(for: size.height)))
            $0.addLine(to: CGPoint(x: x2.resolve(for: size.width), y: y2.resolve(for: size.height)))
            $0.addLine(to: CGPoint(x: x3.resolve(for: size.width), y: y3.resolve(for: size.height)))
            $0.addLine(to: CGPoint(x: x1.resolve(for: size.width), y: y1.resolve(for: size.height)))
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func triangle(x1: CanvasValue, y1: CanvasValue, x2: CanvasValue, y2: CanvasValue, x3: CanvasValue, y3: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            $0.move(to: CGPoint(x: x1.resolve(for: size.width), y: y1.resolve(for: size.height)))
            $0.addLine(to: CGPoint(x: x2.resolve(for: size.width), y: y2.resolve(for: size.height)))
            $0.addLine(to: CGPoint(x: x3.resolve(for: size.width), y: y3.resolve(for: size.height)))
            $0.addLine(to: CGPoint(x: x1.resolve(for: size.width), y: y1.resolve(for: size.height)))
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func triangle(p1: CanvasPoint, p2: CanvasPoint, p3: CanvasPoint) -> Instruction {
    triangle(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y, x3: p3.x, y3: p3.y)
}

@_disfavoredOverload public func line(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) -> Instruction {
    line(.absolute(x1), .absolute(y1), .absolute(x2), .absolute(y2))
}
public func line(x1: CanvasValue, y1: CanvasValue, x2: CanvasValue, y2: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            $0.move(to: CGPoint(x: x1.resolve(for: size.width), y: y1.resolve(for: size.height)))
            $0.addLine(to: CGPoint(x: x2.resolve(for: size.width), y: y2.resolve(for: size.height)))
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func line(_ x1: CanvasValue, _ y1: CanvasValue, _ x2: CanvasValue, _ y2: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            $0.move(to: CGPoint(x: x1.resolve(for: size.width), y: y1.resolve(for: size.height)))
            $0.addLine(to: CGPoint(x: x2.resolve(for: size.width), y: y2.resolve(for: size.height)))
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func line(p1: CanvasPoint, p2: CanvasPoint) -> Instruction { line(p1.x, p1.y, p2.x, p2.y) }

public func strokeCap(_ cap: StrokeCap) -> Instruction {
    .action { $0.strokeCap = cap }
}

@_disfavoredOverload public func point(_ x: Double, _ y: Double) -> Instruction {
    point(x: .absolute(x), y: .absolute(y))
}
public func point(_ x: CanvasValue, _ y: CanvasValue) -> Instruction {
    point(x: x, y: y)
}
public func point(x: CanvasValue, y: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            if values.strokeWeight > 1 {
                $0.addEllipse(in: CGRect(center: CGPoint(x: x.resolve(for: size.width), y: y.resolve(for: size.height)), size: CGSize(width: values.strokeWeight, height: values.strokeWeight)))
            } else {
                $0.addRect(CGRect(origin: CGPoint(x: x.resolve(for: size.width), y: y.resolve(for: size.height)), size: CGSize(width: values.strokeWeight, height: values.strokeWeight)))
            }
        }
        
        context.fill(path, with: .color(values.strokeColor))
    }
}
public func point(_ p: CanvasPoint) -> Instruction {
    point(x: p.x, y: p.y)
}

public func arc(centerX: CanvasValue, centerY: CanvasValue, width: CanvasValue, height: CanvasValue, from start: Angle, to stop: Angle) -> Instruction {
    .draw { context, size, values in
        let centerX = centerX.resolve(for: size.width)
        let centerY = centerY.resolve(for: size.height)
        let width = width.resolve(for: size.width)
        let height = height.resolve(for: size.height)
        
        let verticalScaleFactor = height / width
        
        let strokePath = Path {
            $0.addArc(center: CGPoint(x: 0, y: 0), radius: width / 2, startAngle: start, endAngle: stop, clockwise: false)
        }//.applying(.init(scaleX: 1, y: verticalScaleFactor).translatedBy(x: 0, y: -((centerY * verticalScaleFactor) - centerY)))
        
        let fillPath = Path {
            $0.addArc(center: CGPoint(x: 0, y: 0), radius: width / 2, startAngle: start, endAngle: stop, clockwise: false)
            $0.addLine(to: CGPoint(x: 0, y: 0))
            $0.closeSubpath()
        }//.applying(.init(scaleX: 1, y: verticalScaleFactor).translatedBy(x: 0, y: -((centerY * verticalScaleFactor) - centerY)))
        
        let matrix = context.transform
        
        context.translateBy(x: centerX, y: centerY)
        //context.scaleBy(x: 1, y: verticalScaleFactor)
        fill(path: fillPath, context: &context, size: size, values: values)
        stroke(path: strokePath, context: &context, size: size, values: values)
        
        context.transform = matrix
    }
}
public func arc(center: CanvasPoint, size: CanvasSize, from startAngle: Angle, to endAngle: Angle) -> Instruction {
    arc(centerX: center.x, centerY: center.y, width: size.width, height: size.height, from: startAngle, to: endAngle)
}
public func arc(x: CanvasValue, y: CanvasValue, width: CanvasValue, height: CanvasValue, from start: Angle, to stop: Angle) -> Instruction {
    .draw { context, size, values in
        let width = width.resolve(for: size.width)
        let height = height.resolve(for: size.height)
        let centerX = x.resolve(for: size.width) + width / 2
        let centerY = y.resolve(for: size.height) + height / 2
        
        let verticalScaleFactor = height / width
        
        let strokePath = Path {
            $0.addArc(center: CGPoint(x: centerX, y: centerY), radius: width / 2, startAngle: start, endAngle: stop, clockwise: false)
        }.applying(.init(scaleX: 1, y: verticalScaleFactor).translatedBy(x: 0, y: -((centerY * verticalScaleFactor) - centerY)))
        
        let fillPath = Path {
            $0.addArc(center: CGPoint(x: centerX, y: centerY), radius: width / 2, startAngle: start, endAngle: stop, clockwise: false)
            $0.addLine(to: CGPoint(x: centerX, y: centerY))
            $0.closeSubpath()
        }.applying(.init(scaleX: 1, y: verticalScaleFactor).translatedBy(x: 0, y: -((centerY * verticalScaleFactor) - centerY)))
        
        fill(path: fillPath, context: &context, size: size, values: values)
        stroke(path: strokePath, context: &context, size: size, values: values)
    }
}
public func arc(origin: CanvasPoint, size: CanvasSize, from startAngle: Angle, to endAngle: Angle) -> Instruction {
    arc(x: origin.x, y: origin.y, width: size.width, height: size.height, from: startAngle, to: endAngle)
}
public func arc(x: CanvasValue, y: CanvasValue, oppositeX: CanvasValue, oppositeY: CanvasValue, from start: Angle, to stop: Angle) -> Instruction {
    .draw { context, size, values in
        let x = x.resolve(for: size.width)
        let y = y.resolve(for: size.height)
        let opX = oppositeX.resolve(for: size.width)
        let opY = oppositeY.resolve(for: size.height)
        
        let width = opX - x
        let height = opY - y
        let centerX = x + width / 2
        let centerY = y + height / 2
        
        let verticalScaleFactor = height / width
        
        let strokePath = Path {
            $0.addArc(center: CGPoint(x: centerX, y: centerY), radius: width / 2, startAngle: start, endAngle: stop, clockwise: false)
        }.applying(.init(scaleX: 1, y: verticalScaleFactor).translatedBy(x: 0, y: -((centerY * verticalScaleFactor) - centerY)))
        
        let fillPath = Path {
            $0.addArc(center: CGPoint(x: centerX, y: centerY), radius: width / 2, startAngle: start, endAngle: stop, clockwise: false)
            $0.addLine(to: CGPoint(x: centerX, y: centerY))
            $0.closeSubpath()
        }.applying(.init(scaleX: 1, y: verticalScaleFactor).translatedBy(x: 0, y: -((centerY * verticalScaleFactor) - centerY)))
        
        fill(path: fillPath, context: &context, size: size, values: values)
        stroke(path: strokePath, context: &context, size: size, values: values)
    }
}
public func arc(origin: CanvasPoint, opposite: CanvasPoint, from startAngle: Angle, to endAngle: Angle) -> Instruction {
    arc(x: origin.x, y: origin.y, oppositeX: opposite.x, oppositeY: opposite.y, from: startAngle, to: endAngle)
}
public func arc(centerX: CanvasValue, centerY: CanvasValue, xRadius: CanvasValue, yRadius: CanvasValue, from start: Angle, to stop: Angle) -> Instruction {
    .draw { context, size, values in
        let centerX = centerX.resolve(for: size.width)
        let centerY = centerY.resolve(for: size.height)
        let width = xRadius.resolve(for: size.width) * 2
        let height = yRadius.resolve(for: size.height) * 2
        
        let verticalScaleFactor = height / width
        
        let strokePath = Path {
            $0.addArc(center: CGPoint(x: centerX, y: centerY), radius: width / 2, startAngle: start, endAngle: stop, clockwise: false)
        }.applying(.init(scaleX: 1, y: verticalScaleFactor).translatedBy(x: 0, y: -((centerY * verticalScaleFactor) - centerY)))
        
        let fillPath = Path {
            $0.addArc(center: CGPoint(x: centerX, y: centerY), radius: width / 2, startAngle: start, endAngle: stop, clockwise: false)
            $0.addLine(to: CGPoint(x: centerX, y: centerY))
            $0.closeSubpath()
        }.applying(.init(scaleX: 1, y: verticalScaleFactor).translatedBy(x: 0, y: -((centerY * verticalScaleFactor) - centerY)))
        
        fill(path: fillPath, context: &context, size: size, values: values)
        stroke(path: strokePath, context: &context, size: size, values: values)
    }
}
public func arc(centerX: CanvasValue, centerY: CanvasValue, radius: CanvasValue, from start: Angle, to end: Angle) -> Instruction {
    arc(centerX: centerX, centerY: centerY, xRadius: radius, yRadius: radius, from: start, to: end)
}
public func arc(_ p1: CanvasValue, _ p2: CanvasValue, _ p3: CanvasValue, _ p4: CanvasValue, _ start: Angle, _ end: Angle) -> Instruction {
    .draw { context, size, values in
        switch values.ellipseMode {
        case .radius:
            arc(centerX: p1, centerY: p2, xRadius: p3, yRadius: p4, from: start, to: end).draw(context: &context, size: size, values: values)
        case .center:
            arc(centerX: p1, centerY: p2, width: p3, height: p4, from: start, to: end).draw(context: &context, size: size, values: values)
        case .corner:
            arc(x: p1, y: p2, width: p3, height: p4, from: start, to: end).draw(context: &context, size: size, values: values)
        case .corners:
            arc(x: p1, y: p2, oppositeX: p3, oppositeY: p4, from: start, to: end).draw(context: &context, size: size, values: values)
        }
    }
}
@_disfavoredOverload public func arc(_ p1: Double, _ p2: Double, _ p3: Double, _ p4: Double , _ p5: Double, _ p6: Double) -> Instruction {
    arc(.absolute(p1), .absolute(p2), .absolute(p3), .absolute(p4), .degrees(p5), .degrees(p6))
}

public func bezier(x1: CanvasValue, y1: CanvasValue, cx1: CanvasValue, cy1: CanvasValue, cx2: CanvasValue, cy2: CanvasValue, x2: CanvasValue, y2: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            $0.move(to: CGPoint(x: x1.resolve(for: size.width), y: y1.resolve(for: size.height)))
            $0.addCurve(to: CGPoint(x: x2.resolve(for: size.width), y: y2.resolve(for: size.height)),
                        control1: CGPoint(x: cx1.resolve(for: size.width), y: cy1.resolve(for: size.height)),
                        control2: CGPoint(x: cx2.resolve(for: size.width), y: cy2.resolve(for: size.height)))
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func bezier(start: CanvasPoint, control1: CanvasPoint, control2: CanvasPoint, end: CanvasPoint) -> Instruction {
    bezier(x1: start.x, y1: start.y, cx1: control1.x, cy1: control1.y, cx2: control2.x, cy2: control2.y, x2: end.x, y2: end.y)
}
@_disfavoredOverload public func bezier(_ x1: CanvasValue, _ y1: CanvasValue, _ cx1: CanvasValue, _ cy1: CanvasValue, _ cx2: CanvasValue, _ cy2: CanvasValue, _ x2: CanvasValue, _ y2: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            $0.move(to: CGPoint(x: x1.resolve(for: size.width), y: y1.resolve(for: size.height)))
            $0.addCurve(to: CGPoint(x: x2.resolve(for: size.width), y: y2.resolve(for: size.height)),
                        control1: CGPoint(x: cx1.resolve(for: size.width), y: cy1.resolve(for: size.height)),
                        control2: CGPoint(x: cx2.resolve(for: size.width), y: cy2.resolve(for: size.height)))
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func bezier(_ x1: Double, _ y1: Double, _ cx1: Double, _ cy1: Double, _ cx2: Double, _ cy2: Double, _ x2: Double, _ y2: Double) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            $0.move(to: CGPoint(x: x1, y: y1))
            $0.addCurve(to: CGPoint(x: x2, y: y2),
                        control1: CGPoint(x: cx1, y: cy1),
                        control2: CGPoint(x: cx2, y: cy2))
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}

public func quad(x1: CanvasValue, y1: CanvasValue, x2: CanvasValue, y2: CanvasValue, x3: CanvasValue, y3: CanvasValue, x4: CanvasValue, y4: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            let p1 = CGPoint(x: x1.resolve(for: size.width), y: y1.resolve(for: size.width))
            let p2 = CGPoint(x: x2.resolve(for: size.width), y: y2.resolve(for: size.width))
            let p3 = CGPoint(x: x3.resolve(for: size.width), y: y3.resolve(for: size.width))
            let p4 = CGPoint(x: x4.resolve(for: size.width), y: y4.resolve(for: size.width))
            
            $0.move(to: p1)
            $0.addLine(to: p2)
            $0.addLine(to: p3)
            $0.addLine(to: p4)
            $0.closeSubpath()
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}
@_disfavoredOverload public func quad(_ x1: CanvasValue, _ y1: CanvasValue, _ x2: CanvasValue, _ y2: CanvasValue, _ x3: CanvasValue, _ y3: CanvasValue, _ x4: CanvasValue, _ y4: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            let p1 = CGPoint(x: x1.resolve(for: size.width), y: y1.resolve(for: size.width))
            let p2 = CGPoint(x: x2.resolve(for: size.width), y: y2.resolve(for: size.width))
            let p3 = CGPoint(x: x3.resolve(for: size.width), y: y3.resolve(for: size.width))
            let p4 = CGPoint(x: x4.resolve(for: size.width), y: y4.resolve(for: size.width))
            
            $0.move(to: p1)
            $0.addLine(to: p2)
            $0.addLine(to: p3)
            $0.addLine(to: p4)
            $0.closeSubpath()
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func quad(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double, _ x3: Double, _ y3: Double, _ x4: Double, _ y4: Double) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            let p1 = CGPoint(x: x1, y: y1)
            let p2 = CGPoint(x: x2, y: y2)
            let p3 = CGPoint(x: x3, y: y3)
            let p4 = CGPoint(x: x4, y: y4)
            
            $0.move(to: p1)
            $0.addLine(to: p2)
            $0.addLine(to: p3)
            $0.addLine(to: p4)
            $0.closeSubpath()
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func quad(x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double, x4: Double, y4: Double) -> Instruction {
    .draw { context, size, values in
        let path = Path {
            let p1 = CGPoint(x: x1, y: y1)
            let p2 = CGPoint(x: x2, y: y2)
            let p3 = CGPoint(x: x3, y: y3)
            let p4 = CGPoint(x: x4, y: y4)
            
            $0.move(to: p1)
            $0.addLine(to: p2)
            $0.addLine(to: p3)
            $0.addLine(to: p4)
            $0.closeSubpath()
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func quad(p1: CanvasPoint, p2: CanvasPoint, p3: CanvasPoint, p4: CanvasPoint) -> Instruction {
    quad(x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y, x3: p3.x, y3: p3.y, x4: p4.x, y4: p4.y)
}

public func getImage(_ name: String) -> Image { Image(name) }
public func image(_ image: Image, x: CanvasValue, y: CanvasValue, width: CanvasValue? = nil, height: CanvasValue? = nil) -> Instruction {
    .draw { context, size, values in
        if width == nil && height == nil {
            context.draw(image, at: CGPoint(x: x.resolve(for: size.width), y: y.resolve(for: size.height)), anchor : .topLeading)
        } else {
            let resolvedImage = context.resolve(image)
            context.draw(image,
                in: CGRect(
                    x: x.resolve(for: size.width),
                    y: y.resolve(for: size.height),
                    width: width?.resolve(for: size.width) ?? resolvedImage.size.width,
                    height: height?.resolve(for: size.height) ?? resolvedImage.size.height
                )
            )
        }
    }
}
public func image(_ image: Image, centerX: CanvasValue, centerY: CanvasValue, width: CanvasValue? = nil, height: CanvasValue? = nil) -> Instruction {
    .draw { context, size, values in
        if width == nil && height == nil {
            context.draw(image, at: CGPoint(x: centerX.resolve(for: size.width), y: centerY.resolve(for: size.height)), anchor : .center)
        } else {
            let resolvedImage = context.resolve(image)
            context.draw(image,
                    in: CGRect(center: CGPoint(
                    x: centerX.resolve(for: size.width),
                    y: centerY.resolve(for: size.height)), size: CGSize(
                    width: width?.resolve(for: size.width) ?? resolvedImage.size.width,
                    height: height?.resolve(for: size.height) ?? resolvedImage.size.height
                ))
            )
        }
    }
}
@_disfavoredOverload public func image(_ image: Image, x: CanvasValue, y: CanvasValue, oppositeX: CanvasValue? = nil, oppositeY: CanvasValue? = nil) -> Instruction {
    .draw { context, size, values in
        if oppositeX == nil && oppositeY == nil {
            context.draw(image, at: CGPoint(x: x.resolve(for: size.width), y: y.resolve(for: size.height)), anchor : .topLeading)
        } else {
            let resolvedImage = context.resolve(image)
            context.draw(image,
                         in: CGRect(origin: CGPoint(
                    x: x.resolve(for: size.width),
                    y: y.resolve(for: size.height)), opposite: CGPoint(
                        x: oppositeX?.resolve(for: size.width) ?? resolvedImage.size.width,
                        y: oppositeY?.resolve(for: size.height) ?? resolvedImage.size.height
                ))
            )
        }
    }
}
public func image(_ imageValue: Image, _ p1: CanvasValue, _ p2: CanvasValue, _ p3: CanvasValue? = nil, _ p4: CanvasValue? = nil) -> Instruction {
    .draw { context, size, values in
        switch values.imageMode {
        case .center:
            image(imageValue, centerX: p1, centerY: p2, width: p3, height: p4).draw(context: &context, size: size, values: values)
        case .corner:
            image(imageValue, x: p1, y: p2, width: p3, height: p4).draw(context: &context, size: size, values: values)
        case .corners:
            image(imageValue, x: p1, y: p2, oppositeX: p3, oppositeY: p4).draw(context: &context, size: size, values: values)
        }
    }
}
@_disfavoredOverload public func image(_ imageValue: Image, _ p1: Double, _ p2: Double, _ p3: Double? = nil, _ p4: Double? = nil) -> Instruction {
    image(imageValue, .absolute(p1), .absolute(p2), p3.map(CanvasValue.absolute), p4.map(CanvasValue.absolute))
}
public func image(_ imageValue: Image, origin: CanvasPoint, size: CanvasSize? = nil) -> Instruction {
    image(imageValue, x: origin.x, y: origin.y, width: size?.width, height: size?.height)
}
public func image(_ imageValue: Image, center: CanvasPoint, size: CanvasSize? = nil) -> Instruction {
    image(imageValue, centerX: center.x, centerY: center.y, width: size?.width, height: size?.height)
}
public func image(_ imageValue: Image, origin: CanvasPoint, opposite: CanvasPoint? = nil) -> Instruction {
    image(imageValue, x: origin.x, y: origin.y, oppositeX: opposite?.x, oppositeY: opposite?.y)
}

extension Image {
    public var width: DelayedValue<Double> {
        DelayedValue { context, size, values in
            let resolvedImage = context.resolve(self)
            return resolvedImage.size.width
        }
    }
    
    public var height: DelayedValue<Double> {
        DelayedValue { context, size, values in
            let resolvedImage = context.resolve(self)
            return resolvedImage.size.height
        }
    }
}

public func imageMode(_ mode: ImageMode) -> Instruction {
    .action { $0.imageMode = mode }
}


/// Calculates the X or Y coordinate of a point on a bezier curve. Plug in the X coordinates for all values to get the X as a result, or Y to get the Y as a result, or use the version that takes a CGPoint.
/// - Parameters:
///   - start: The coordinate of the first point on the curve.
///   - control1: The coordinate of the first control point.
///   - control2: The coordinate of the second control point.
///   - end: The coordinate of the second point.
///   - time: The position on the curve, between 0 and 1.
public func bezierPoint(start: Double, control1: Double, control2: Double, end: Double, time: Double) -> Double {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    return (1 - t) * (1 - t) * (1 - t) * a + 3 * (1 - t) * (1 - t) * t * b + 3 * (1 - t) * t * t * c + t * t * t * d
}
@_disfavoredOverload public func bezierPoint(start: CanvasValue, control1: CanvasValue, control2: CanvasValue, end: CanvasValue, time: Double) -> CanvasValue {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    let stat1 = (a * (1 - t) * (1 - t) * (1 - t))
    let stat2 = (b * 3 * (1 - t) * (1 - t) * t)
    let stat3 = (c * 3 * (1 - t) * t * t)
    let stat4 = (d * t * t * t)
    return stat1 + stat2 + stat3 + stat4
}
@_disfavoredOverload public func bezierPoint(_ start: CanvasValue, _ control1: CanvasValue, _ control2: CanvasValue, _ end: CanvasValue, _ time: Double) -> CanvasValue {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    let stat1 = (a * (1 - t) * (1 - t) * (1 - t))
    let stat2 = (b * 3 * (1 - t) * (1 - t) * t)
    let stat3 = (c * 3 * (1 - t) * t * t)
    let stat4 = (d * t * t * t)
    return stat1 + stat2 + stat3 + stat4
}
public func bezierPoint(_ a: Double, _ b: Double, _ c: Double, _ d: Double, _ t: Double) -> Double {
    bezierPoint(start: a, control1: b, control2: c, end: d, time: t)
}
public func bezierPoint(start: CanvasPoint, control1: CanvasPoint, control2: CanvasPoint, end: CanvasPoint, time: Double) -> CanvasPoint {
    CanvasPoint(x: bezierPoint(start: start.x, control1: control1.x, control2: control2.x, end: end.x, time: time), y: bezierPoint(start: start.y, control1: control1.y, control2: control2.y, end: end.y, time: time))
}
public func bezierPoint(start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint, time: Double) -> CGPoint {
    CGPoint(x: bezierPoint(start: start.x, control1: control1.x, control2: control2.x, end: end.x, time: time), y: bezierPoint(start: start.y, control1: control1.y, control2: control2.y, end: end.y, time: time))
}
public func bezierPoint(x: Double, y: Double, cx1: Double, cy1: Double, cx2: Double, cy2: Double, x2: Double, y2: Double, t: Double) -> CGPoint {
    bezierPoint(start: CGPoint(x: x, y: y), control1: CGPoint(x: cx1, y: cy1), control2: CGPoint(x: cx2, y: cy2), end: CGPoint(x: x2, y: y2), time: t)
}
public func bezierPoint(x: CanvasValue, y: CanvasValue, cx1: CanvasValue, cy1: CanvasValue, cx2: CanvasValue, cy2: CanvasValue, x2: CanvasValue, y2: CanvasValue, t: Double) -> CanvasPoint {
    bezierPoint(start: CanvasPoint(x:x,y:y), control1: CanvasPoint(x:cx1,y:cy1), control2: CanvasPoint(x:cx2,y:cy2), end: CanvasPoint(x:x2,y:y2), time: t)
}

public func bezierTangent(start: Double, control1: Double, control2: Double, end: Double, time: Double) -> Double {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    return (3 * t * t * (-a + 3 * b - 3 * c + d) + 6 * t * (a - 2 * b + c) + 3 * (-a + b));
}
@_disfavoredOverload public func bezierTangent(start: CanvasValue, control1: CanvasValue, control2: CanvasValue, end: CanvasValue, time: Double) -> CanvasValue {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    let stat1 = (a * (1 - t) * (1 - t) * (1 - t))
    let stat2 = (b * 3 * (1 - t) * (1 - t) * t)
    let stat3 = (c * 3 * (1 - t) * t * t)
    let stat4 = (d * t * t * t)
    return stat1 + stat2 + stat3 + stat4
}
@_disfavoredOverload public func bezierTangent(_ start: CanvasValue, _ control1: CanvasValue, _ control2: CanvasValue, _ end: CanvasValue, _ time: Double) -> CanvasValue {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    let stat1 = (a * (1 - t) * (1 - t) * (1 - t))
    let stat2 = (b * 3 * (1 - t) * (1 - t) * t)
    let stat3 = (c * 3 * (1 - t) * t * t)
    let stat4 = (d * t * t * t)
    return stat1 + stat2 + stat3 + stat4
}
public func bezierTangent(_ a: Double, _ b: Double, _ c: Double, _ d: Double, _ t: Double) -> Double {
    bezierTangent(start: a, control1: b, control2: c, end: d, time: t)
}
public func bezierTangent(start: CanvasPoint, control1: CanvasPoint, control2: CanvasPoint, end: CanvasPoint, time: Double) -> CanvasPoint {
    CanvasPoint(x: bezierTangent(start: start.x, control1: control1.x, control2: control2.x, end: end.x, time: time), y: bezierTangent(start: start.y, control1: control1.y, control2: control2.y, end: end.y, time: time))
}
public func bezierTangent(start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint, time: Double) -> CGPoint {
    CGPoint(x: bezierTangent(start: start.x, control1: control1.x, control2: control2.x, end: end.x, time: time), y: bezierTangent(start: start.y, control1: control1.y, control2: control2.y, end: end.y, time: time))
}
public func bezierTangent(x: Double, y: Double, cx1: Double, cy1: Double, cx2: Double, cy2: Double, x2: Double, y2: Double, t: Double) -> CGPoint {
    bezierTangent(start: CGPoint(x: x, y: y), control1: CGPoint(x: cx1, y: cy1), control2: CGPoint(x: cx2, y: cy2), end: CGPoint(x: x2, y: y2), time: t)
}
public func bezierTangent(x: CanvasValue, y: CanvasValue, cx1: CanvasValue, cy1: CanvasValue, cx2: CanvasValue, cy2: CanvasValue, x2: CanvasValue, y2: CanvasValue, t: Double) -> CanvasPoint {
    bezierTangent(start: CanvasPoint(x: x, y: y), control1: CanvasPoint(x: cx1, y: cy1), control2: CanvasPoint(x: cx2, y: cy2), end: CanvasPoint(x: x2, y: y2), time: t)
}



public func path(_ path: @escaping (inout Path) -> Void) -> Instruction {
    .draw { context, size, values in
        draw(path: Path(path), context: &context, size: size, values: values)
    }
}

/// Calculates the X or Y coordinate of a point on a curve. Plug in the X coordinates for all values to get the X as a result, or Y to get the Y as a result, or use the version that takes a CGPoint.
/// - Parameters:
///   - start: The coordinate of the first point on the curve.
///   - control1: The coordinate of the first control point.
///   - control2: The coordinate of the second control point.
///   - end: The coordinate of the second point.
///   - time: The position on the curve, between 0 and 1.
public func curvePoint(start: Double, control1: Double, control2: Double, end: Double, time: Double) -> Double {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    return 0.5 * ((2 * b) + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (-a + 3 * b - 3 * c + d) * t * t * t)
}
@_disfavoredOverload public func curvePoint(start: CanvasValue, control1: CanvasValue, control2: CanvasValue, end: CanvasValue, time: Double) -> CanvasValue {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    let stat1: CanvasValue = ((a * -1) + c) * t
    let stat1_5: CanvasValue = (a * 2) - (b * 5)
    let stat1_75: CanvasValue = (c * 4) - d
    let stat2: CanvasValue = (stat1_5 + stat1_75)
    let stat2_5: CanvasValue = (a * -1) + (b * 3)
    let stat3: CanvasValue = (stat2_5 - (c * 3) + d)
    let stat4: CanvasValue = ((stat2 * t) * t)
    let stat5: CanvasValue = (((stat3 * t) * t) * t)
    return ((b * 2) + stat1 + stat4 + stat5) * 0.5
}
@_disfavoredOverload public func curvePoint(_ start: CanvasValue, _ control1: CanvasValue, _ control2: CanvasValue, _ end: CanvasValue, _ time: Double) -> CanvasValue {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    let stat1: CanvasValue = ((a * -1) + c) * t
    let stat1_5: CanvasValue = (a * 2) - (b * 5)
    let stat1_75: CanvasValue = (c * 4) - d
    let stat2: CanvasValue = (stat1_5 + stat1_75)
    let stat2_5: CanvasValue = (a * -1) + (b * 3)
    let stat3: CanvasValue = (stat2_5 - (c * 3) + d)
    let stat4: CanvasValue = ((stat2 * t) * t)
    let stat5: CanvasValue = (((stat3 * t) * t) * t)
    return ((b * 2) + stat1 + stat4 + stat5) * 0.5
}
public func curvePoint(_ a: Double, _ b: Double, _ c: Double, _ d: Double, _ t: Double) -> Double {
    curvePoint(start: a, control1: b, control2: c, end: d, time: t)
}
public func curvePoint(start: CanvasPoint, control1: CanvasPoint, control2: CanvasPoint, end: CanvasPoint, time: Double) -> CanvasPoint {
    CanvasPoint(x: curvePoint(start: start.x, control1: control1.x, control2: control2.x, end: end.x, time: time), y: curvePoint(start: start.y, control1: control1.y, control2: control2.y, end: end.y, time: time))
}
public func curvePoint(start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint, time: Double) -> CGPoint {
    CGPoint(x: curvePoint(start: start.x, control1: control1.x, control2: control2.x, end: end.x, time: time), y: curvePoint(start: start.y, control1: control1.y, control2: control2.y, end: end.y, time: time))
}
public func curvePoint(x: Double, y: Double, cx1: Double, cy1: Double, cx2: Double, cy2: Double, x2: Double, y2: Double, t: Double) -> CGPoint {
    curvePoint(start: CGPoint(x: x, y: y), control1: CGPoint(x: cx1, y: cy1), control2: CGPoint(x: cx2, y: cy2), end: CGPoint(x: x2, y: y2), time: t)
}

internal func curve(controlPoints: [CGPoint]) -> Instruction {
    .draw { context, size, values in
        let curTightness = values.curveTightness
        
        var b: [CGPoint] = []
        let s = 1 - curTightness
        
        let path = Path {
            let controlPoints = Array(controlPoints)
            $0.move(to: controlPoints[1])
            
            for i in 1..<(controlPoints.count - 2) {
                let currentPoint = controlPoints[i]
                b.append(currentPoint)
                b.append(CGPoint(x: currentPoint.x + (s * controlPoints[i+1].x - s * controlPoints[i-1].x) / 6, y:
                                    currentPoint.y + (s * controlPoints[i+1].y - s * controlPoints[i-1].y) / 6))
                b.append(CGPoint(x: controlPoints[i+1].x + (s * controlPoints[i].x - s * controlPoints[i+2].x) / 6, y:
                                    controlPoints[i+1].y + (s * controlPoints[i].y - s * controlPoints[i+2].y) / 6))
                b.append(CGPoint(x: controlPoints[i+1].x, y: controlPoints[i+1].y))
                $0.addCurve(to: b[3], control1: b[1], control2: b[2])
                print(b)
                b = []
            }
        }
        
        draw(path: path, context: &context, size: size, values: values)
    }
}
public func curve(x1: Double, y1: Double, cx1: Double, cy1: Double, cx2: Double, cy2: Double, x2: Double, y2: Double) -> Instruction {
    curve(controlPoints: [CGPoint(x: x1, y: y1), CGPoint(x: cx1, y: cy1), CGPoint(x: cx2, y: cy2), CGPoint(x: x2, y: y2)])
}
public func curve(_ x1: Double, _ y1: Double, _ cx1: Double, _ cy1: Double, _ cx2: Double, _ cy2: Double, _ x2: Double, _ y2: Double) -> Instruction {
    curve(controlPoints: [CGPoint(x: x1, y: y1), CGPoint(x: cx1, y: cy1), CGPoint(x: cx2, y: cy2), CGPoint(x: x2, y: y2)])
}
public func curve(start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint) -> Instruction {
    curve(x1: start.x, y1: start.y, cx1: control1.x, cy1: control1.y, cx2: control2.x, cy2: control2.y, x2: end.x, y2: end.y)
}
@_disfavoredOverload public func curve(x1: CanvasValue, y1: CanvasValue, cx1: CanvasValue, cy1: CanvasValue, cx2: CanvasValue, cy2: CanvasValue, x2: CanvasValue, y2: CanvasValue) -> Instruction {
    .draw { context, size, values in
        curve(x1: x1.resolve(for: size.width), y1: y1.resolve(for: size.height), cx1: cx1.resolve(for: size.width), cy1: cy1.resolve(for: size.height), cx2: cx2.resolve(for: size.width), cy2: cy2.resolve(for: size.height), x2: x2.resolve(for: size.width), y2: y2.resolve(for: size.height)).draw(context: &context, size: size, values: values)
    }
}
@_disfavoredOverload public func curve(_ x1: CanvasValue, _ y1: CanvasValue, _ cx1: CanvasValue, _ cy1: CanvasValue, _ cx2: CanvasValue, _ cy2: CanvasValue, _ x2: CanvasValue, _ y2: CanvasValue) -> Instruction {
    curve(x1: x1, y1: y1, cx1: cx1, cy1: cy1, cx2: cx2, cy2: cy2, x2: x2, y2: y2)
}
@_disfavoredOverload public func curve(start: CanvasPoint, control1: CanvasPoint, control2: CanvasPoint, end: CanvasPoint) -> Instruction {
    curve(start.x, start.y, control1.x, control1.y, control2.x, control2.y, end.x, end.y)
}

public func curveTightness(_ tightness: Double) -> Instruction {
    .action { $0.curveTightness = tightness }
}

public func curveTangent(start: Double, control1: Double, control2: Double, end: Double, time: Double) -> Double {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    return 0.5 * ((-a + c) + 2 * (2 * a - 5 * b + 4 * c - d) * t + 3 * (-a + 3 * b - 3 * c + d) * t * t)
}
@_disfavoredOverload public func curveTangent(start: CanvasValue, control1: CanvasValue, control2: CanvasValue, end: CanvasValue, time: Double) -> CanvasValue {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    return 0.5 * ((-a + c) + 2 * (2 * a - 5 * b + 4 * c - d) * t + 3 * (-a + 3 * b - 3 * c + d) * t * t)
}
@_disfavoredOverload public func curveTangent(_ start: CanvasValue, _ control1: CanvasValue, _ control2: CanvasValue, _ end: CanvasValue, _ time: Double) -> CanvasValue {
    let a = start
    let b = control1
    let c = control2
    let d = end
    let t = time
    
    return 0.5 * ((-a + c) + 2 * (2 * a - 5 * b + 4 * c - d) * t + 3 * (-a + 3 * b - 3 * c + d) * t * t);
}
public func curveTangent(_ a: Double, _ b: Double, _ c: Double, _ d: Double, _ t: Double) -> Double {
    curveTangent(start: a, control1: b, control2: c, end: d, time: t)
}
public func curveTangent(start: CanvasPoint, control1: CanvasPoint, control2: CanvasPoint, end: CanvasPoint, time: Double) -> CanvasPoint {
    CanvasPoint(x: curveTangent(start: start.x, control1: control1.x, control2: control2.x, end: end.x, time: time), y: curveTangent(start: start.y, control1: control1.y, control2: control2.y, end: end.y, time: time))
}
public func curveTangent(start: CGPoint, control1: CGPoint, control2: CGPoint, end: CGPoint, time: Double) -> CGPoint {
    CGPoint(x: curveTangent(start: start.x, control1: control1.x, control2: control2.x, end: end.x, time: time), y: curveTangent(start: start.y, control1: control1.y, control2: control2.y, end: end.y, time: time))
}
public func curveTangent(x: Double, y: Double, cx1: Double, cy1: Double, cx2: Double, cy2: Double, x2: Double, y2: Double, t: Double) -> CGPoint {
    curveTangent(start: CGPoint(x: x, y: y), control1: CGPoint(x: cx1, y: cy1), control2: CGPoint(x: cx2, y: cy2), end: CGPoint(x: x2, y: y2), time: t)
}
