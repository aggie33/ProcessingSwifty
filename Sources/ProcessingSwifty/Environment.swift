//
//  Environment.swift
//  ProcessingJS-Swift
//
//  Created by Eric Bodnick on 4/16/23.
//

import Foundation
import AVFoundation

public var width: DelayedValue<Double> {
    DelayedValue(obtain: { _, size, _ in size.width })
}
public var height: DelayedValue<Double> {
    DelayedValue(obtain: { _, size, _ in size.height })
}

public func getSound(named resource: String, withExtension: String? = nil) -> AVAudioPlayer? {
    try? Bundle.main.url(forResource: resource, withExtension: withExtension).map(AVAudioPlayer.init(contentsOf:))
}

public func playSound(_ sound: AVAudioPlayer?) -> Instruction {
    .action { _ in
        sound?.play()
        
        if sound == nil {
            print("Attempted to play 'nil' sound.")
        }
    }
}
public func pauseSound(_ sound: AVAudioPlayer?) -> Instruction {
    .action { _ in sound?.pause() }
}

/// Don't rely on the frame rate being `rate`, as it will increase to the maximum possible value when the user interacts with the canvas to ensure smoothness. Make sure to multiply any offsets by `frameTime`.
public func frameRate(_ rate: Double) -> Instruction {
    .action { values in
        let frameRate = values.$frameRate
        Task { await MainActor.run { frameRate.wrappedValue = rate } }
    }
}

/// Sets the frame rate to 0, effectively stopping the animation.
public func noLoop() -> Instruction {
    frameRate(0)
}

/// Returns the frame rate to maximum.
public func loop() -> Instruction { frameRate(120) }
