//
//  File.swift
//  swift-s100-portrayal
//

import Foundation

public struct FeatureDrawingCommand {
    
    public let featureId: String
    public let drawingCommandId: String
    public let drawingCommand: any DrawingCommand
    
}
