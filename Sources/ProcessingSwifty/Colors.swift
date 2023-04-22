//
//  Colors.swift
//  ProcessingJS-Swift
//
//  Created by Eric Bodnick on 4/15/23.
//

import Foundation

/*
    blendColor(c1, c2, MODE)
 */

import SwiftUI

public enum ColorMode {
    /// Red, green, and blue
    case rgb
    
    /// Hue, saturation and brightness
    case hsb
}

/// Draws a single-color background across the whole scene, covering anything drawn beforehand.
/// - Parameter p: A single value between `0...255` that will be used to determine the shade of gray used.
public func background(_ p: Double) -> Instruction {
    background(p, p, p)
}

/// Draws a single-color background across the whole scene, covering anything drawn beforehand.
/// - Parameter color: The color of the background.
public func background(_ color: Color) -> Instruction {
    return .draw { context, size, values in
        let rect = CGRect(origin: .zero, size: size)
        context.fill(Path(rect), with: .color(color))
    }
}

/// Draws a single-color background across the whole scene, covering anything drawn beforehand.
/// - Parameters:
///   - red: The amount of red in the color, which must be between 0 and 255.
///   - green: The amount of red in the color, which must be between 0 and 255.
///   - blue: The amount of red in the color, which must be between 0 and 255.
///   - alpha: The opacity of the color, which must be between 0 and 255, 255 being fully opaque and 0 being fully clear.
public func background(red: Double, green: Double, blue: Double, alpha: Double = 255) -> Instruction {
    background(Color(red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha / 255))
}

/// Draws a single-color background across the whole scene, covering anything drawn beforehand.
/// - Parameters:
///   - hue: The hue of the color, which must be between 0 and 255.
///   - saturation: The saturation of the color, which must be between 0 and 255.
///   - brightness: The brightness of the color, which must be between 0 and 255.
///   - alpha: The opacity of the color, which must be between 0 (fully clear) and 255 (fully opaque).
public func background(hue: Double, saturation: Double, brightness: Double, alpha: Double = 255) -> Instruction {
    background(Color(hue: hue / 255, saturation: saturation / 255, brightness: brightness / 255, opacity: alpha / 255))
}


/// Draws a single-color background across the whole scene, covering anything drawn beforehand. If `colorMode` is `rgb`, it's equivalent to calling `background(red:green:blue:alpha:)` without argument labels. If `colorMode` is `hsb`, it's equivalent to calling `background(hue:saturation:brightness:alpha)` without argument labels.
public func background(_ p1: Double, _ p2: Double, _ p3: Double, _ alpha: Double = 255) -> Instruction {
    .draw { context, size, values in
        switch values.colorMode {
        case .hsb:
            background(hue: p1, saturation: p2, brightness: p3, alpha: alpha).draw(context: &context, size: size, values: values)
        case .rgb:
            background(red: p1, green: p2, blue: p3, alpha: alpha).draw(context: &context, size: size, values: values)
        }
    }
}

public func fill(_ p: Double) -> Instruction {
    fill(p, p, p)
}
public func fill(_ color: Color) -> Instruction {
    return .action { values in
        values.fillColor = color
        values.noFill = false
    }
}
public func fill(_ p1: Double, _ p2: Double, _ p3: Double, _ alpha: Double = 255) -> Instruction {
    .action { values in
        switch values.colorMode {
        case .hsb:
            fill(hue: p1, saturation: p2, brightness: p3, alpha: alpha).action(values: &values)
        case .rgb:
            fill(red: p1, green: p2, blue: p3, alpha: alpha).action(values: &values)
        }
    }
}
public func fill(red: Double, green: Double, blue: Double, alpha: Double = 255) -> Instruction {
    fill(Color(red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha / 255))
}
public func fill(hue: Double, saturation: Double, brightness: Double, alpha: Double = 255) -> Instruction {
    fill(Color(hue: hue / 255, saturation: saturation / 255, brightness: brightness / 255, opacity: alpha / 255))
}

public func noFill() -> Instruction {
    .action { values in
        values.noFill = true
    }
}

public func stroke(_ p: Double) -> Instruction {
    stroke(p, p, p)
}
public func stroke(_ color: Color) -> Instruction {
    return .action { values in
        values.strokeColor = color
        values.noStroke = false
    }
}
public func stroke(hue: Double, saturation: Double, brightness: Double, alpha: Double = 255) -> Instruction {
    stroke(Color(hue: hue / 255, saturation: saturation / 255, brightness: brightness / 255, opacity: alpha / 255))
}
public func stroke(_ p1: Double, _ p2: Double, _ p3: Double, _ alpha: Double = 255) -> Instruction {
    .action { values in
        switch values.colorMode {
        case .hsb:
            stroke(hue: p1, saturation: p2, brightness: p3, alpha: alpha).action(values: &values)
        case .rgb:
            stroke(red: p1, green: p2, blue: p3, alpha: alpha).action(values: &values)
        }
    }
}
public func stroke(red: Double, green: Double, blue: Double, alpha: Double = 255) -> Instruction {
    stroke(Color(red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha / 255))
}

public func strokeWeight(_ weight: Double) -> Instruction { .action { $0.strokeWeight = weight} }

public func noStroke() -> Instruction {
    .action { values in
        values.noStroke = true
    }
}

public func color(_ red: Double, _ green: Double, _ blue: Double, _ alpha: Double = 255) -> Color {
    Color(red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha / 255)
}
public func color(red: Double, green: Double, blue: Double, alpha: Double = 255) -> Color {
    Color(red: red / 255, green: green / 255, blue: blue / 255, opacity: alpha / 255)
}

public func color(_ black: Double) -> Color {
    color(black, black, black)
}

public func colorMode(_ mode: ColorMode) -> Instruction { .action { $0.colorMode = mode }}

public func red(_ color: Color) -> Double {
    NSColor(color).redComponent * 255.0
}
public func green(_ color: Color) -> Double {
    NSColor(color).greenComponent * 255.0
}
public func blue(_ color: Color) -> Double {
    NSColor(color).blueComponent * 255.0
}
public func alpha(_ color: Color) -> Double {
    NSColor(color).alphaComponent * 255.0
}
public func hue(_ color: Color) -> Double {
    NSColor(color).hueComponent * 255.0
}
public func saturation(_ color: Color) -> Double {
    NSColor(color).saturationComponent * 255.0
}
public func brightness(_ color: Color) -> Double {
    NSColor(color).brightnessComponent * 255.0
}

public func decompose(_ color: Color) -> (red: Double, green: Double, blue: Double, alpha: Double, hue: Double, saturation: Double, brightness: Double) {
    let color = NSColor(color)
    return (color.redComponent * 255, color.greenComponent * 255, color.blueComponent * 255, color.alphaComponent * 255, color.hueComponent * 255, color.saturationComponent * 255, color.brightnessComponent * 255)
}

public func lerpColor(_ c1: Color, _ c2: Color, amount: Double) -> Color {
    let c1 = decompose(c1)
    let c2 = decompose(c2)
    
    return color(red: c1.red + (c2.red - c1.red) * amount, green: c1.green + (c2.green - c1.green) * amount, blue: c1.blue + (c2.blue - c1.blue) * amount, alpha: c1.alpha + (c2.alpha - c1.alpha) * amount)
}
public func lerpColor(_ c1: Color, _ c2: Color, _ amount: Double) -> Color {
    lerpColor(c1, c2, amount: amount)
}

public enum BlendColorMode {
    case blend
    case add
    case subtract
    case darkest
    case lightest
    case difference
    case exclusion
    case multiply
    case screen
    case overlay
    case hardLight
    case softLight
    case dodge
    case burn
}

// MARK: FIXME - BlendColor doesn't correctly blend transparent colors
public func blendColor(_ c1: Color, _ c2: Color, mode: BlendColorMode = .blend) -> Color {
    let c1 = decompose(c1)
    let c2 = decompose(c2)
    let factor = ((255 - c2.alpha) / 255)
    
    switch mode {
    case .blend:
        return color(red: c1.red * factor + c2.red, green: c1.green * factor + c2.green, blue: c1.blue * factor + c2.blue)
    case .add:
        return color(red: min(c1.red + c2.red, 255), green: min(c1.green + c2.green, 255), blue: min(c1.blue + c2.blue, 255))
    case .subtract:
        return color(red: max(c1.red - c2.red, 0), green: max(c1.green - c2.green, 0), blue: max(c1.blue - c2.blue, 0))
    case .darkest:
        return color(red: min(c1.red, c2.red), green: min(c1.green, c2.green), blue: min(c1.blue, c2.blue))
    case .lightest:
        return color(red: max(c1.red, c2.red), green: max(c1.green, c2.green), blue: max(c1.blue, c2.blue))
    case .difference:
        return color(red: abs(c2.red - c1.red), green: abs(c2.green - c1.green), blue: abs(c2.blue - c1.blue))
    case .exclusion:
        return color(red: c2.red + c1.red - Double(Int(c2.red * c1.red) >> 7), green: c2.green + c1.green - Double(Int(c2.green * c1.green) >> 7), blue: c2.blue + c1.blue - Double(Int(c2.blue * c1.blue) >> 7))
    case .multiply:
        return color(red: Double(Int(c1.red * c2.red) >> 8), green: Double(Int(c1.green * c2.green) >> 8), blue: Double(Int(c1.blue * c2.blue) >> 8))
    case .screen:
        return color(red: 255 - Double(Int((255 - c1.red) * (255 - c2.red)) >> 8), green: 255 - Double(Int((255 - c1.green) * (255 - c2.green)) >> 8), blue: 255 - Double(Int((255 - c1.blue) * (255 - c2.blue)) >> 8))
    case .overlay:
        let red = (c1.red < 128) ? (Int(c1.red * c2.red) >> 7) : (255 - (Int((255 - c1.red) * (255 - c2.red)) >> 7))
        let green = (c1.green < 128) ? (Int(c1.green * c2.green) >> 7) : (255 - (Int((255 - c1.green) * (255 - c2.green)) >> 7))
        let blue = (c1.red < 128) ? (Int(c1.red * c2.blue) >> 7) : (255 - (Int((255 - c1.blue) * (255 - c2.blue)) >> 7))
        
        return color(Double(red), Double(green), Double(blue))
    case .hardLight:
        let ar = Int(c1.red)
        let ag = Int(c1.green)
        let ab = Int(c1.blue)
        let br = Int(c2.red)
        let bg = Int(c2.green)
        let bb = Int(c2.blue)
        
        let cr = (br < 128) ? ((ar * br) >> 7) : (255 - (((255 - ar) * (255 - br)) >> 7))
        let cg = (bg < 128) ? ((ag * bg) >> 7) : (255 - (((255 - ag) * (255 - bg)) >> 7))
        let cb = (bb < 128) ? ((ab * bb) >> 7) : (255 - (((255 - ab) * (255 - bb)) >> 7))
        
        return color(red: Double(cr), green: Double(cg), blue: Double(cb))
    case .softLight:
        let ar = Int(c1.red)
        let ag = Int(c1.green)
        let ab = Int(c1.blue)
        let br = Int(c2.red)
        let bg = Int(c2.green)
        let bb = Int(c2.blue)
        
        let cr = ((ar * br) >> 7) + ((ar * ar) >> 8) - ((ar * ar * br) >> 15)
        let cg = ((ag * bg) >> 7) + ((ag * ag) >> 8) - ((ag * ag * bg) >> 15)
        let cb = ((ab * bb) >> 7) + ((ab * ab) >> 8) - ((ab * ab * bb) >> 15)
        
        return color(red: Double(cr), green: Double(cg), blue: Double(cb))
    case .burn:
        let ar = Int(c1.red)
        let ag = Int(c1.green)
        let ab = Int(c1.blue)
        let br = Int(c2.red)
        let bg = Int(c2.green)
        let bb = Int(c2.blue)
        
        var cr = 0;
          if (br != 0) {
            cr = ((255 - ar) << 8) / br;
            cr = 255 - ((cr < 0) ? 0 : ((cr > 255) ? 255 : cr));
          }

          var cg = 0;
          if (bg != 0) {
            cg = ((255 - ag) << 8) / bg;
            cg = 255 - ((cg < 0) ? 0 : ((cg > 255) ? 255 : cg));
          }

          var cb = 0;
        if (bb != 0) {
            cb = ((255 - ab) << 8) / bb;
            cb = 255 - ((cb < 0) ? 0 : ((cb > 255) ? 255 : cb));
        }
              
              return color(red: Double(cr), green: Double(cg), blue: Double(cb))
    case .dodge:
        let ar = Int(c1.red)
        let ag = Int(c1.green)
        let ab = Int(c1.blue)
        let br = Int(c2.red)
        let bg = Int(c2.green)
        let bb = Int(c2.blue)
        
        var cr = 255;
          if (br != 255) {
            cr = (ar << 8) / (255 - br);
            cr = (cr < 0) ? 0 : ((cr > 255) ? 255 : cr);
          }

          var cg = 255;
          if (bg != 255) {
            cg = (ag << 8) / (255 - bg);
            cg = (cg < 0) ? 0 : ((cg > 255) ? 255 : cg);
          }

          var cb = 255;
          if (bb != 255) {
            cb = (ab << 8) / (255 - bb);
            cb = (cb < 0) ? 0 : ((cb > 255) ? 255 : cb);
          }
        
        return color(red: Double(cr), green: Double(cg), blue: Double(cb))
    }
}
