//
//  File.swift
//  SwiftS100Portrayal
//

import Foundation

public protocol DrawingCommand: Sendable {
    
    var visibilityState: VisibilityState.Record { get }
    
    var instructionTypePriority: Int { get }
    
}
