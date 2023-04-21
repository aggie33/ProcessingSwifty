//
//  Math.swift
//  ProcessingJS-Swift
//
//  Created by Eric Bodnick on 4/17/23.
//

import Foundation

public func dist(_ x1: Double, _ y1: Double, _ x2: Double, _ y2: Double) -> Double {
    sqrt(pow(x2 - x1, 2) + pow(y2 - y1, 2))
}
