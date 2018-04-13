//
//  MarchingCubes.swift
//  ios-test-marchingcube-0
//
//  Created by Louis Foster on 13/4/18.
//  Copyright © 2018 Louis Foster. All rights reserved.
//

import Foundation

protocol MarchingCubesProtocol {
    
    // Buffers
    var vList: [Float] { get set }
    var nList: [Float] { get set }
    
    // Include UVs and Colors
    var enableUVs: Bool { get set }
    var enableColors: Bool { get set }
    
    // Resolution (size) of area
    var resolution: Float { get }
    var size: Float { get } // == resolution
    var size2: Float { get } // == size * size
    var size3: Float { get } // == size2 * size
    var halfSize: Float { get } // == size * 0.5
    
    // Size deltas
    var delta: Float { get } // == 2 / size
    var yDelta: Float { get } // == size
    var zDelta: Float { get } // == size2
    
    var field: [Float] { get } // length == size3
    var normalCache: [Float] { get set } // length == size3 * 3
    
    // Parameters
    var isolation: Float { get }
    
    // Immediate render mode simulator
    var maxCount: Int { get } // should == 4096
    var count: Int { get } // start @ 0
    
    var hasPositions: Bool { get } // false
    var hasNormals: Bool { get } // false
    var hasColors: Bool { get } // false
    var hasUVs: Bool { get } // false
    
    var positionArray: [Float] { get } // length == maxCount * 3
    var normalArray: [Float] { get } // length == maxCount * 3
    
    var uvArray: [Float]? { get }
    var colorArray: [Float]? { get }
}

extension MarchingCubesProtocol {
    
    // TODO: revise and interpret
    mutating func VIntX(q: Int, offset: Int, isol: Float, x: Float, y: Float, z: Float, valp1: Float, valp2: Float) {
    
        let mu = ( isol - valp1 ) / ( valp2 - valp1 )
        let nc = self.normalCache
        
        self.vList[offset + 0] = x + mu * self.delta
        self.vList[offset + 1] = y
        self.vList[offset + 2] = z
        
        self.nList[offset + 0] = lerp(input0: nc[q + 0], input1: nc[q + 3], parameter: mu)
        self.nList[offset + 1] = lerp(input0: nc[q + 1], input1: nc[q + 4], parameter: mu)
        self.nList[offset + 2] = lerp(input0: nc[q + 2], input1: nc[q + 5], parameter: mu)
    }
    
    // TODO: revise and interpret
    mutating func VIntY(q: Int, offset: Int, isol: Float, x: Float, y: Float, z: Float, valp1: Float, valp2: Float) {
    
        let mu = ( isol - valp1 ) / ( valp2 - valp1 )
        let nc = self.normalCache
        
        self.vList[offset + 0] = x
        self.vList[offset + 1] = y + mu * self.delta
        self.vList[offset + 2] = z
    
        let q2 = q + Int(self.yDelta * 3)
        
        self.nList[offset + 0] = lerp(input0: nc[q + 0], input1: nc[q2 + 0], parameter: mu)
        self.nList[offset + 1] = lerp(input0: nc[q + 1], input1: nc[q2 + 1], parameter: mu)
        self.nList[offset + 2] = lerp(input0: nc[q + 2], input1: nc[q2 + 2], parameter: mu)
    }
    
    // TODO: revise and interpret
    mutating func VIntZ(q: Int, offset: Int, isol: Float, x: Float, y: Float, z: Float, valp1: Float, valp2: Float) {
    
        let mu = ( isol - valp1 ) / ( valp2 - valp1 )
        let nc = self.normalCache
        
        self.vList[offset + 0] = x
        self.vList[offset + 1] = y
        self.vList[offset + 2] = z + mu * self.delta
    
        let q2 = q + Int(self.zDelta * 3)
    
        self.nList[offset + 0] = lerp(input0: nc[q + 0], input1: nc[q2 + 0], parameter: mu)
        self.nList[offset + 1] = lerp(input0: nc[q + 1], input1: nc[q2 + 1], parameter: mu)
        self.nList[offset + 2] = lerp(input0: nc[q + 2], input1: nc[q2 + 2], parameter: mu)
    }
    
    // TODO: revise and interpret
    mutating func compNorm(q: Int) {
    
        let q3 = q * 3;
    
        if self.normalCache[q3] == 0.0 {
    
            self.normalCache[q3 + 0] = self.field[q - 1] - self.field[q + 1]
            self.normalCache[q3 + 1] = self.field[q - Int(self.yDelta)] - self.field[q + Int(self.yDelta)]
            self.normalCache[q3 + 2] = self.field[q - Int(self.zDelta)] - self.field[q + Int(self.zDelta)]
        }
    }
}


struct MarchingCubes: MarchingCubesProtocol {
    
    var uvArray: [Float]?
    var colorArray: [Float]?
    var vList: [Float]
    var nList: [Float]
    var enableUVs: Bool
    var enableColors: Bool
    var resolution: Float
    var size: Float
    var size2: Float
    var size3: Float
    var halfSize: Float
    var delta: Float
    var yDelta: Float
    var zDelta: Float
    var field: [Float]
    var normalCache: [Float]
    var isolation: Float
    var maxCount: Int
    var count: Int
    var hasPositions: Bool
    var hasNormals: Bool
    var hasColors: Bool
    var hasUVs: Bool
    var positionArray: [Float]
    var normalArray: [Float]
    
    init() {
        
        self.vList = [Float].init(repeating: 0, count: 36)
        self.nList = [Float].init(repeating: 0, count: 36)
        
        self.enableUVs = true
        self.enableColors = true
        
        self.resolution = 16
        self.size = self.resolution
        self.size2 = square(x: self.size)
        self.size3 = self.size2 * self.size
        self.halfSize = self.size * 0.5
        
        self.isolation = 80.0
        
        self.delta = 2.0 / self.size
        self.yDelta = self.size
        self.zDelta = self.size2
        
        self.field = [Float].init(repeating: 0, count: Int(self.size3))
        self.normalCache = [Float].init(repeating: 0, count: Int(self.size3 * 3))
        
        self.maxCount = 4096
        self.count = 0
        
        self.hasPositions = false
        self.hasNormals = false
        self.hasColors = false
        self.hasUVs = false
        
        self.positionArray = [Float].init(repeating: 0, count: Int(self.maxCount * 3))
        self.normalArray = [Float].init(repeating: 0, count: Int(self.maxCount * 3))
        
        if self.enableUVs {
            
            self.uvArray = [Float].init(repeating: 0, count: self.maxCount * 2)
        }
        else {
            
            self.colorArray = [Float].init(repeating: 0, count: self.maxCount * 3)
        }
    }
    
}
