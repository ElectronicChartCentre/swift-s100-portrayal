//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public class TransformState {
    
    var rotationCRS: String?
    var rotation: Double?
    
    var scaleFactor: Double?
    
    var localOffsetXMM: Double?
    var localOffsetYMM: Double?
    
    var linePlacementMode: String = LinePlacementCommand.Relative
    var linePlacementOffset: Double = 0.5
    var linePlacementEndOffset: Double?
    var linePlacementVisibleParts: Bool = false

    public func toRecord() -> Record {
        return .init(rotationCRS: rotationCRS, rotation: rotation, scaleFactor: scaleFactor, localOffsetXMM: localOffsetXMM, localOffsetYMM: localOffsetYMM, linePlacementMode: linePlacementMode, linePlacementOffset: linePlacementOffset, linePlacementEndOffset: linePlacementEndOffset, linePlacementVisibleParts: linePlacementVisibleParts)
    }
    
    public struct Record: Sendable {
        
        let rotationCRS: String?
        let rotation: Double?
        
        let scaleFactor: Double?
        
        let localOffsetXMM: Double?
        let localOffsetYMM: Double?
        
        let linePlacementMode: String
        let linePlacementOffset: Double
        let linePlacementEndOffset: Double?
        let linePlacementVisibleParts: Bool
        
    }
    
}
