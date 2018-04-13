//
//  Helpers.swift
//  ios-test-marchingcube-0
//
//  Created by Louis Foster on 13/4/18.
//  Copyright © 2018 Louis Foster. All rights reserved.
//

import Foundation

// Squaring func for semantic squares
public func square(x: Int) -> Int { return x * x }
public func square(x: Float) -> Float { return x * x }

/* Imprecise
public func lerp(a: Float, b: Float, t: Float) -> Float {
    
    return a + ( b - a ) * t;
}
*/

// Lerping (linear interpolation) for ...
// https://en.wikipedia.org/wiki/Linear_interpolation
public func lerp(input0 v0: Float, input1 v1: Float, parameter t: Float) -> Float {
    
    return (1 - t) * v0 + t * v1
}
