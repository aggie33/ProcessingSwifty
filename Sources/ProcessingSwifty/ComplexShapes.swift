//
//  ComplexShapes.swift
//  ProcessingJS-Swift
//
//  Created by Eric Bodnick on 4/15/23.
//

import Foundation
import SwiftUI
import Algorithms

public enum BeginShapeMode {
    case points
    case lines
    case triangles
    case triangleFan
    case triangleStrip
    case quads
    case quadStrip
}
public enum EndShapeMode {
    case close
}
public enum ShapeType {
    case bezier
    case regular
    case curve
}
public enum Vertex {
    case point(x: CanvasValue, y: CanvasValue)
    case bezier(cx1: CanvasValue, cy1: CanvasValue, cx2: CanvasValue, cy2: CanvasValue, x: CanvasValue, y: CanvasValue)
    
    var x: CanvasValue {
        switch self {
        case let .point(x: x, y: _):
            return x
        case let .bezier(cx1: cx1, cy1: _, cx2: _, cy2: _, x: _, y: _):
            return cx1
        }
    }
    
    var y: CanvasValue {
        switch self {
        case let .point(x: _, y: y):
            return y
        case let .bezier(cx1: _, cy1: cy1, cx2: _, cy2: _, x: _, y: _):
            return cy1
        }
    }
}

public func beginShape(_ mode: BeginShapeMode? = nil) -> Instruction {
    .action { values in
        values.beginShapeMode = mode
        values.vertices = []
        values.shapeType = .regular
    }
}

@_disfavoredOverload public func vertex(x: Double, y: Double) -> Instruction {
    .action { values in
        values.vertices.append(.point(x: .absolute(x), y: .absolute(y)))
    }
}
@_disfavoredOverload public func vertex(_ x: Double, _ y: Double) -> Instruction {
    .action { values in
        values.vertices.append(.point(x: .absolute(x), y: .absolute(y)))
    }
}
public func vertex(_ point: CGPoint) -> Instruction {
    .action { values in
        values.vertices.append(.point(x: .absolute(point.x), y: .absolute(point.y)))
    }
}
public func vertex(x: CanvasValue, y: CanvasValue) -> Instruction {
    .action { values in
        values.vertices.append(.point(x: x, y: y))
    }
}
public func vertex(_ x: CanvasValue, _ y: CanvasValue) -> Instruction {
    .action { values in
        values.vertices.append(.point(x: x, y: y))
    }
}
public func vertex(_ point: CanvasPoint) -> Instruction {
    .action { values in
        values.vertices.append(.point(x: point.x, y: point.y))
    }
}

@_disfavoredOverload public func curveVertex(x: Double, y: Double) -> Instruction {
    .action { values in
        values.shapeType = .curve
        values.vertices.append(.point(x: .absolute(x), y: .absolute(y)))
    }
}
@_disfavoredOverload public func curveVertex(_ x: Double, _ y: Double) -> Instruction {
    .action { values in
        values.shapeType = .curve
        values.vertices.append(.point(x: .absolute(x), y: .absolute(y)))
    }
}
public func curveVertex(_ point: CGPoint) -> Instruction {
    .action { values in
        values.shapeType = .curve
        values.vertices.append(.point(x: .absolute(point.x), y: .absolute(point.y)))
    }
}
public func curveVertex(x: CanvasValue, y: CanvasValue) -> Instruction {
    .action { values in
        values.shapeType = .curve
        values.vertices.append(.point(x: x, y: y))
    }
}
public func curveVertex(_ x: CanvasValue, _ y: CanvasValue) -> Instruction {
    .action { values in
        values.shapeType = .curve
        values.vertices.append(.point(x: x, y: y))
    }
}
public func curveVertex(_ point: CanvasPoint) -> Instruction {
    .action { values in
        values.shapeType = .curve
        values.vertices.append(.point(x: point.x, y: point.y))
    }
}

public func bezierVertex(cx1: CanvasValue, cy1: CanvasValue, cx2: CanvasValue, cy2: CanvasValue, x: CanvasValue, y: CanvasValue) -> Instruction {
    .action { values in
        values.shapeType = .bezier
        values.vertices.append(.bezier(cx1: cx1, cy1: cy1, cx2: cx2, cy2: cy2, x: x, y: y))
    }
}
public func bezierVertex(_ cx1: CanvasValue, _ cy1: CanvasValue, _ cx2: CanvasValue, _ cy2: CanvasValue, _ x: CanvasValue, _ y: CanvasValue) -> Instruction {
    .action { values in
        values.shapeType = .bezier
        values.vertices.append(.bezier(cx1: cx1, cy1: cy1, cx2: cx2, cy2: cy2, x: x, y: y))
    }
}
public func bezierVertex(control1: CanvasPoint, control2: CanvasPoint, end: CanvasPoint) -> Instruction {
    bezierVertex(cx1: control1.x, cy1: control1.y, cx2: control2.x, cy2: control2.y, x: end.x, y: end.y)
}
@_disfavoredOverload public func bezierVertex(_ cx1: Double, _ cy1: Double, _ cx2: Double, _ cy2: Double, _ x: Double, _ y: Double) -> Instruction {
    bezierVertex(cx1: .absolute(cx1), cy1: .absolute(cy1), cx2: .absolute(cx2), cy2: .absolute(cy2), x: .absolute(x), y: .absolute(y))
}
@_disfavoredOverload public func bezierVertex(cx1: Double, cy1: Double, cx2: Double, cy2: Double, x: Double, y: Double) -> Instruction {
    bezierVertex(cx1: .absolute(cx1), cy1: .absolute(cy1), cx2: .absolute(cx2), cy2: .absolute(cy2), x: .absolute(x), y: .absolute(y))
}
public func bezierVertex(control1: CGPoint, control2: CGPoint, end: CGPoint) -> Instruction {
    bezierVertex(control1: .absolute(control1), control2: .absolute(control2), end: .absolute(end))
}

public func endShape(_ mode: EndShapeMode? = nil) -> Instruction {
    .draw { context, size, values in
        switch values.shapeType {
        case .bezier:
            let path = Path { path in
                path.move(to: CGPoint(x: values.vertices[0].x.resolve(for: size.width), y: values.vertices[0].y.resolve(for: size.height)))
                for vertex in values.vertices.dropFirst(1) {
                    switch vertex {
                    case let .point(x: x, y: y):
                        let x = x.resolve(for: size.width)
                        let y = y.resolve(for: size.height)
                        
                        path.addLine(to: CGPoint(x: x, y: y))
                    case let .bezier(cx1: cx1, cy1: cy1, cx2: cx2, cy2: cy2, x: x, y: y):
                        let cx1 = cx1.resolve(for: size.width)
                        let cx2 = cx2.resolve(for: size.width)
                        let x = x.resolve(for: size.width)
                        let cy1 = cy1.resolve(for: size.height)
                        let cy2 = cy2.resolve(for: size.height)
                        let y = y.resolve(for: size.height)
                        
                        path.addCurve(to: CGPoint(x: x, y: y), control1: CGPoint(x: cx1, y: cy1), control2: CGPoint(x: cx2, y: cy2))
                    }
                    
                    if mode == .close {
                        path.closeSubpath()
                    }
                }
                
                
            }
            draw(path: path, context: &context, size: size, values: values)
        case .regular:
            switch values.beginShapeMode {
            case .points:
                for vertex in values.vertices {
                    point(vertex.x, vertex.y).draw(context: &context, size: size, values: values)
                }
            case .lines:
                let path = Path { path in
                    for chunk in values.vertices.chunks(ofCount: 2) {
                        if chunk.count >= 2 {
                            let start = chunk[chunk.startIndex]
                            let end = chunk[chunk.index(after: chunk.startIndex)]
                            
                            path.move(to: CGPoint(x: start.x.resolve(for: size.width), y: start.y.resolve(for: size.height)))
                            path.addLine(to: CGPoint(x: end.x.resolve(for: size.width), y: end.y.resolve(for: size.height)))
                        }
                    }
                }
                
                draw(path: path, context: &context, size: size, values: values)
            case .triangles:
                let path = Path { path in
                    for chunk in values.vertices.chunks(ofCount: 3) where chunk.count == 3 {
                        let startIndex = chunk.startIndex
                        
                        let p1 = chunk[startIndex]
                        let p2 = chunk[startIndex + 1]
                        let p3 = chunk[startIndex + 2]
                        
                        path.move(to: CGPoint(x: p1.x.resolve(for: size.width), y: p1.y.resolve(for: size.height)))
                        path.addLine(to: CGPoint(x: p2.x.resolve(for: size.width), y: p2.y.resolve(for: size.height)))
                        path.addLine(to: CGPoint(x: p3.x.resolve(for: size.width), y: p3.y.resolve(for: size.height)))
                        path.closeSubpath()
                    }
                }
                
                draw(path: path, context: &context, size: size, values: values)
            case .triangleStrip:
                let path = Path { path in
                    for i in 0..<(values.vertices.count - 2) {
                        let p1 = values.vertices[i]
                        let p2 = values.vertices[i + 1]
                        let p3 = values.vertices[i + 2]
                        
                        path.move(to: CGPoint(x: p1.x.resolve(for: size.width), y: p1.y.resolve(for: size.height)))
                        path.addLine(to: CGPoint(x: p2.x.resolve(for: size.width), y: p2.y.resolve(for: size.height)))
                        path.addLine(to: CGPoint(x: p3.x.resolve(for: size.width), y: p3.y.resolve(for: size.height)))
                        path.closeSubpath()
                    }
                }
                
                draw(path: path, context: &context, size: size, values: values)
            case .triangleFan:
                let path = Path { path in
                    let vertices = values.vertices.map { CGPoint(x: $0.x.resolve(for: size.width), y: $0.y.resolve(for: size.height)) }
                    
                    if values.vertices.count > 2 {
                        path.move(to: vertices[0])
                        path.addLine(to: vertices[1])
                        path.addLine(to: vertices[2])
                        path.closeSubpath()
                        
                        for i in 3..<vertices.count {
                            path.move(to: vertices[0])
                            path.addLine(to: vertices[i - 1])
                            path.addLine(to: vertices[i])
                            path.closeSubpath()
                        }
                    }
                }
                
                draw(path: path, context: &context, size: size, values: values)
            case .quads:
                let path = Path { path in
                    let vertices = values.vertices.map { CGPoint(x: $0.x.resolve(for: size.width), y: $0.y.resolve(for: size.height)) }
                    
                    for chunk in vertices.chunks(ofCount: 4) where chunk.count == 4 {
                        let i = chunk.startIndex
                        
                        let p0 = chunk[i]
                        let p1 = chunk[i+1]
                        let p2 = chunk[i+2]
                        let p3 = chunk[i+3]
                        
                        path.move(to: p0)
                        path.addLine(to: p1)
                        path.addLine(to: p2)
                        path.addLine(to: p3)
                        path.closeSubpath()
                    }
                }
                
                draw(path: path, context: &context, size: size, values: values)
            case .quadStrip:
                let vertices = values.vertices.map { CGPoint(x: $0.x.resolve(for: size.width), y: $0.y.resolve(for: size.height)) }
                
                let path = Path { path in
                    if vertices.count > 3 {
                        for i in stride(from: 0, to: vertices.count, by: 2) {
                            if i + 3 < vertices.count {
                                path.move(to: vertices[i + 2])
                                path.addLine(to: vertices[i])
                                path.addLine(to: vertices[i + 1])
                                path.addLine(to: vertices[i + 3])
                            } else {
                                path.move(to: vertices[i])
                                path.addLine(to: vertices[i + 1])
                            }
                        }
                        
                        if mode == .close {
                            path.closeSubpath()
                        }
                    }
                }
                
                draw(path: path, context: &context, size: size, values: values)
            default:
                let path = Path {
                    $0.move(to: CGPoint(x: values.vertices[0].x.resolve(for: size.width), y: values.vertices[0].y.resolve(for: size.height)))
                    
                    for vertex in values.vertices.dropFirst(1) {
                        $0.addLine(to: CGPoint(x: vertex.x.resolve(for: size.width), y: vertex.y.resolve(for: size.height)))
                    }
                    
                    if mode == .close {
                        $0.closeSubpath()
                    }
                }
                
                draw(path: path, context: &context, size: size, values: values)
            }
        case .curve:
            curve(controlPoints: values.vertices.map { CGPoint(x: $0.x.resolve(for: size.width), y: $0.y.resolve(for: size.height))}).draw(context: &context, size: size, values: values)
        }
    }
}

public func strokeJoin(_ join: CGLineJoin) -> Instruction {
    .action { $0.strokeJoin = join }
}
