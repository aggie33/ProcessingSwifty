//
//  Games.swift
//  ProcessingJS-Swift
//
//  Created by Eric Bodnick on 4/12/23.
//

//
//  Internals.swift
//  ProcessingJS-Swift
//
//  Created by Eric Bodnick on 4/11/23.
//

/*
 
 Overall project roadmap:
 
 SHAPES:
 func ellipse(x: CanvasValue, y: CanvasValue, width: CanvasValue, height: CanvasValue)
 func triangle(x1, y1, x2, y2, x3, y3)
 func line(x1, y1, x2, y2)
 func point(x, y)
 func arc(x, y, w, h, start, stop)
 func bezier(x1, y1, cx1, cy1, cx2, cy2, x2, y2)
 func quad(x1, y1, x2, y2, x3, y3, x4, y4)
 func image(image, x, y, width?, height?)
 
 func ellipseMode(mode)
 func rectMode(mode)
 func imageMode(mode)
 func strokeCap(cap)
 func bezierPoint(...)
 func bezierTangent(...)
 func curve(...)
 func curvePoint(...)
 func curveTangent(...)
 func curveTightness(...)
 
 */
import Foundation
import SwiftUI

public struct DelayedValue<T> {
    var obtain: (GraphicsContext, CGSize, GameValues) -> T
    
    /// Does something with the obtained value upon obtaining it.
    ///```swift
    /// public struct BorderedImage: Game {
    ///     var imageWidth: Double = 0
    ///     var imageHeight: Double = 0
    ///
    ///     public func draw(values: CanvasValues) {
    ///         var image = getImage("example_image")
    ///         image(image, x: .relative(0.25), y: .relative(0.25))
    ///
    ///         image.width.send { imageWidth = $0 }
    ///         image.height.send { imageHeight = $0 }
    ///
    ///         noFill()
    ///         rect(x: .relative(0.25), y: .relative(0.25), width: .absolute(imageWidth), height: .absolute(imageHeight))
    ///     }
    /// }
    /// ```
    public func send(closure: @escaping (T) -> Void) -> Instruction {
        .draw { context, size, values in
            closure(obtain(context, size, values))
        }
    }
}

/// A ProcessingJS canvas environment.
public protocol Game {
    mutating func setup() -> Void
    @ContentBuilder func draw(values: CanvasValues) -> Content
    
    mutating func mouseClicked(values: CanvasValues)
    mutating func mousePressed(values: CanvasValues)
    mutating func mouseReleased(values: CanvasValues)
    mutating func mouseMoved(values: CanvasValues)
    mutating func mouseDragged(values: CanvasValues)
    mutating func mouseOver(values: CanvasValues)
    mutating func mouseOut(values: CanvasValues)
    
    mutating func keyPressed(values: CanvasValues)
    mutating func keyReleased(values: CanvasValues)
}

extension Game {
    public func setup() {}
    
    public func mouseClicked(values: CanvasValues) {}
    public func mousePressed(values: CanvasValues) {}
    public func mouseReleased(values: CanvasValues) {}
    public func mouseMoved(values: CanvasValues) {}
    public func mouseDragged(values: CanvasValues) {}
    public func mouseOver(values: CanvasValues) {}
    public func mouseOut(values: CanvasValues) {}
    
    public func keyPressed(values: CanvasValues) {}
    public func keyReleased(values: CanvasValues) {}
}

@resultBuilder public struct ContentBuilder {
    
    public static func buildBlock(_ components: Content...) -> Content {
        Content(instructions: components.reduce([]) { $0 + $1.instructions })
     }
    
    /* I'm gonna try it out with the other kind
    public static func buildExpression(_ expression: Void) -> Content {
        Content(instructions: [])
    }
    
     */
    public static func buildExpression(_ expression: @autoclosure @escaping () -> Instruction) -> Content {
        Content(instructions: [expression])
    }
    
    public static func buildExpression(_ expression: @autoclosure @escaping () -> Void) -> Content {
        Content(instructions: [{.action { _ in
            expression()
        }}])
    }
    
    public static func buildExpression(_ expression: Content) -> Content {
        expression
    }
    
    public static func buildArray(_ components: [Content]) -> Content {
        Content(instructions: components.reduce([]) { $0 + $1.instructions })
    }
    
    public static func buildOptional(_ component: Content?) -> Content {
        component ?? Content(instructions: [])
    }
    
    public static func buildEither(first component: Content) -> Content {
        component
    }
    
    public static func buildEither(second component: Content) -> Content {
        component
    }
    
    public static func buildLimitedAvailability(_ component: Content) -> Content {
        component
    }
}

/// The content of a ProcessingJS canvas.
public struct Content {
    public var instructions: [() -> Instruction]
}
extension Content {
    public init(@ContentBuilder builder: () -> Content) {
        self = builder()
    }
}

/// An individual instruction to either perform an action or draw something to the canvas.
public enum Instruction {
    case draw((inout GraphicsContext, CGSize, GameValues) -> Void)
    case action((inout GameValues) -> Void)
    
    /// If `self` is drawing something, draws that thing.
    func draw(context: inout GraphicsContext, size: CGSize, values: GameValues) {
        switch self {
        case .draw(let closure):
            closure(&context, size, values)
        default:
            return
        }
    }
    func action(values: inout GameValues) {
        if case let .action(closure) = self {
            closure(&values)
        }
    }
}

/// The position or size of something on the canvas.
public struct CanvasValue: ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, AdditiveArithmetic {
    public var absolute: Double = 0
    public var relative: Double = 0
    
    public init(absolute: Double = 0, relative: Double = 0) {
        self.absolute = absolute
        self.relative = relative
    }
    
    public init(floatLiteral value: FloatLiteralType) {
        self.absolute = value
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.absolute = Double(value)
    }
    
    public static func absolute(_ value: Double) -> Self {
        Self(absolute: value)
    }
    
    public static func absolute(_ value: Int) -> Self {
        Self(absolute: Double(value))
    }
    
    public static func relative(_ value: Double) -> Self {
        Self(relative: value)
    }
    
    public static var zero: CanvasValue { CanvasValue() }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(absolute: lhs.absolute + rhs.absolute, relative: lhs.relative + rhs.relative)
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(absolute: lhs.absolute - rhs.absolute, relative: lhs.relative - rhs.relative)
    }
    
    func resolve(for value: Double) -> Double {
        self.relative * value + self.absolute
    }
    
    public static func * (lhs: Self, rhs: Double) -> Self {
        Self(absolute: lhs.absolute * rhs, relative: lhs.relative * rhs)
    }
    
    public static func * (lhs: Double, rhs: Self) -> Self {
        Self(absolute: rhs.absolute * lhs, relative: rhs.relative * lhs)
    }
    
    public static func / (lhs: Self, rhs: Double) -> Self {
        Self(absolute: lhs.absolute / rhs, relative: lhs.relative / rhs)
    }
    
    public static prefix func - (rhs: Self) -> Self {
        rhs * -1
    }
}

/// A layout similar to the Khanacademy layout.
public struct PJSCanvas<T: Game>: View {
    @Binding var game: T
    
    public var body: some View {
        GameView($game)
            .frame(width: 400, height: 400)
            .border(.gray)
            .background(.white)
    }
}

/// A view to display the game.
public struct GameView<T: Game>: View {
    @Binding var game: T
    @Modifiable var prevTime: Date? = nil
    @Modifiable var mousePosition: CGPoint = .zero
    @Modifiable var prevMousePosition: CGPoint = .zero
    
    @State var mouseIsPressed = false
    @State var mouseButton: CGMouseButton? = nil
    
    @State var frameRate = 60.0
    
    @State var key: UInt16? = nil
    @State var keyText: String? = nil
    @State var specialKey: NSEvent.SpecialKey? = nil
    @State var keyIsPressed = false
    
    @Modifiable var canvasValues = CanvasValues(frameTime: 0, mouseX: 0, mouseY: 0, pmouseX: 0, pmouseY: 0, width: 400, height: 400, mouseIsPressed: false, mouseButton: nil, key: nil, keyText: nil, specialKey: nil, keyIsPressed: false)
    
    public var body: some View {
        TimelineView(.animation(minimumInterval: 1 / frameRate)) { context in
            Canvas { ctx, size in
                var frameTime = 0.0
                
                if let prevTime {
                    frameTime = context.date.timeIntervalSinceReferenceDate - prevTime.timeIntervalSinceReferenceDate
                }
                    
                prevTime = context.date
                print("Save the date!")
                
                var values = GameValues(frameRate: $frameRate)
                
                self.canvasValues = CanvasValues(frameTime: frameTime, mouseX: mousePosition.x, mouseY: mousePosition.y, pmouseX: prevMousePosition.x, pmouseY: prevMousePosition.y, width: size.width, height: size.height, mouseIsPressed: mouseIsPressed, mouseButton: mouseButton, key: key, keyText: keyText, specialKey: specialKey, keyIsPressed: keyIsPressed)
                
                for instruction in game.draw(values: canvasValues).instructions {
                    switch instruction() {
                    case .draw(let closure):
                        closure(&ctx, size, values)
                    case .action(let closure):
                        closure(&values)
                    }
                }
                
                self.prevMousePosition = mousePosition
            }
            .onAppear {
                game.setup()
            }
            .onContinuousHover { phase in
                if case let .active(point) = phase {
                    self.mousePosition = point
                }
            }
            .gesture (
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        self.mousePosition = value.location
                        mouseIsPressed = true
                    }
                    .onEnded { value in
                        self.mousePosition = value.location
                        mouseIsPressed = false
                    }
            )
            .onAppear {
                NSEvent.addLocalMonitorForEvents(matching: .leftMouseUp) { event in
                    game.mouseClicked(values: canvasValues)
                    game.mouseReleased(values: canvasValues)
                    
                    mouseButton = nil
                    return event
                }
                NSEvent.addLocalMonitorForEvents(matching: .rightMouseUp) { event in
                    game.mouseClicked(values: canvasValues)
                    game.mouseReleased(values: canvasValues)
                    
                    mouseButton = .right
                    return event
                }
                NSEvent.addLocalMonitorForEvents(matching: .otherMouseUp) { event in
                    game.mouseClicked(values: canvasValues)
                    game.mouseReleased(values: canvasValues)
                    
                    mouseButton = nil
                    return event
                }
                
                NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { event in
                    game.mousePressed(values: canvasValues)
                    
                    mouseButton = .left
                    return event
                }
                NSEvent.addLocalMonitorForEvents(matching: .rightMouseDown) { event in
                    game.mousePressed(values: canvasValues)
                    
                    mouseButton = .right
                    return event
                }
                NSEvent.addLocalMonitorForEvents(matching: .otherMouseDown) { event in
                    game.mousePressed(values: canvasValues)
                    
                    mouseButton = .center
                    return event
                }
                
                NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { event in
                    game.mouseMoved(values: canvasValues)
                    return event
                }
                
                NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDragged, .otherMouseDragged]) { event in
                    game.mouseDragged(values: canvasValues)
                    return event
                }
                
                NSEvent.addLocalMonitorForEvents(matching: [.rightMouseDragged]) { event in
                    game.mouseDragged(values: canvasValues)
                    
                    mouseButton = .right
                    return event
                }
                
                NSEvent.addLocalMonitorForEvents(matching: .mouseEntered) {
                    game.mouseOver(values: canvasValues)
                    return $0
                }
                
                NSEvent.addLocalMonitorForEvents(matching: .mouseExited) {
                    game.mouseOut(values: canvasValues)
                    return $0
                }
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    key = event.keyCode
                    keyText = event.characters
                    specialKey = event.specialKey
                    keyIsPressed = true
                    game.keyPressed(values: canvasValues)
                    return event
                }
                NSEvent.addLocalMonitorForEvents(matching: .keyUp) { event in
                    print("Key up")
                    keyIsPressed = false
                    game.keyReleased(values: canvasValues)
                    return event
                }
            }
            .drawingGroup()
        }
    }
    
    /// Creates a game view displaying `game`.
    public init(_ game: Binding<T>) {
        self._game = game
    }
}

/// An attribute to apply to properties so you can modify them in the draw function. A property can either be changed from within the canvas or observed and changed from outside, but not both.
@propertyWrapper public class Changeable<T> {
    var _value: T
    
    public var wrappedValue: T {
        get {
            _value
        }
        set { _value = newValue }
    }
    
    public init(wrappedValue: T) {
        self._value = wrappedValue
    }
    
    public var projectedValue: Changeable<T> { self }
}
public typealias Modifiable = Changeable

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

public struct CanvasPoint: Hashable {
    public var relative: UnitPoint = .zero
    public var absolute: CGPoint = .zero
    
    public var x: CanvasValue {
        get { CanvasValue(absolute: absolute.x, relative: relative.x) }
        set { relative.x = newValue.relative; absolute.x = newValue.absolute }
    }
    
    public var y: CanvasValue {
        get { CanvasValue(absolute: absolute.y, relative: relative.y) }
        set { relative.y = newValue.relative; absolute.y = newValue.absolute }
    }
    
    public init(relative: UnitPoint, absolute: CGPoint) {
        self.relative = relative
        self.absolute = absolute
    }
    
    public init(x: CanvasValue = .zero, y: CanvasValue = .zero) {
        self.relative = UnitPoint(x: x.relative, y: y.relative)
        self.absolute = CGPoint(x: x.absolute, y: y.absolute)
    }
    
    static func relative(_ point: UnitPoint) -> Self {
        .init(relative: point, absolute: .zero)
    }
    
    static func absolute(_ point: CGPoint) -> Self {
        .init(relative: .zero, absolute: point)
    }
    
    static func relative(x: Double = .zero, y: Double = .zero) -> Self {
        .init(relative: UnitPoint(x: x, y: y), absolute: .zero)
    }
    
    static func absolute(x: Double = .zero, y: Double = .zero) -> Self {
        .init(relative: .zero, absolute: CGPoint(x: x, y: y))
    }
}
extension CanvasPoint: AdditiveArithmetic {
    public static var zero: Self {
        Self(relative: .zero, absolute: .zero)
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

extension CanvasPoint {
    public func resolve(_ size: CGSize) -> CGPoint {
        CGPoint(x: x.resolve(for: size.width), y: y.resolve(for: size.height))
    }
}

public struct CanvasSize {
    public var width: CanvasValue
    public var height: CanvasValue
    
    public init(width: CanvasValue = .zero, height: CanvasValue = .zero) {
        self.width = width
        self.height = height
    }
    
    static func relative(_ size: CGSize) -> Self {
        .init(width: .relative(size.width), height: .relative(size.height))
    }
    
    static func absolute(_ size: CGSize) -> Self {
        .init(width: .absolute(size.width), height: .absolute(size.height))
    }
    
    static func relative(width: Double = .zero, height: Double = .zero) -> Self {
        .init(width: .relative(width), height: .relative(height))
    }
    
    static func absolute(width: Double = .zero, height: Double = .zero) -> Self {
        .init(width: .absolute(width), height: .absolute(height))
    }
}
extension CanvasSize: AdditiveArithmetic {
    public static var zero: Self {
        Self(width: .zero, height: .zero)
    }
    
    public static func + (lhs: Self, rhs: Self) -> Self {
        Self(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    public static func - (lhs: Self, rhs: Self) -> Self {
        Self(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
}

public extension CGRect {
    init(center: CGPoint, size: CGSize) {
        var center = center
        center.x -= size.width / 2
        center.y -= size.height / 2
        self.init(origin: center, size: size)
    }
    
    init(origin: CGPoint, opposite: CGPoint) {
        self.init(origin: origin, size: CGSize(width: opposite.x - origin.x, height: opposite.y - origin.y))
    }
}

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }
    
    static func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x / scalar, y: point.y / scalar)
    }
}
 
infix operator <-
public func <- <T> (lhs: Modifiable<T>, rhs: DelayedValue<T>) -> Instruction {
    rhs.send { lhs.wrappedValue = $0 }
}

public protocol Node {
    @ContentBuilder func draw(values: CanvasValues) -> Content
}

public extension ContentBuilder {
}

