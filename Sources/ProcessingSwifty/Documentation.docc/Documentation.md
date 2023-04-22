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

    stroke(.red)
    arc(centerX: .relative(0.5), centerY: .relative(1) - 150, width: .relative(1), height: 300, from: .degrees(0), to: .degrees(180))

    stroke(.orange)
    arc(centerX: .relative(0.5), centerY: .relative(1) - 150, width: .relative(1) - 60, height: 270, from: .degrees(0), to: .degrees(180))
}
```

## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
