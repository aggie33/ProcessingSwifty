//
//  Text.swift
//  ProcessingJS-Swift
//
//  Created by Eric Bodnick on 4/15/23.
//

import Foundation
import SwiftUI

public func text(_ text: String, x: CanvasValue, y: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let alignment = values.textAlignment
        let text = context.resolve(Text(text).foregroundColor(values.fillColor).font(.system(size: values.textSize, design: values.textDesign)))
        let textDescent = textDescent().obtain(context, size, values)
        let textAscent = textAscent().obtain(context, size, values)
        
        var x = x.resolve(for: size.width)
        var y = y.resolve(for: size.height)
        print("Y: \(y)")
        let horizontalAlignment: Double
        let verticalAlignment: Double
        
        switch alignment.horizontal {
        case .center:
            horizontalAlignment = 0.5
        case .leading:
            horizontalAlignment = 0
        case .trailing:
            horizontalAlignment = 1
        default:
            horizontalAlignment = 0
        }
        
        print(textDescent)
        
        switch alignment.vertical {
        case .bottom:
            verticalAlignment = 0
        case .center:
            verticalAlignment = 0.5
        case .top:
            verticalAlignment = 1
        case .firstTextBaseline:
            verticalAlignment = 0
            y -= text.firstBaseline(in: CGSize(width: CGFloat.infinity, height: .infinity))
            print("Y changed to \(y)")
        default:
            verticalAlignment = 0
            y += text.firstBaseline(in: CGSize(width: CGFloat.infinity, height: .infinity))
            print(textDescent)
        }
        
        context.draw(text, at: CGPoint(x: x, y: y), anchor: UnitPoint(x: horizontalAlignment, y: verticalAlignment))
    }
}
public func text(_ textValue: String, _ x: CanvasValue, _ y: CanvasValue) -> Instruction {
    text(textValue, x: x, y: y)
}
public func text(_ textValue: String, at point: CanvasPoint) -> Instruction {
    text(textValue, x: point.x, y: point.y)
}
@_disfavoredOverload public func text(_ textValue: String, x: Double, y: Double) -> Instruction {
    text(textValue, x: .absolute(x), y: .absolute(y))
}
@_disfavoredOverload public func text(_ textValue: String, _ x: Double, _ y: Double) -> Instruction {
    text(textValue, .absolute(x), .absolute(y))
}
public func text(_ textValue: String, at point: CGPoint) -> Instruction {
    text(textValue, at: .absolute(point))
}

/// When text is drawn in a rectangle, it ignores `textAlign`.
public func text(_ text: String, x: CanvasValue, y: CanvasValue, width: CanvasValue, height: CanvasValue) -> Instruction {
    .draw { context, size, values in
        let text = Text(text).foregroundColor(values.fillColor).font(.system(size: values.textSize, design: values.textDesign))
        
        context.draw(text, in: CGRect(x: x.resolve(for: size.width), y: y.resolve(for: size.height), width: width.resolve(for: size.width), height: height.resolve(for: size.height)))
    }
}
public func text(_ textValue: String, _ x: CanvasValue, _ y: CanvasValue, _ width: CanvasValue, _ height: CanvasValue) -> Instruction {
    text(textValue, x: x, y: y, width: width, height: height)
}
public func text(_ textValue: String, at point: CanvasPoint, in size: CanvasSize) -> Instruction {
    text(textValue, point.x, point.y, size.width, size.height)
}
@_disfavoredOverload public func text(_ textValue: String, x: Double, y: Double, width: Double, height: Double) -> Instruction {
    text(textValue, .absolute(x), .absolute(y), .absolute(width), .absolute(height))
}
@_disfavoredOverload public func text(_ textValue: String, _ x: Double, _ y: Double, _ width: Double, _ height: Double) -> Instruction {
    text(textValue, x: x, y: y, width: width, height: height)
}
public func text(_ textValue: String, at point: CGPoint, in size: CGSize) -> Instruction {
    text(textValue, x: point.x, y: point.y, width: size.width, height: size.height)
}

public func textSize(_ size: Double) -> Instruction {
    .action {
        print("Text size changed to \(size)")
        $0.textSize = size }
}

public func createFont(_ name: Font.Design) -> Font.Design {
    name
}

public func textFont(_ font: Font.Design, size: Double? = nil) -> Instruction {
    .action { values in values.textDesign = font; size.map { size in values.textSize = size }}
}
public func textFont(_ font: Font.Design, _ size: Double? = nil) -> Instruction {
    .action { values in values.textDesign = font; size.map { size in values.textSize = size }}
}
public func textWidth(_ text: String) -> DelayedValue<Double> {
    .init { context, size, values in
        let resolvedText = context.resolve(Text(text).font(.system(size: values.textSize, design: values.textDesign)))
        return resolvedText.measure(in: CGSize(width: CGFloat.infinity, height: CGFloat.infinity)).width
    }
}
public func textAscent() -> DelayedValue<Double> {
    .init { context, size, values in
        let design: NSFontDescriptor.SystemDesign
        
        switch values.textDesign {
        case .rounded:
            design = .rounded
        case .default:
            design = .default
        case .monospaced:
            design = .monospaced
        case .serif:
            design = .serif
        @unknown default:
            design = .default
            print("Unrecognized font design used")
        }
        
        let font = CTFontCreateWithFontDescriptor(NSFont.systemFont(ofSize: values.textSize).fontDescriptor.withDesign(design)!, values.textSize, nil)
        return CTFontGetAscent(font) - CTFontGetDescent(font)
    }
}
public func textDescent() -> DelayedValue<Double> {
    .init { context, size, values in
        let design: NSFontDescriptor.SystemDesign
        
        switch values.textDesign {
        case .rounded:
            design = .rounded
        case .default:
            design = .default
        case .monospaced:
            design = .monospaced
        case .serif:
            design = .serif
        @unknown default:
            design = .default
            print("Unrecognized font design used")
        }
        
        let font = CTFontCreateWithFontDescriptor(NSFont.systemFont(ofSize: values.textSize).fontDescriptor.withDesign(design)!, values.textSize, nil)
        return CTFontGetDescent(font)
    }
}

@available(*, unavailable, message: "textLeading(_:) is not available in ProcessingJS-Swift. If you need to adjust multiline text spacing, use the .lineSpacing(_:) modifier on the parent view of the game.")
public func textLeading(_ amount: Double) -> Instruction {
    fatalError()
}

public func textAlign(_ alignment: Alignment) -> Instruction {
    .action { $0.textAlignment = alignment }
}
