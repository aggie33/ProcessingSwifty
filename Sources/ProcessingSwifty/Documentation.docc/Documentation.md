# ``ProcessingSwifty``

Have you ever wanted ProcessingJS, but in Swift? We try to get close to that in this project.

## Overview

Start out by defining a new type that conforms to the `Game` protocol:

```swift
public struct ExampleGame: Game {
    public func draw(values: CanvasValues) -> Content {
        // drawing code here
    }
}
```

Then, use various drawing functions provided by us to draw content in the canvas.

```swift
public struct Snowman: Game {
    public func draw(values: CanvasValues) -> Content {
        fill(.white)
        stroke(.black)
    
        // the body
        ellipse(centerX: 200, centerY: 300, radius: 150)
        ellipse(centerX: 200, centerY: 200, radius: 100)
        ellipse(centerX: 200, centerY: 100, radius: 50)
    
        // the eyes
        fill(.black)
        ellipse(centerX: 190, centerY: 90, radius: 5) 
        ellipse(centerX: 210, centerY: 90, radius: 5)
    }
}
```

To make your own function that does this, use the `ContentBuilder` attribute.

```swift
@ContentBuilder public func drawRainbow() -> Content {
    noFill()
    strokeWeight(30)
    strokeCap(.square)

    stroke(.red)
    arc(centerX: .relative(0.5), centerY: .relative(0.5), width: .relative(0.6), height: .relative(0.6), from: .radians(.pi), to: .radians(0))

    stroke(.orange)
    arc(centerX: .relative(0.5), centerY: .relative(0.5), width: .relative(0.6) - 60, height: .relative(0.6) - 60, from: .radians(.pi), to: .radians(0))

    stroke(.yellow)
    arc(centerX: .relative(0.5), centerY: .relative(0.5), width: .relative(0.6) - 120, height: .relative(0.6) - 120, from: .radians(.pi), to: .radians(0))

    stroke(.green)
    arc(centerX: .relative(0.5), centerY: .relative(0.5), width: .relative(0.6) - 180, height: .relative(0.6) - 180, from: .radians(.pi), to: .radians(0))
}
```

## Topics

### Setting up your game

- ``Game``
- ``GameView``
- ``PJSCanvas``

### Supporting types

- ``CanvasValues``
- ``GameValues``
- ``Content``
- ``ContentBuilder``
- ``Instruction````

### Numeric values

- ``CanvasValue``
- ``CanvasPoint``
- ``CanvasSize``

### Modifiable values

- ``Modifiable``
- ``Changeable``
- ``DelayedValue``
- ``<-(lhs:rhs:)``

### Drawing rectangles

- ``rect(_:_:_:_:_:)-6u6nv``
- ``rect(_:_:_:_:_:)-bn7t``
- ``rect(center:size:cornerRadius:)``
- ``rect(origin:size:cornerRadius:)``
- ``rect(origin:opposite:cornerRadius:)``
- ``rect(x:y:width:height:cornerRadius:)``
- ``rect(x:y:oppositeX:oppositeY:cornerRadius:)``
- ``rect(centerX:centerY:width:height:cornerRadius:)
- ``rect(centerX:centerY:xRadius:yRadius:cornerRadius:)``
- ``rectMode(_:)``
- ``RectMode``
