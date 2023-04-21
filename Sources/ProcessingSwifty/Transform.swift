//
//  Transform.swift
//  ProcessingJS-Swift
//
//  Created by Eric Bodnick on 4/16/23.
//

import Foundation
import SwiftUI

public func rotate(_ angle: Angle) -> Instruction {
    .draw { context, size, values in
        context.rotate(by: angle)
    }
}
public func rotate(by angle: Angle) -> Instruction {
    .draw { context, size, values in
        context.rotate(by: angle)
    }
}

public func scale(_ percent: Double) -> Instruction {
    .draw { context, size, values in
        context.scaleBy(x: percent, y: percent)
    }
}
public func scale(by percent: Double) -> Instruction {
    .draw { context, size, values in
        context.scaleBy(x: percent, y: percent)
    }
}
public func scale(x: Double, y: Double) -> Instruction {
    .draw { context, _, _ in
        context.scaleBy(x: x, y: y)
    }
}
public func scale(_ x: Double, _ y: Double) -> Instruction {
    .draw { context, _, _ in
        context.scaleBy(x: x, y: y)
    }
}

@_disfavoredOverload public func translate(x: CanvasValue, y: CanvasValue) -> Instruction {
    .draw { context, size, values in
        context.translateBy(x: x.resolve(for: size.width), y: y.resolve(for: size.height))
    }
}
public func translate(x: Double, y: Double) -> Instruction {
    .draw { context, size, values in
        context.translateBy(x: x, y: y)
    }
}
@_disfavoredOverload public func translate(_ x: CanvasValue, _ y: CanvasValue) -> Instruction {
    .draw { context, size, values in
        context.translateBy(x: x.resolve(for: size.width), y: y.resolve(for: size.height))
    }
}
public func translate(_ x: Double, _ y: Double) -> Instruction {
    .draw { context, size, values in
        context.translateBy(x: x, y: y)
    }
}

public func pushMatrix() -> Instruction {
    .draw { context, size, values in
        values.matrices.append(context.transform)
    }
}
public func popMatrix() -> Instruction {
    .draw { context, size, values in
        context.transform = values.matrices.popLast() ?? .identity
    }
}
public func resetMatrix() -> Instruction {
    .draw { context, _, _ in
        context.transform = .identity
    }
}
public func printMatrix() -> Instruction {
    .draw { ctxt, sz, values in
        print(ctxt.transform)
    }
}
